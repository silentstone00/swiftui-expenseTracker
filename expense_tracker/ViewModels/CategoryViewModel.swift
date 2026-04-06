//
//  CategoryViewModel.swift
//  expense_tracker
//
//  ViewModel managing category state and business logic
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CategoryViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var categories: [Category] = []
    @Published var customCategories: [Category] = []
    
    // MARK: - Private Properties
    
    private let dataManager: DataManager
    
    // MARK: - Initialization
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Data Loading
    
    /// Load all categories (predefined + custom) from Core Data
    func loadCategories() async {
        do {
            // Load custom categories from Core Data
            let customEntities = try dataManager.fetchCustomCategories()
            let loadedCustomCategories = customEntities.compactMap { entity in
                convertEntityToCategory(entity)
            }
            
            // Combine predefined and custom categories
            customCategories = loadedCustomCategories
            categories = Category.predefined + loadedCustomCategories
        } catch {
            print("Error loading categories: \(error)")
            // Fall back to predefined categories only
            categories = Category.predefined
            customCategories = []
        }
    }
    
    // MARK: - Category Operations
    
    /// Add a new custom category
    func addCustomCategory(_ category: Category) async throws {
        // Ensure the category is marked as custom
        var customCategory = category
        customCategory.isCustom = true
        
        // Save to Core Data
        try dataManager.saveCategory(
            id: customCategory.id,
            name: customCategory.name,
            icon: customCategory.icon,
            color: customCategory.color.rawValue,
            isCustom: true
        )
        
        // Reload categories
        await loadCategories()
    }
    
    /// Delete a custom category
    func deleteCustomCategory(_ category: Category) async throws {
        // Only allow deletion of custom categories
        guard category.isCustom else {
            throw CategoryError.cannotDeletePredefinedCategory
        }
        
        // Delete from Core Data
        try dataManager.deleteCategory(id: category.id)
        
        // Reload categories
        await loadCategories()
    }
    
    // MARK: - Helper Methods
    
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

// MARK: - Error Types

enum CategoryError: LocalizedError {
    case cannotDeletePredefinedCategory
    
    var errorDescription: String? {
        switch self {
        case .cannotDeletePredefinedCategory:
            return "Cannot delete predefined categories"
        }
    }
}
