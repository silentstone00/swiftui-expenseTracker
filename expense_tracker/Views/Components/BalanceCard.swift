//
//  BalanceCard.swift
//  expense_tracker
//
//  Reusable component displaying monthly financial summary with gradient background
//

import SwiftUI

struct BalanceCard: View {
    // MARK: - Properties
    
    let summary: MonthlySummary
    @Environment(\.colorScheme) var colorScheme
    @State private var animateNumbers: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Month display
            Text(monthText)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            // Balance (main value)
            VStack(spacing: 4) {
                Text("Balance")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(formatCurrency(summary.balance))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateNumbers ? 1 : 0)
            }
            
            // Income and Expenses row
            HStack(spacing: 32) {
                // Income
                VStack(spacing: 4) {
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(formatCurrency(summary.totalIncome))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(animateNumbers ? 1 : 0)
                }
                
                // Expenses
                VStack(spacing: 4) {
                    Text("Expenses")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(formatCurrency(summary.totalExpenses))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(animateNumbers ? 1 : 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(
            LinearGradient(
                gradient: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateNumbers = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Gradient colors based on theme
    private var gradientColors: Gradient {
        if colorScheme == .dark {
            // Dark mode: Deep purple to blue gradient
            return Gradient(colors: [
                Color(red: 0.4, green: 0.2, blue: 0.6),  // Deep purple
                Color(red: 0.2, green: 0.3, blue: 0.7)   // Deep blue
            ])
        } else {
            // Light mode: Vibrant purple to pink gradient
            return Gradient(colors: [
                Color(red: 0.6, green: 0.3, blue: 0.9),  // Vibrant purple
                Color(red: 0.9, green: 0.4, blue: 0.7)   // Pink
            ])
        }
    }
    
    /// Shadow color based on theme
    private var shadowColor: Color {
        colorScheme == .dark 
            ? Color.black.opacity(0.3) 
            : Color.purple.opacity(0.2)
    }
    
    /// Formatted month text
    private var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: summary.month)
    }
    
    // MARK: - Helper Methods
    
    /// Format decimal value as currency
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        
        let nsDecimal = value as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "$0.00"
    }
}

// MARK: - Preview

struct BalanceCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Light mode preview
            BalanceCard(summary: MonthlySummary(
                month: Date(),
                totalIncome: 5000.00,
                totalExpenses: 3200.50,
                transactionCount: 25
            ))
            .preferredColorScheme(.light)
            
            // Dark mode preview
            BalanceCard(summary: MonthlySummary(
                month: Date(),
                totalIncome: 5000.00,
                totalExpenses: 3200.50,
                transactionCount: 25
            ))
            .preferredColorScheme(.dark)
        }
        .padding()
    }
}
