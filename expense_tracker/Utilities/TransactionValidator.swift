//
//  TransactionValidator.swift
//  expense_tracker
//
//  Validation logic for transaction data
//

import Foundation

// MARK: - Validation Error

/// Enum representing validation errors for transactions
enum ValidationError: LocalizedError {
    case invalidAmount
    case missingCategory
    case futureDateNotAllowed
    case noteTooLong
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Amount must be greater than zero"
        case .missingCategory:
            return "Please select a category"
        case .futureDateNotAllowed:
            return "Date cannot be in the future"
        case .noteTooLong:
            return "Note cannot exceed 200 characters"
        }
    }
}

// MARK: - Validation Result

/// Enum representing the result of validation
enum ValidationResult {
    case valid
    case invalid([ValidationError])
    
    var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }
    
    var errors: [ValidationError] {
        if case .invalid(let errors) = self {
            return errors
        }
        return []
    }
}

// MARK: - Transaction Validator

/// Validator for transaction data
struct TransactionValidator {
    /// Validates a transaction and returns validation result
    /// - Parameter transaction: The transaction to validate
    /// - Returns: ValidationResult indicating if valid or containing errors
    static func validate(_ transaction: Transaction) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // Validate amount is positive and numeric
        if transaction.amount <= 0 {
            errors.append(.invalidAmount)
        }
        
        // Validate date is not in future
        if transaction.date > Date() {
            errors.append(.futureDateNotAllowed)
        }
        
        // Validate note length (if present)
        if let note = transaction.note, note.count > 200 {
            errors.append(.noteTooLong)
        }
        
        // Return result
        if errors.isEmpty {
            return .valid
        } else {
            return .invalid(errors)
        }
    }
}
