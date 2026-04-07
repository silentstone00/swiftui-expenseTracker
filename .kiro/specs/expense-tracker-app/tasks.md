# Implementation Plan: Expense Tracker App

## Overview

This implementation plan builds a SwiftUI-based iOS expense tracker with MVVM architecture, Core Data persistence, and property-based testing. The app features transaction management, category organization, monthly financial summaries, and a modern fintech-style UI with dark/light theme support and smooth animations.

## Tasks

- [x] 1. Set up project structure and Core Data stack
  - Configure Core Data persistent container with TransactionEntity and CategoryEntity
  - Create Core Data model file (.xcdatamodeld) with proper relationships and indexes
  - Implement DataManager singleton with save, fetch, and delete operations
  - Add Swift-Check package dependency for property-based testing
  - _Requirements: 8.1, 8.2, 8.4_

- [ ]* 1.1 Write property test for Core Data initialization
  - **Property: Core Data stack initializes successfully**
  - **Validates: Requirements 8.2**

- [ ] 2. Implement core models and validation
  - [x] 2.1 Create Transaction, Category, and MonthlySummary models
    - Define Transaction struct with id, amount, type, category, date, note, timestamps
    - Define Category struct with predefined categories (Food, Transport, Shopping, etc.)
    - Define TransactionType enum (income/expense) and CategoryColor enum
    - Implement Identifiable, Codable, and Hashable conformance
    - _Requirements: 1.1, 2.1, 2.2_

  - [x] 2.2 Implement TransactionValidator with validation logic
    - Validate amount is positive and numeric
    - Validate category is selected
    - Validate date is not in future
    - Return ValidationResult with specific ValidationError cases
    - _Requirements: 1.3, 1.4_

  - [ ]* 2.3 Write property test for invalid amount validation
    - **Property 2: Invalid Amount Validation**
    - **Validates: Requirements 1.3**

  - [ ]* 2.4 Write property test for transaction persistence round-trip
    - **Property 1: Transaction Persistence Round-Trip**
    - **Validates: Requirements 1.6**

- [ ] 3. Implement ViewModels with business logic
  - [x] 3.1 Create TransactionViewModel
    - Implement @Published properties for transactions, filteredTransactions, selectedCategory, monthlySummary
    - Implement addTransaction, updateTransaction, deleteTransaction methods
    - Implement loadTransactions with async/await
    - Implement filterByCategory logic
    - Implement calculateMonthlySummary with income, expense, and balance calculations
    - _Requirements: 1.2, 1.5, 2.4, 3.1, 3.2, 3.3_

  - [ ]* 3.2 Write property test for transaction list sorting
    - **Property 3: Transaction List Sorting**
    - **Validates: Requirements 1.5**

  - [ ]* 3.3 Write property test for category filtering
    - **Property 4: Category Filtering**
    - **Validates: Requirements 2.4**

  - [ ]* 3.4 Write property test for monthly income calculation
    - **Property 6: Monthly Income Calculation**
    - **Validates: Requirements 3.1**

  - [ ]* 3.5 Write property test for monthly expense calculation
    - **Property 7: Monthly Expense Calculation**
    - **Validates: Requirements 3.2**

  - [ ]* 3.6 Write property test for balance calculation invariant
    - **Property 8: Balance Calculation Invariant**
    - **Validates: Requirements 3.3**

  - [x] 3.7 Create CategoryViewModel
    - Implement @Published properties for categories and customCategories
    - Implement loadCategories to load predefined and custom categories
    - Implement addCustomCategory and deleteCustomCategory methods
    - _Requirements: 2.1, 2.3_

  - [ ]* 3.8 Write property test for custom category persistence
    - **Property 5: Custom Category Persistence**
    - **Validates: Requirements 2.3**

  - [x] 3.9 Create ThemeViewModel
    - Implement @Published isDarkMode property
    - Implement @AppStorage for theme preference persistence
    - Implement toggleTheme and applyTheme methods
    - _Requirements: 4.1, 4.2, 4.3_

  - [ ]* 3.10 Write property test for theme preference persistence
    - **Property 9: Theme Preference Persistence**
    - **Validates: Requirements 4.2**

- [ ] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement UI components and views
  - [x] 5.1 Create BalanceCard component
    - Implement gradient background with LinearGradient
    - Display totalIncome, totalExpenses, and balance with proper formatting
    - Add animated number counters with fade-in effect
    - Support both dark and light theme color schemes
    - _Requirements: 3.5, 4.4, 4.5, 6.4_

  - [x] 5.2 Create HomeView
    - Display BalanceCard with monthly summary
    - Show recent transactions list (last 5-10)
    - Add quick action button to navigate to add transaction
    - Implement pull-to-refresh for data reload
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 5.1_

  - [x] 5.3 Create TransactionListView
    - Display scrollable list of all transactions
    - Group transactions by date (Today, Yesterday, This Week, etc.)
    - Implement category filter chips at top
    - Add swipe actions for delete and edit
    - Show empty state when no transactions exist
    - _Requirements: 1.5, 2.4, 9.1, 9.3_

  - [x] 5.4 Create AddTransactionView
    - Implement form with amount TextField (numeric keyboard)
    - Add transaction type toggle (Income/Expense) with Picker
    - Add category picker with icons and colors
    - Add DatePicker defaulting to today
    - Add optional note TextField with character limit
    - Implement save button with validation
    - Show validation error messages inline
    - Dismiss keyboard on tap outside
    - _Requirements: 1.1, 1.3, 1.4, 7.1, 7.2, 7.3_

  - [ ]* 5.5 Write unit tests for view validation feedback
    - Test validation error messages display correctly
    - Test form fields show appropriate keyboard types
    - Test empty state messages appear when no data
    - _Requirements: 1.3, 1.4, 7.1, 9.1, 9.2_

