//
//  BalanceView.swift
//  expense_tracker
//
//  Balance view with transactions list and statistics
//

import SwiftUI

struct BalanceView: View {
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    
    @State private var selectedFilter: Category?
    @State private var selectedSegment: Int = 0 // 0 = Transactions, 1 = Stats
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                Color(red: 0.05, green: 0.05, blue: 0.05)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Control
                    Picker("View", selection: $selectedSegment) {
                        Text("Transactions").tag(0)
                        Text("Statistics").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Content based on selection
                    if selectedSegment == 0 {
                        transactionsContent
                    } else {
                        statsContent
                    }
                }
            }
            .navigationTitle("Balance")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Transactions Content
    
    private var transactionsContent: some View {
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
    
    // MARK: - Stats Content
    
    private var statsContent: some View {
        StatsView()
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
                            TransactionRow(transaction: transaction)
                                .padding(.horizontal)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteTransaction(transaction)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
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

// MARK: - Preview

#Preview {
    BalanceView()
}
