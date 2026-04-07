//
//  LaunchScreenView.swift
//  expense_tracker
//
//  Launch screen matching app theme
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background matching app theme
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App icon placeholder with gradient
                ZStack {
                    // Gradient circle matching balance card
                    Circle()
                        .fill(AppTheme.balanceCardGradient)
                        .frame(width: 120, height: 120)
                    
                    // Dollar sign icon
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                
                // App name
                Text("Expense Tracker")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primaryText)
                
                // Tagline
                Text("Track your finances")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
