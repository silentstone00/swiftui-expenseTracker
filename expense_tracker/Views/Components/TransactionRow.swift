//
//  TransactionRow.swift
//  expense_tracker
//
//  Reusable transaction row component with Figma-style inner shadows
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(transaction.category.color.color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
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
                
                HStack(spacing: 8) {
                    if let note = transaction.note, !note.isEmpty {
                        Text(note)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(amountColor)
                
                Text(transaction.type == .income ? "Income" : "Expense")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.09, green: 0.09, blue: 0.09))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.gray.opacity(0.07), lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white.opacity(0.4), location: 0.0),
                            .init(color: .white.opacity(0.2), location: 0.1),
                            .init(color: .white.opacity(0.05), location: 0.25),
                            .init(color: .white.opacity(0.0), location: 0.43),
                            .init(color: .white.opacity(0.05), location: 0.46),
                            .init(color: .white.opacity(0.4), location: 0.5),
                            .init(color: .white.opacity(0.2), location: 0.6),
                            .init(color: .white.opacity(0.05), location: 0.75),
                            .init(color: .white.opacity(0.0), location: 0.93),
                            .init(color: .white.opacity(0.2), location: 0.97),
                            .init(color: .white.opacity(0.4), location: 1.0),
                        ]),
                        center: .center,
                        startAngle: .degrees(192),
                        endAngle: .degrees(552)
                    ),
                    lineWidth: 1.0
                )
        )
        .innerShadow(color: Color.white.opacity(0.15), radius: 3.5, x: 2, y: 2)
        .innerShadow(color: Color.black.opacity(0.25), radius: 3.5, x: -2, y: -2)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .contextMenu {
            Button(action: {
                onEdit?()
            }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: {
                showDeleteAlert = true
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Transaction", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
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
        transaction.type == .income ? .green.opacity(0.7) : .red.opacity(0.7)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: transaction.date)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.05)
            .ignoresSafeArea()
        
        VStack(spacing: 16) {
            TransactionRow(
                transaction: Transaction(
                    amount: 45.50,
                    type: .expense,
                    category: Category.predefined[0],
                    date: Date(),
                    note: "Lunch at cafe"
                ),
                onEdit: { print("Edit tapped") },
                onDelete: { print("Delete tapped") }
            )
            
            TransactionRow(
                transaction: Transaction(
                    amount: 1200.00,
                    type: .income,
                    category: Category.predefined[1],
                    date: Date(),
                    note: nil
                ),
                onEdit: { print("Edit tapped") },
                onDelete: { print("Delete tapped") }
            )
        }
        .padding()
    }
}
