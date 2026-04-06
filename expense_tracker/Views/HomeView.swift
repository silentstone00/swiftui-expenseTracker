//
//  HomeView.swift
//  expense_tracker
//
//  Main dashboard view displaying monthly summary and recent transactions
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = TransactionViewModel()
    @State private var isRefreshing = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background matching Figma
                Color(red: 0.05, green: 0.05, blue: 0.05)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Balance Card with monthly summary
                        if let summary = viewModel.monthlySummary {
                            BalanceCard(summary: summary)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        } else {
                            // Loading state or empty summary
                            BalanceCard(summary: MonthlySummary(month: Date()))
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .redacted(reason: .placeholder)
                        }
                        
                        // Recent Transactions Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Transactions")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if !recentTransactions.isEmpty {
                                    Button(action: {
                                        // TODO: Navigate to full transaction list
                                    }) {
                                        Text("See All")
                                            .font(.subheadline)
                                            .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.75))
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if recentTransactions.isEmpty {
                                // Empty state
                                emptyStateView
                            } else {
                                // Recent transactions list
                                ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                                    TransactionRow(transaction: transaction)
                                        .padding(.horizontal)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)
                                        ))
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7).delay(Double(index) * 0.05), value: recentTransactions.count)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 24)
                }
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addTransactionButton
                }
            }
            .toolbarBackground(Color(red: 0.05, green: 0.05, blue: 0.05), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            await viewModel.loadTransactions()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Get the most recent 5-10 transactions
    private var recentTransactions: [Transaction] {
        let maxCount = 10
        return Array(viewModel.transactions.prefix(maxCount))
    }
    
    // MARK: - Subviews
    
    /// Empty state view when no transactions exist
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No transactions yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Tap + to add your first transaction")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
    
    /// Quick action button to add transaction
    private var addTransactionButton: some View {
        Button(action: {
            // TODO: Navigate to add transaction view
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.accentColor)
        }
    }
    
    // MARK: - Methods
    
    /// Refresh data with pull-to-refresh
    private func refreshData() async {
        isRefreshing = true
        await viewModel.loadTransactions()
        
        // Add slight delay for better UX
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        isRefreshing = false
    }
}

// MARK: - Transaction Row Component

/// Individual transaction row for the list
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(transaction.category.color.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transaction.category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(transaction.category.color.color)
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Amount
            Text(formattedAmount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(amountColor)
        }
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(16)
    }
    
    // MARK: - Computed Properties
    
    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        
        let nsDecimal = transaction.amount as NSDecimalNumber
        let amountString = formatter.string(from: nsDecimal) ?? "$0.00"
        
        return transaction.type == .income ? "+\(amountString)" : "-\(amountString)"
    }
    
    private var amountColor: Color {
        transaction.type == .income ? .green : .red
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: transaction.date)
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
