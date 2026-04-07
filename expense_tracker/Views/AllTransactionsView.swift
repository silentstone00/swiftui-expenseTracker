//
//  AllTransactionsView.swift
//  expense_tracker
//
//  All transactions view with filtering options
//

import SwiftUI

struct AllTransactionsView: View {
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    @EnvironmentObject private var appState: AppState
    
    @State private var selectedFilter: Category?
    @State private var transactionToEdit: Transaction?
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Category filter chips
                if !categoryViewModel.categories.isEmpty {
                    categoryFilterChips
                        .padding(.vertical, 12)
                }

                // Transaction list or empty state
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
        .onAppear { appState.showFAB = false }
        .onDisappear { appState.showFAB = true }
        .sheet(item: $transactionToEdit) { transaction in
            EditTransactionView(transaction: transaction)
                .environmentObject(transactionViewModel)
                .environmentObject(categoryViewModel)
        }
        .task {
            await categoryViewModel.loadCategories()
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredTransactions: [Transaction] {
        if let selectedFilter = selectedFilter {
            // Filter by both category ID and name for better matching
            return transactionViewModel.transactions.filter { transaction in
                // Match by ID first (most reliable)
                if transaction.category.id == selectedFilter.id {
                    return true
                }
                // Fallback to name matching (case-insensitive)
                return transaction.category.name.lowercased() == selectedFilter.name.lowercased()
            }
        }
        return transactionViewModel.transactions
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
            if sortOrder.contains(first.key) {
                return true
            }
            if sortOrder.contains(second.key) {
                return false
            }
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
                FilterChip(
                    title: "All",
                    icon: "line.3.horizontal.decrease.circle",
                    isSelected: selectedFilter == nil
                ) {
                    selectedFilter = nil
                }
                
                ForEach(categoryViewModel.categories) { category in
                    FilterChip(
                        title: category.name,
                        icon: category.icon,
                        color: category.color.color,
                        isSelected: selectedFilter?.id == category.id
                    ) {
                        if selectedFilter?.id == category.id {
                            selectedFilter = nil
                        } else {
                            selectedFilter = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Transaction List
    
    private var transactionList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedTransactions, id: \.0) { group in
                    Section {
                        ForEach(Array(group.1.sorted(by: { $0.date > $1.date }).enumerated()), id: \.element.id) { index, transaction in
                            TransactionRow(
                                transaction: transaction,
                                onEdit: {
                                    transactionToEdit = transaction
                                },
                                onDelete: {
                                    Task {
                                        try? await transactionViewModel.deleteTransaction(transaction)
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                    } header: {
                        Text(group.0)
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.05, green: 0.05, blue: 0.05))
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        SmartEmptyState(type: selectedFilter == nil ? .noTransactions : .noFilteredTransactions)
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
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? Color.accentColor.opacity(0.2)
                    : Color(red: 0.12, green: 0.12, blue: 0.12)
            )
            .foregroundColor(isSelected ? Color.accentColor : .white)
            .cornerRadius(16)
        }
    }
}

// MARK: - Preview

#Preview {
    AllTransactionsView()
}
