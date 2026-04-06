//
//  TransactionListView.swift
//  expense_tracker
//
//  View displaying scrollable list of transactions with grouping and filtering
//

import SwiftUI

struct TransactionListView: View {
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    
    @State private var selectedFilter: Category?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background matching Figma
                Color(red: 0.05, green: 0.05, blue: 0.05)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category filter chips
                    if !categoryViewModel.categories.isEmpty {
                        categoryFilterChips
                            .padding(.vertical, 8)
                    }
                    
                    // Transaction list or empty state
                    if filteredTransactions.isEmpty {
                        emptyStateView
                    } else {
                        transactionList
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbarBackground(Color(red: 0.05, green: 0.05, blue: 0.05), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await transactionViewModel.loadTransactions()
                await categoryViewModel.loadCategories()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredTransactions: [Transaction] {
        if let selectedFilter = selectedFilter {
            return transactionViewModel.transactions.filter { $0.category.id == selectedFilter.id }
        }
        return transactionViewModel.transactions
    }
    
    private var groupedTransactions: [(String, [Transaction])] {
        let calendar = Calendar.current
        let now = Date()
        
        // Group transactions by date
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
        
        // Sort groups by most recent first
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
            // For month names, compare dates
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
                
                // Category chips
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
                            TransactionRow(transaction: transaction)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                                .animation(.spring(response: 0.3, dampingFraction: 0.7).delay(Double(index) * 0.03), value: filteredTransactions.count)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteTransaction(transaction)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        // TODO: Navigate to edit view
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
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
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(selectedFilter == nil ? "No transactions yet" : "No transactions found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(selectedFilter == nil
                 ? "Tap + to add your first transaction"
                 : "Try selecting a different category")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Actions
    
    private func deleteTransaction(_ transaction: Transaction) {
        Task {
            do {
                try await transactionViewModel.deleteTransaction(transaction)
            } catch {
                print("Error deleting transaction: \(error)")
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
                    ? Color(red: 0.4, green: 0.8, blue: 0.75).opacity(0.2)
                    : Color(red: 0.12, green: 0.12, blue: 0.12)
            )
            .foregroundColor(isSelected ? Color(red: 0.4, green: 0.8, blue: 0.75) : .white)
            .cornerRadius(16)
        }
    }
}



// MARK: - Preview

#Preview {
    TransactionListView()
}
