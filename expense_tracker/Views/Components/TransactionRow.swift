//
//  TransactionRow.swift
//  expense_tracker
//
//  Reusable transaction row component with Figma-style inner shadows
//

import SwiftUI

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
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.15, green: 0.15, blue: 0.15), lineWidth: 1)
        )
        .innerShadow(color: Color.white.opacity(0.15), radius: 3.5, x: 2, y: 2)
        .innerShadow(color: Color.black.opacity(0.25), radius: 3.5, x: -2, y: -2)
        .clipShape(RoundedRectangle(cornerRadius: 14))
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

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.05)
            .ignoresSafeArea()
        
        VStack(spacing: 16) {
            TransactionRow(transaction: Transaction(
                amount: 45.50,
                type: .expense,
                category: Category.predefined[0],
                date: Date(),
                note: "Lunch at cafe"
            ))
            
            TransactionRow(transaction: Transaction(
                amount: 1200.00,
                type: .income,
                category: Category.predefined[1],
                date: Date(),
                note: nil
            ))
        }
        .padding()
    }
}
