//
//  AllTransactionsView.swift
//  expense_tracker
//

import SwiftUI

struct AllTransactionsView: View {
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    @EnvironmentObject private var appState: AppState

    @State private var selectedFilters: Set<UUID> = []
    @State private var transactionToEdit: Transaction?
    @State private var showFilterSheet: Bool = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                if !categoryViewModel.categories.isEmpty {
                    categoryFilterChips.padding(.vertical, 12)
                }

                if filteredTransactions.isEmpty {
                    emptyStateView
                } else {
                    transactionList
                }
            }
        }
        .navigationTitle("All Transactions")
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            appState.showFAB = false
            Task { await categoryViewModel.loadCategories() }
        }
        .onDisappear { appState.showFAB = true }
        .sheet(item: $transactionToEdit) { transaction in
            EditTransactionView(transaction: transaction)
                .environmentObject(transactionViewModel)
                .environmentObject(categoryViewModel)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showFilterSheet) {
            CategoryFilterSheet(
                categories: categoryViewModel.categories,
                selectedFilters: $selectedFilters
            )
        }
    }

    // MARK: - Computed Properties

    private var filteredTransactions: [Transaction] {
        guard !selectedFilters.isEmpty else {
            return transactionViewModel.transactions
        }
        return transactionViewModel.transactions.filter {
            selectedFilters.contains($0.category.id)
        }
    }

    private var groupedTransactions: [(String, [Transaction])] {
        let calendar = Calendar.current
        let now = Date()

        let grouped = Dictionary(grouping: filteredTransactions) { transaction -> String in
            if calendar.isDateInToday(transaction.date) {
                return "Today"
            } else if calendar.isDateInYesterday(transaction.date) {
                return "Yesterday"
            } else if calendar.isDate(transaction.date, equalTo: now, toGranularity: .weekOfYear) {
                return "This Week"
            } else if calendar.isDate(transaction.date, equalTo: now, toGranularity: .month) {
                return "This Month"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: transaction.date)
            }
        }

        let sortOrder = ["Today", "Yesterday", "This Week", "This Month"]
        return grouped.sorted { first, second in
            if let firstIndex = sortOrder.firstIndex(of: first.key),
               let secondIndex = sortOrder.firstIndex(of: second.key) {
                return firstIndex < secondIndex
            }
            if sortOrder.contains(first.key) { return true }
            if sortOrder.contains(second.key) { return false }
            if let firstDate = first.value.first?.date,
               let secondDate = second.value.first?.date {
                return firstDate > secondDate
            }
            return first.key > second.key
        }
    }

    // MARK: - Category Filter Chips

    private var categoryFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            // All chip
            FilterChip(
                title: "All",
                icon: "line.3.horizontal.decrease.circle",
                color: .accentColor,
                isSelected: selectedFilters.isEmpty
            ) {
                selectedFilters.removeAll()
            }

            // First 4 categories
            ForEach(Array(categoryViewModel.categories.prefix(4))) { category in
                FilterChip(
                    title: category.name,
                    icon: category.icon,
                    color: category.color.color,
                    isSelected: selectedFilters.contains(category.id)
                ) {
                    if selectedFilters.contains(category.id) {
                        selectedFilters.remove(category.id)
                    } else {
                        selectedFilters.insert(category.id)
                    }
                }
            }

            // More button — shown if categories > 4
            if categoryViewModel.categories.count > 4 {
                let extraSelected = selectedFilters.filter { id in
                    !categoryViewModel.categories.prefix(4).map(\.id).contains(id)
                }.count

                Button(action: { showFilterSheet = true }) {
                    HStack(spacing: 5) {
                        if extraSelected > 0 {
                            Text("\(extraSelected)")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                                .background(Circle().fill(Color.accentColor))
                        }
                        Text("•••")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(extraSelected > 0 ? Color.accentColor : .primaryText)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        extraSelected > 0
                            ? Color.accentColor.opacity(0.15)
                            : Color.inputBackground
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                extraSelected > 0 ? Color.accentColor.opacity(0.4) : Color.clear,
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
          }
          .padding(.horizontal)
          .padding(.vertical, 2)
        }
    }

    // MARK: - Transaction List

    private var transactionList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedTransactions, id: \.0) { group in
                    Section {
                        ForEach(Array(group.1.sorted(by: { $0.date > $1.date }).enumerated()), id: \.element.id) { _, transaction in
                            TransactionRow(
                                transaction: transaction,
                                onEdit: { transactionToEdit = transaction },
                                onDelete: {
                                    Task { try? await transactionViewModel.deleteTransaction(transaction) }
                                }
                            )
                            .padding(.horizontal)
                        }
                    } header: {
                        Text(group.0)
                            .font(.headline)
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.appBackground)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        SmartEmptyState(type: selectedFilters.isEmpty ? .noTransactions : .noFilteredTransactions)
    }
}

// MARK: - Category Filter Sheet

struct CategoryFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    let categories: [Category]
    @Binding var selectedFilters: Set<UUID>

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(categories) { category in
                            Button(action: {
                                if selectedFilters.contains(category.id) {
                                    selectedFilters.remove(category.id)
                                } else {
                                    selectedFilters.insert(category.id)
                                }
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(category.color.color.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: category.icon)
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(category.color.color)
                                    }

                                    Text(category.name)
                                        .font(.body)
                                        .foregroundColor(.primaryText)

                                    Spacer()

                                    ZStack {
                                        Circle()
                                            .strokeBorder(
                                                selectedFilters.contains(category.id)
                                                    ? category.color.color
                                                    : Color.secondaryText.opacity(0.3),
                                                lineWidth: 2
                                            )
                                            .frame(width: 24, height: 24)
                                        if selectedFilters.contains(category.id) {
                                            Circle()
                                                .fill(category.color.color)
                                                .frame(width: 14, height: 14)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(
                                    selectedFilters.contains(category.id)
                                        ? category.color.color.opacity(0.06)
                                        : Color.clear
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .padding(.leading, 78)
                                .opacity(0.3)
                        }
                    }
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .padding()
                }
            }
            .navigationTitle("Filter by Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        selectedFilters.removeAll()
                    }
                    .foregroundColor(.secondaryText)
                    .disabled(selectedFilters.isEmpty)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

// MARK: - Filter Chip Component

struct FilterChip: View {
    let title: String
    let icon: String
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 14))
                Text(title).font(.subheadline).fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.18) : Color.inputBackground)
            .foregroundColor(isSelected ? color : .primaryText)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    AllTransactionsView()
}
