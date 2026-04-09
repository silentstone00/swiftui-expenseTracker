//
//  SmartEmptyState.swift
//  expense_tracker
//

import SwiftUI

struct SmartEmptyState: View {
    let type: EmptyStateType
    var style: EmptyStateStyle = .row
    @State private var appeared = false

    var body: some View {
        switch style {
        case .row:    rowStyle
        case .centered: centeredStyle
        }
    }

    // MARK: - Row style (Home / AllTransactions — blends with TransactionRow cards)

    private var rowStyle: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(type.accentColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: type.icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(type.accentColor.opacity(0.7))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(type.title)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(.primaryText)
                Text(type.message)
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 22).fill(Color.cardBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.primaryText.opacity(0.07), lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white.opacity(0.4),  location: 0.0),
                            .init(color: .white.opacity(0.2),  location: 0.1),
                            .init(color: .white.opacity(0.05), location: 0.25),
                            .init(color: .white.opacity(0.0),  location: 0.43),
                            .init(color: .white.opacity(0.05), location: 0.46),
                            .init(color: .white.opacity(0.4),  location: 0.5),
                            .init(color: .white.opacity(0.2),  location: 0.6),
                            .init(color: .white.opacity(0.05), location: 0.75),
                            .init(color: .white.opacity(0.0),  location: 0.93),
                            .init(color: .white.opacity(0.2),  location: 0.97),
                            .init(color: .white.opacity(0.4),  location: 1.0),
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
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) { appeared = true }
        }
    }

    // MARK: - Centered style (Stats / Balance tab)

    private var centeredStyle: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                // Icon with dashed ring
                ZStack {
                    // Outer ring
                    Circle()
                        .strokeBorder(type.accentColor.opacity(0.18), lineWidth: 1)
                        .frame(width: 112, height: 112)

                    // Solid inner circle
                    Circle()
                        .fill(type.accentColor.opacity(0.08))
                        .frame(width: 72, height: 72)

                    Image(systemName: type.icon)
                        .font(.system(size: 26, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [type.accentColor, type.accentColor.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)

                // Text
                VStack(spacing: 10) {
                    Text(type.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)

                    Text(type.message)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.tertiaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 48)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.05)) {
                appeared = true
            }
        }
    }
}

// MARK: - Style

enum EmptyStateStyle {
    case row, centered
}

// MARK: - Type

enum EmptyStateType {
    case noTransactions, noFilteredTransactions, noStats, noCategories

    var icon: String {
        switch self {
        case .noTransactions:         return "tray"
        case .noFilteredTransactions: return "line.3.horizontal.decrease.circle"
        case .noStats:                return "chart.pie"
        case .noCategories:           return "square.grid.2x2"
        }
    }

    var title: String {
        switch self {
        case .noTransactions:         return "No Transactions Yet"
        case .noFilteredTransactions: return "No Matches Found"
        case .noStats:                return "No Data Yet"
        case .noCategories:           return "No Categories"
        }
    }

    var message: String {
        switch self {
        case .noTransactions:         return "Tap + to add your first transaction"
        case .noFilteredTransactions: return "Try adjusting your category filters"
        case .noStats:                return "Add transactions to see spending insights"
        case .noCategories:           return "Create categories to organise your transactions"
        }
    }

    var accentColor: Color {
        switch self {
        case .noTransactions:         return Color.accentColor
        case .noFilteredTransactions: return .orange
        case .noStats:                return .purple
        case .noCategories:           return .blue
        }
    }
}
