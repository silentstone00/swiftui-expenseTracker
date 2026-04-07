//
//  HomeView.swift
//  expense_tracker
//
//  Enhanced dashboard with fintech-style layout and smart empty states
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    
    @EnvironmentObject private var viewModel: TransactionViewModel
    @State private var isRefreshing = false
    @State private var transactionToEdit: Transaction?
    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color(red: 0.05, green: 0.05, blue: 0.05)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Balance Card
                        if let summary = viewModel.monthlySummary {
                            BalanceCard(summary: summary)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }

                        // Recent Transactions Section
                        recentTransactionsSection
                    }
                    .padding(.bottom, 100)
                }
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle("Dashboard \(moodEmoji)")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $transactionToEdit) { transaction in
                EditTransactionView(transaction: transaction)
                    .environmentObject(viewModel)
                    .environmentObject(CategoryViewModel())
            }
        }
    }
    
    // MARK: - Recent Transactions Section
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !recentTransactions.isEmpty {
                    NavigationLink {
                        AllTransactionsView()
                            .environmentObject(viewModel)
                            .environmentObject(CategoryViewModel())
                    } label: {
                        HStack(spacing: 4) {
                            Text("See All")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                        }
                        .foregroundColor(Color.accentColor)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            if recentTransactions.isEmpty {
                SmartEmptyState(type: .noTransactions)
                    .frame(height: 300)
            } else {
                ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                    TransactionRow(
                        transaction: transaction,
                        onEdit: {
                            transactionToEdit = transaction
                        },
                        onDelete: {
                            Task {
                                try? await viewModel.deleteTransaction(transaction)
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.05),
                        value: recentTransactions.count
                    )
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var recentTransactions: [Transaction] {
        Array(viewModel.transactions.prefix(5))
    }

    private var moodEmoji: String {
        guard let summary = viewModel.monthlySummary, summary.totalIncome > 0 else { return "😐" }
        let income  = Double(truncating: summary.totalIncome as NSNumber)
        let balance = Double(truncating: (summary.totalIncome - summary.totalExpenses) as NSNumber)
        let ratio   = balance / income  // what % of income is left

        switch ratio {
        case ..<0.33: return "😔"   // balance < 33% of income
        case 0.33..<0.66: return "😐"   // balance 33–66% of income
        default:      return "😊"   // balance > 66% of income
        }
    }
    
    // MARK: - Methods
    
    private func refreshData() async {
        isRefreshing = true
        await viewModel.loadTransactions()
        try? await Task.sleep(nanoseconds: 300_000_000)
        isRefreshing = false
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
