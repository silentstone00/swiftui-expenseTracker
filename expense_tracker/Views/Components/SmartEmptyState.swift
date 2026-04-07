//
//  SmartEmptyState.swift
//  expense_tracker
//
//  Smart empty state component with contextual messaging
//

import SwiftUI

struct SmartEmptyState: View {
    let type: EmptyStateType
    @State private var animateIcon: Bool = false
    @State private var animateText: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                type.accentColor.opacity(0.2),
                                type.accentColor.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .opacity(animateIcon ? 1.0 : 0)
                
                Image(systemName: type.icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [type.accentColor, type.accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .opacity(animateIcon ? 1.0 : 0)
            }
            
            // Text content
            VStack(spacing: 12) {
                Text(type.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .opacity(animateText ? 1.0 : 0)
                    .offset(y: animateText ? 0 : 20)
                
                Text(type.message)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(animateText ? 1.0 : 0)
                    .offset(y: animateText ? 0 : 20)
                
                if let actionText = type.actionText {
                    Button(action: type.action ?? {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text(actionText)
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(type.accentColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(type.accentColor.opacity(0.15))
                        .cornerRadius(12)
                    }
                    .opacity(animateText ? 1.0 : 0)
                    .offset(y: animateText ? 0 : 20)
                    .padding(.top, 8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateIcon = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                animateText = true
            }
        }
    }
}

enum EmptyStateType {
    case noTransactions
    case noFilteredTransactions
    case noStats
    case noCategories
    
    var icon: String {
        switch self {
        case .noTransactions: return "chart.line.uptrend.xyaxis"
        case .noFilteredTransactions: return "line.3.horizontal.decrease.circle"
        case .noStats: return "chart.pie"
        case .noCategories: return "square.grid.2x2"
        }
    }
    
    var title: String {
        switch self {
        case .noTransactions: return "No Transactions Yet"
        case .noFilteredTransactions: return "No Matches Found"
        case .noStats: return "No Data Available"
        case .noCategories: return "No Categories"
        }
    }
    
    var message: String {
        switch self {
        case .noTransactions:
            return "Start tracking your finances by adding your first transaction"
        case .noFilteredTransactions:
            return "Try adjusting your filters or add new transactions"
        case .noStats:
            return "Add some transactions to see your spending insights"
        case .noCategories:
            return "Create categories to organize your transactions"
        }
    }
    
    var actionText: String? {
        switch self {
        case .noTransactions: return "Add Transaction"
        case .noFilteredTransactions: return nil
        case .noStats: return "Add Transaction"
        case .noCategories: return "Create Category"
        }
    }
    
    var action: (() -> Void)? {
        return nil // Will be set by parent view
    }
    
    var accentColor: Color {
        switch self {
        case .noTransactions: return Color.accentColor
        case .noFilteredTransactions: return .orange
        case .noStats: return .purple
        case .noCategories: return .blue
        }
    }
}
