//
//  TransactionViewModel.swift
//  expense_tracker
//
//  ViewModel managing transaction state and business logic
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TransactionViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var selectedCategory: Category?
    @Published var monthlySummary: MonthlySummary?
    
    // MARK: - Private Properties
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        
        // Setup reactive filtering
        setupCategoryFiltering()
    }
    
    // MARK: - Setup
    
    private func setupCategoryFiltering() {
        // Automatically update filtered transactions when category selection changes
        $selectedCategory
            .combineLatest($transactions)
            .map { [weak self] category, transactions in
                self?.filterTransactions(transactions, by: category) ?? []
            }
            .assign(to: &$filteredTransactions)
    }
    
    // MARK: - Transaction Operations
    
    /// Add a new transaction
    func addTransaction(_ transaction: Transaction) async throws {
        // Validate transaction
        let validationResult = TransactionValidator.validate(transaction)
        guard validationResult.isValid else {
            throw validationResult.errors.first ?? ValidationError.invalidAmount
        }
        
        // Ensure category exists in Core Data
        try await ensureCategoryExists(transaction.category)
        
        // Save to Core Data
        try dataManager.saveTransaction(
            id: transaction.id,
            amount: transaction.amount,
            type: transaction.type.rawValue,
            categoryId: transaction.category.id,
            date: transaction.date,
            note: transaction.note
        )
        
        // Reload transactions
        await loadTransactions()
    }
    
    /// Update an existing transaction
    func updateTransaction(_ transaction: Transaction) async throws {
        // Validate transaction
        let validationResult = TransactionValidator.validate(transaction)
        guard validationResult.isValid else {
            throw validationResult.errors.first ?? ValidationError.invalidAmount
        }
        
        // Ensure category exists in Core Data
        try await ensureCategoryExists(transaction.category)
        
        // Update in Core Data
        try dataManager.updateTransaction(
            id: transaction.id,
            amount: transaction.amount,
            type: transaction.type.rawValue,
            categoryId: transaction.category.id,
            date: transaction.date,
            note: transaction.note
        )
        
        // Reload transactions
        await loadTransactions()
    }
    
    /// Delete a transaction
    func deleteTransaction(_ transaction: Transaction) async throws {
        try dataManager.deleteTransaction(id: transaction.id)
        
        // Reload transactions
        await loadTransactions()
    }
    
    // MARK: - Data Loading
    
    /// Load all transactions from Core Data
    func loadTransactions() async {
        do {
            let entities = try dataManager.fetchTransactions()
            transactions = entities.compactMap { entity in
                convertEntityToTransaction(entity)
            }
            
            // Recalculate monthly summary for current month
            monthlySummary = calculateMonthlySummary(for: Date())
        } catch {
            print("Error loading transactions: \(error)")
            transactions = []
        }
    }
    
    // MARK: - Filtering
    
    /// Filter transactions by category
    func filterByCategory(_ category: Category?) {
        selectedCategory = category
        // Filtering happens automatically via Combine pipeline
    }
    
    private func filterTransactions(_ transactions: [Transaction], by category: Category?) -> [Transaction] {
        guard let category = category else {
            return transactions
        }
        
        return transactions.filter { $0.category.id == category.id }
    }
    
    // MARK: - Monthly Summary
    
    /// Calculate monthly summary for a given month
    func calculateMonthlySummary(for month: Date) -> MonthlySummary {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return MonthlySummary(month: month)
        }
        
        // Filter transactions for the month
        let monthTransactions = transactions.filter { transaction in
            transaction.date >= startOfMonth && transaction.date <= endOfMonth
        }
        
        // Calculate totals
        var totalIncome: Decimal = 0
        var totalExpenses: Decimal = 0
        var categoryBreakdown: [Category: Decimal] = [:]
        
        for transaction in monthTransactions {
            switch transaction.type {
            case .income:
                totalIncome += transaction.amount
            case .expense:
                totalExpenses += transaction.amount
            }
            
            // Update category breakdown (expenses only)
            if transaction.type == .expense {
                let currentAmount = categoryBreakdown[transaction.category] ?? 0
                categoryBreakdown[transaction.category] = currentAmount + transaction.amount
            }
        }
        
        return MonthlySummary(
            month: startOfMonth,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            transactionCount: monthTransactions.count,
            categoryBreakdown: categoryBreakdown
        )
    }
    
    // MARK: - Helper Methods
    
    private func ensureCategoryExists(_ category: Category) async throws {
        let categories = try dataManager.fetchCategories()
        let exists = categories.contains { $0.id == category.id }
        
        if !exists {
            try dataManager.saveCategory(
                id: category.id,
                name: category.name,
                icon: category.icon,
                color: category.color.rawValue,
                isCustom: category.isCustom
            )
        }
    }
    
    private func convertEntityToTransaction(_ entity: TransactionEntity) -> Transaction? {
        guard let id = entity.id,
              let amount = entity.amount as Decimal?,
              let typeString = entity.type,
              let type = TransactionType(rawValue: typeString),
              let categoryEntity = entity.category,
              let date = entity.date,
              let createdAt = entity.createdAt,
              let updatedAt = entity.updatedAt else {
            return nil
        }
        
        guard let category = convertEntityToCategory(categoryEntity) else {
            return nil
        }
        
        return Transaction(
            id: id,
            amount: amount,
            type: type,
            category: category,
            date: date,
            note: entity.note,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private func convertEntityToCategory(_ entity: CategoryEntity) -> Category? {
        guard let id = entity.id,
              let name = entity.name,
              let icon = entity.icon,
              let colorString = entity.color,
              let color = CategoryColor(rawValue: colorString) else {
            return nil
        }
        
        return Category(
            id: id,
            name: name,
            icon: icon,
            color: color,
            isCustom: entity.isCustom
        )
    }
}
