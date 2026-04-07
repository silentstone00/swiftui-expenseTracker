//
//  BalanceView.swift
//  expense_tracker
//
//  Balance view with statistics and graphs only
//

import SwiftUI

struct BalanceView: View {
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                Color(red: 0.05, green: 0.05, blue: 0.05)
                    .ignoresSafeArea()
                
                // Stats content
                StatsView()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Preview

#Preview {
    BalanceView()
}
