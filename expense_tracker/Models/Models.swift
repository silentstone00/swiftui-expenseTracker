//
//  Models.swift
//  expense_tracker
//
//  Swift model structs for transactions, categories, and summaries
//

import Foundation
import SwiftUI

// MARK: - Transaction Type

/// Enum representing whether a transaction is income or expense
enum TransactionType: String, Codable, CaseIterable {
    case income
    case expense
}

// MARK: - Category Color

/// Enum representing predefined colors for categories
enum CategoryColor: String, Codable, CaseIterable {
    case blue
    case green
    case red
    case orange
    case purple
    case pink
    case yellow
    case gray
    
    /// Maps enum case to SwiftUI Color
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .red: return .red
        case .orange: return .orange
        case .purple: return .purple
        case .pink: return .pink
        case .yellow: return .yellow
        case .gray: return .gray
        }
    }
}

// MARK: - Category

/// Model representing a transaction category with icon and color
struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String // SF Symbol name
    var color: CategoryColor
    var isCustom: Bool
    
    init(id: UUID = UUID(), name: String, icon: String, color: CategoryColor, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.isCustom = isCustom
    }
    
    // MARK: - Income Default Category

    /// Stable income category — fixed UUID so Core Data never creates duplicates
    static let income = Category(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Income",
        icon: "indianrupeesign.circle.fill",
        color: .green,
        isCustom: false
    )

    // MARK: - Predefined Categories

    /// Predefined categories available to all users — fixed UUIDs so IDs are stable across launches
    static let predefined: [Category] = [
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!, name: "Food", icon: "fork.knife", color: .orange, isCustom: false),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!, name: "Transport", icon: "car.fill", color: .blue, isCustom: false),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!, name: "Shopping", icon: "cart.fill", color: .purple, isCustom: false),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000040")!, name: "Entertainment", icon: "tv.fill", color: .pink, isCustom: false),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000050")!, name: "Bills", icon: "doc.text.fill", color: .red, isCustom: false),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000060")!, name: "Salary", icon: "indianrupeesign.circle.fill", color: .green, isCustom: false),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000070")!, name: "Other", icon: "ellipsis.circle.fill", color: .gray, isCustom: false)
    ]
}

// MARK: - Transaction

/// Model representing a financial transaction (income or expense)
struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    var amount: Decimal
    var type: TransactionType
    var category: Category
    var date: Date
    var note: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        amount: Decimal,
        type: TransactionType,
        category: Category,
        date: Date = Date(),
        note: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.date = date
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Monthly Summary

/// Model representing financial summary for a specific month
struct MonthlySummary {
    let month: Date
    let totalIncome: Decimal
    let totalExpenses: Decimal
    let transactionCount: Int
    let categoryBreakdown: [UUID: Decimal]     // keyed by category ID — UUID is nonisolated Hashable
    
    /// Computed balance (income - expenses)
    var balance: Decimal {
        return totalIncome - totalExpenses
    }
    
    init(
        month: Date,
        totalIncome: Decimal = 0,
        totalExpenses: Decimal = 0,
        transactionCount: Int = 0,
        categoryBreakdown: [UUID: Decimal] = [:]
    ) {
        self.month = month
        self.totalIncome = totalIncome
        self.totalExpenses = totalExpenses
        self.transactionCount = transactionCount
        self.categoryBreakdown = categoryBreakdown
    }
}