- [ ] 6. Implement navigation and tab structure
  - [x] 6.1 Create TabView with bottom navigation
    - Add Home tab with SF Symbol "house.fill"
    - Add Transactions tab with SF Symbol "list.bullet"
    - Add Add Transaction tab with SF Symbol "plus.circle.fill"
    - Implement tab selection state and highlighting
    - Add smooth transition animations between tabs
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [ ]* 6.2 Write UI tests for navigation flows
    - Test user can navigate between all tabs
    - Test active tab is highlighted correctly
    - Test transitions animate smoothly
    - _Requirements: 5.2, 5.3, 5.4_

- [ ] 7. Implement animations and micro-interactions
  - [x] 7.1 Add screen transition animations
    - Implement slide transitions with 200-400ms duration
    - Add fade-in animations for BalanceCard appearance
    - Animate transaction list items on appear
    - _Requirements: 6.1, 6.4_

  - [x] 7.2 Add interaction feedback animations
    - Implement scale animation on button taps
    - Add opacity feedback on card taps
    - Animate success confirmation after adding transaction
    - Add spring animation to swipe actions
    - _Requirements: 6.2, 6.3_

  - [ ]* 7.3 Write UI tests for animation presence
    - Test confirmation animation appears after transaction added
    - Test buttons provide visual feedback on tap
    - _Requirements: 6.2, 6.3_

- [ ] 8. Implement data persistence operations
  - [x] 8.1 Wire DataManager to ViewModels
    - Connect TransactionViewModel to DataManager for CRUD operations
    - Connect CategoryViewModel to DataManager for category persistence
    - Implement immediate save on transaction add/update/delete
    - Implement data loading on app launch
    - _Requirements: 8.1, 8.2, 8.3_

  - [ ]* 8.2 Write property test for transaction deletion
    - **Property 10: Transaction Deletion**
    - **Validates: Requirements 8.3**

  - [ ]* 8.3 Write integration tests for persistence
    - Test transactions persist after app restart
    - Test theme preference loads on launch
    - Test monthly summary updates when month changes
    - _Requirements: 8.1, 8.2, 8.4, 3.4, 4.3_

- [ ] 9. Implement error handling and empty states
  - [x] 9.1 Add validation error messages
    - Display "Amount must be greater than zero" for invalid amounts
    - Display "Please select a category" when category missing
    - Display "Date cannot be in the future" for future dates
    - Display "Note cannot exceed 200 characters" for long notes
    - _Requirements: 1.3, 1.4_

  - [x] 9.2 Add empty state views
    - Create empty state for no transactions with illustration and CTA
    - Create empty state for no filtered results
    - Create empty state for monthly summary with zero values
    - _Requirements: 9.1, 9.2, 9.3_

  - [x] 9.3 Add Core Data error handling
    - Implement try-catch for save operations with user-friendly messages
    - Implement try-catch for fetch operations with retry mechanism
    - Log errors for debugging without exposing to user
    - _Requirements: 8.1, 8.2_

- [ ] 10. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. Polish UI and accessibility
  - [x] 11.1 Implement theme support
    - Apply consistent color schemes for dark and light modes
    - Update gradient colors based on theme
    - Ensure text contrast meets accessibility standards
    - Test all views in both themes
    - _Requirements: 4.1, 4.4, 4.5_

  - [ ] 11.2 Add accessibility support
    - Add VoiceOver labels to all interactive elements
    - Support Dynamic Type for text scaling
    - Ensure minimum touch target sizes (44x44 points)
    - Test with VoiceOver enabled
    - _Requirements: 4.5_

  - [x] 11.3 Add app icon and launch screen
    - Create app icon asset in multiple sizes
    - Design launch screen matching app theme
    - _Requirements: 10.4_

- [ ] 12. Final integration and testing
  - [ ] 12.1 Wire all components together
    - Connect all views to ViewModels with proper bindings
    - Ensure data flows correctly from Core Data through ViewModels to Views
    - Test complete user flows end-to-end
    - _Requirements: All_

  - [ ]* 12.2 Run full test suite
    - Execute all property-based tests with 100 iterations
    - Execute all unit tests
    - Execute all UI tests
    - Execute all integration tests
    - Verify test coverage meets goals (>80% for ViewModels)
    - _Requirements: All_

  - [x] 12.3 Build for TestFlight deployment
    - Configure build settings for iOS 15.0+ support
    - Archive build for distribution
    - Upload to TestFlight for beta testing
    - _Requirements: 10.1, 10.2, 10.3_

- [ ] 13. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property-based tests use Swift-Check with minimum 100 iterations
- All Core Data operations use async/await for better performance
- SwiftUI previews should be added to all views for rapid development
- Checkpoints ensure incremental validation and user feedback opportunities
