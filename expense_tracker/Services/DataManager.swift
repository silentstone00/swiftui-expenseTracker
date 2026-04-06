//
//  DataManager.swift
//  expense_tracker
//
//  Core Data persistence manager for transactions and categories
//

import Foundation
import CoreData

/// Singleton manager for Core Data operations
class DataManager {
    static let shared = DataManager()
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ExpenseTracker")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Core Data Saving
    
    func saveContext() throws {
        let context = viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - Transaction Operations
    
    /// Save a new transaction to Core Data
    func saveTransaction(id: UUID, amount: Decimal, type: String, categoryId: UUID, date: Date, note: String?) throws {
        let context = viewContext
        
        // Fetch the category
        let categoryFetch = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        categoryFetch.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
        
        guard let category = try context.fetch(categoryFetch).first else {
            throw DataManagerError.categoryNotFound
        }
        
        let transaction = TransactionEntity(context: context)
        transaction.id = id
        transaction.amount = amount as NSDecimalNumber
        transaction.type = type
        transaction.category = category
        transaction.date = date
        transaction.note = note
        transaction.createdAt = Date()
        transaction.updatedAt = Date()
        
        try saveContext()
    }
    
    /// Fetch all transactions sorted by date descending
    func fetchTransactions() throws -> [TransactionEntity] {
        let fetchRequest = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return try viewContext.fetch(fetchRequest)
    }
    
    /// Fetch transactions filtered by category
    func fetchTransactions(categoryId: UUID) throws -> [TransactionEntity] {
        let fetchRequest = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        fetchRequest.predicate = NSPredicate(format: "category.id == %@", categoryId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return try viewContext.fetch(fetchRequest)
    }
    
    /// Fetch transactions for a specific month
    func fetchTransactions(forMonth date: Date) throws -> [TransactionEntity] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            throw DataManagerError.invalidDate
        }
        
        let fetchRequest = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return try viewContext.fetch(fetchRequest)
    }
    
    /// Update an existing transaction
    func updateTransaction(id: UUID, amount: Decimal?, type: String?, categoryId: UUID?, date: Date?, note: String?) throws {
        let fetchRequest = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let transaction = try viewContext.fetch(fetchRequest).first else {
            throw DataManagerError.transactionNotFound
        }
        
        if let amount = amount {
            transaction.amount = amount as NSDecimalNumber
        }
        if let type = type {
            transaction.type = type
        }
        if let categoryId = categoryId {
            let categoryFetch = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
            categoryFetch.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
            
            guard let category = try viewContext.fetch(categoryFetch).first else {
                throw DataManagerError.categoryNotFound
            }
            transaction.category = category
        }
        if let date = date {
            transaction.date = date
        }
        if let note = note {
            transaction.note = note
        }
        
        transaction.updatedAt = Date()
        try saveContext()
    }
    
    /// Delete a transaction
    func deleteTransaction(id: UUID) throws {
        let fetchRequest = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let transaction = try viewContext.fetch(fetchRequest).first else {
            throw DataManagerError.transactionNotFound
        }
        
        viewContext.delete(transaction)
        try saveContext()
    }
    
    // MARK: - Category Operations
    
    /// Save a new category to Core Data
    func saveCategory(id: UUID, name: String, icon: String, color: String, isCustom: Bool) throws {
        let context = viewContext
        
        let category = CategoryEntity(context: context)
        category.id = id
        category.name = name
        category.icon = icon
        category.color = color
        category.isCustom = isCustom
        category.createdAt = Date()
        
        try saveContext()
    }
    
    /// Fetch all categories
    func fetchCategories() throws -> [CategoryEntity] {
        let fetchRequest = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isCustom", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        return try viewContext.fetch(fetchRequest)
    }
    
    /// Fetch only custom categories
    func fetchCustomCategories() throws -> [CategoryEntity] {
        let fetchRequest = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        fetchRequest.predicate = NSPredicate(format: "isCustom == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return try viewContext.fetch(fetchRequest)
    }
    
    /// Delete a category (only custom categories can be deleted)
    func deleteCategory(id: UUID) throws {
        let fetchRequest = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND isCustom == YES", id as CVarArg)
        
        guard let category = try viewContext.fetch(fetchRequest).first else {
            throw DataManagerError.categoryNotFound
        }
        
        viewContext.delete(category)
        try saveContext()
    }
    
    // MARK: - Utility Methods
    
    /// Delete all data (useful for testing)
    func deleteAllData() throws {
        let entities = ["TransactionEntity", "CategoryEntity"]
        
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: viewContext)
        }
        
        try saveContext()
    }
}

// MARK: - Error Types

enum DataManagerError: LocalizedError {
    case transactionNotFound
    case categoryNotFound
    case invalidDate
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .transactionNotFound:
            return "Transaction not found"
        case .categoryNotFound:
            return "Category not found"
        case .invalidDate:
            return "Invalid date provided"
        case .saveFailed:
            return "Failed to save data"
        }
    }
}
