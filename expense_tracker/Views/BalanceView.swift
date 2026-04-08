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
                Color.appBackground
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
