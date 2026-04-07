//
//  HomeView.swift
//  expense_tracker
//
//  Main dashboard view displaying monthly summary and recent transactions
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    
    @EnvironmentObject private var viewModel: TransactionViewModel
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

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
