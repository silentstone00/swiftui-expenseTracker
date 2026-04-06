# Design Document: Expense Tracker App

## Overview

The Expense Tracker App is a SwiftUI-based iOS application that enables users to track income and expenses with a modern fintech-style interface. The app features local data persistence, category-based organization, monthly financial summaries, and support for both dark and light themes with smooth animations throughout.

The application follows the MVVM (Model-View-ViewModel) architecture pattern, leveraging SwiftUI's declarative syntax and Combine framework for reactive data flow. All data is stored locally using Core Data for robust persistence and query capabilities.

Key design principles:
- **Simplicity**: Clean, intuitive interface focused on core financial tracking
- **Performance**: Smooth 60fps animations and instant data access
- **Accessibility**: Full VoiceOver support and dynamic type scaling
- **Maintainability**: Clear separation of concerns with MVVM architecture

## Architecture

### High-Level Architecture

The application follows a layered MVVM architecture:

```
┌─────────────────────────────────────────┐
│           Views (SwiftUI)               │
│  - HomeView, TransactionListView, etc.  │
└──────────────┬──────────────────────────┘
               │ Bindings
┌──────────────▼──────────────────────────┐
│         ViewModels                      │
│  - TransactionViewModel                 │
│  - CategoryViewModel                    │
│  - ThemeViewModel                       │
└──────────────┬──────────────────────────┘
               │ Business Logic
┌──────────────▼──────────────────────────┐
│         Models & Services               │
│  - Transaction, Category (Models)       │
│  - DataManager (Core Data)              │
│  - ThemeManager                         │
└─────────────────────────────────────────┘
```

### Architecture Layers

1. **View Layer (SwiftUI)**
   - Declarative UI components
   - Consumes ViewModels via @StateObject and @ObservedObject
   - Handles user interactions and navigation
   - Implements animations and transitions

2. **ViewModel Layer**
   - Manages view state and business logic
   - Transforms model data for presentation
   - Handles user actions and validation
   - Publishes state changes via @Published properties

3. **Model & Service Layer**
   - Core Data models for persistence
   - Data access and manipulation logic
   - Theme management and preferences
   - Validation and business rules

### Navigation Structure

Bottom tab navigation with three primary tabs:

```
TabView
├── Home Tab (Dashboard)
│   └── Monthly summary, recent transactions
├── Transactions Tab
│   └── Full transaction list with filtering
└── Add Tab
    └── Transaction form (income/expense)
```

## Components and Interfaces

### Core Models

#### Transaction Model
```swift
struct Transaction: Identifiable, Codable {
    let id: UUID
    var amount: Decimal
    var type: TransactionType // .income or .expense
    var category: Category
    var date: Date
    var note: String?
    var createdAt: Date
    var updatedAt: Date
}

enum TransactionType: String, Codable {
    case income
    case expense
}
```

#### Category Model
```swift
struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String // SF Symbol name
    var color: CategoryColor
    var isCustom: Bool
    
    static let predefined: [Category] // Food, Transport, etc.
}

enum CategoryColor: String, Codable {
    case blue, green, red, orange, purple, pink, yellow
    
    var color: Color { /* maps to Color values */ }
}
```

#### MonthlySummary Model
```swift
struct MonthlySummary {
    let month: Date
    let totalIncome: Decimal
    let totalExpenses: Decimal
    var balance: Decimal { totalIncome - totalExpenses }
    let transactionCount: Int
    let categoryBreakdown: [Category: Decimal]
}
```

### ViewModels

#### TransactionViewModel
```swift
@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var selectedCategory: Category?
    @Published var monthlySummary: MonthlySummary?
    
    private let dataManager: DataManager
    
    func addTransaction(_ transaction: Transaction) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(_ transaction: Transaction) async throws
    func loadTransactions() async
    func filterByCategory(_ category: Category?)
    func calculateMonthlySummary(for month: Date) -> MonthlySummary
}
```

#### CategoryViewModel
```swift
@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var customCategories: [Category] = []
    
    private let dataManager: DataManager
    
    func loadCategories() async
    func addCustomCategory(_ category: Category) async throws
    func deleteCustomCategory(_ category: Category) async throws
}
```

#### ThemeViewModel
```swift
@MainActor
class ThemeViewModel: ObservableObject {
    @Published var isDarkMode: Bool = false
    @AppStorage("userThemePreference") private var themePreference: String = "system"
    
    func toggleTheme()
    func applyTheme(_ theme: ThemePreference)
}

enum ThemePreference: String {
    case light, dark, system
}
```

### Services

#### DataManager
```swift
class DataManager {
    static let shared = DataManager()
    private let persistentContainer: NSPersistentContainer
    
    func saveTransaction(_ transaction: Transaction) throws
    func fetchTransactions() throws -> [Transaction]
    func deleteTransaction(_ transaction: Transaction) throws
    func saveCategory(_ category: Category) throws
    func fetchCategories() throws -> [Category]
}
```

### Key Views

#### HomeView
- Displays Balance_Card with gradient showing monthly summary
- Shows recent transactions (last 5-10)
- Quick action button to add transaction
- Animated number counters for financial values

#### TransactionListView
- Scrollable list of all transactions
- Grouped by date (Today, Yesterday, This Week, etc.)
- Swipeable rows for delete/edit actions
- Category filter chips at top
- Empty state when no transactions exist

#### AddTransactionView
- Form with amount input (numeric keyboard)
- Transaction type toggle (Income/Expense)
- Category picker with icons
- Date picker (defaults to today)
- Optional note field
- Save button with validation
- Keyboard dismissal on tap outside

#### Balance_Card Component
```swift
struct BalanceCard: View {
    let summary: MonthlySummary
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // Gradient background
        // Animated income, expense, balance values
        // Month selector
    }
}
```

### Validation Logic

#### TransactionValidator
```swift
struct TransactionValidator {
    static func validate(_ transaction: Transaction) -> ValidationResult {
        // Amount must be positive
        // Category must be selected
        // Date cannot be in future
        // Note length limit (optional)
    }
}

enum ValidationResult {
    case valid
    case invalid([ValidationError])
}

enum ValidationError: LocalizedError {
    case invalidAmount
    case missingCategory
    case futureDateNotAllowed
    case noteTooLong
}
```

## Data Models

### Core Data Schema

#### TransactionEntity
```
TransactionEntity
├── id: UUID (Primary Key)
├── amount: Decimal
├── type: String (income/expense)
├── categoryId: UUID (Foreign Key)
├── date: Date
├── note: String?
├── createdAt: Date
└── updatedAt: Date

Indexes: date (DESC), categoryId, type
```

#### CategoryEntity
```
CategoryEntity
├── id: UUID (Primary Key)
├── name: String
├── icon: String
├── color: String
├── isCustom: Bool
└── createdAt: Date

Indexes: name, isCustom
```

### Data Flow

1. **Adding Transaction**:
   - User fills form → ViewModel validates → DataManager saves to Core Data → ViewModel updates @Published array → View refreshes

2. **Loading Transactions**:
   - View appears → ViewModel fetches from DataManager → Core Data query → Transform to models → Update @Published array → View renders

3. **Monthly Summary Calculation**:
   - ViewModel filters transactions by current month → Reduces to totals → Creates MonthlySummary → Publishes to view

### Predefined Categories

```swift
extension Category {
    static let predefined: [Category] = [
        Category(name: "Food", icon: "fork.knife", color: .orange, isCustom: false),
        Category(name: "Transport", icon: "car.fill", color: .blue, isCustom: false),
        Category(name: "Shopping", icon: "cart.fill", color: .purple, isCustom: false),
        Category(name: "Entertainment", icon: "tv.fill", color: .pink, isCustom: false),
        Category(name: "Bills", icon: "doc.text.fill", color: .red, isCustom: false),
        Category(name: "Salary", icon: "dollarsign.circle.fill", color: .green, isCustom: false),
        Category(name: "Other", icon: "ellipsis.circle.fill", color: .gray, isCustom: false)
    ]
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Transaction Persistence Round-Trip

*For any* valid transaction with amount, category, date, and optional note, saving the transaction to local storage and then loading it back SHALL produce an equivalent transaction with the same id, amount, type, category, date, and note values.

**Validates: Requirements 1.6**

### Property 2: Invalid Amount Validation

*For any* transaction with an amount that is negative, zero, or non-numeric, the validation logic SHALL reject the transaction and return an appropriate validation error.

**Validates: Requirements 1.3**

### Property 3: Transaction List Sorting

*For any* list of transactions with varying dates, retrieving the transaction list SHALL return transactions sorted by date in descending order (most recent first).

**Validates: Requirements 1.5**

### Property 4: Category Filtering

*For any* selected category and any list of transactions, filtering transactions by that category SHALL return only transactions where the transaction's category matches the selected category.

**Validates: Requirements 2.4**

### Property 5: Custom Category Persistence

*For any* custom category with name, icon, and color, saving the category to local storage SHALL make it available for future transactions and persist across app launches.

**Validates: Requirements 2.3**

### Property 6: Monthly Income Calculation

*For any* set of income transactions within a given month, the monthly summary's total income SHALL equal the sum of all income transaction amounts for that month.

**Validates: Requirements 3.1**

### Property 7: Monthly Expense Calculation

*For any* set of expense transactions within a given month, the monthly summary's total expenses SHALL equal the sum of all expense transaction amounts for that month.

**Validates: Requirements 3.2**

### Property 8: Balance Calculation Invariant

*For any* set of transactions in a given month, the monthly summary's balance SHALL always equal (total income - total expenses), maintaining the fundamental accounting equation.

**Validates: Requirements 3.3**

### Property 9: Theme Preference Persistence

*For any* theme preference (light, dark, or system), saving the preference SHALL persist it to local storage and make it available when the application launches.

**Validates: Requirements 4.2**

### Property 10: Transaction Deletion

*For any* transaction that exists in local storage, deleting the transaction SHALL remove it permanently such that subsequent queries for that transaction return no results.

**Validates: Requirements 8.3**

## Error Handling

### Validation Errors

The application implements comprehensive validation with user-friendly error messages:

**Amount Validation**
- Error: "Amount must be greater than zero"
- Trigger: User enters negative or zero amount
- Recovery: Clear error when valid amount entered

**Category Validation**
- Error: "Please select a category"
- Trigger: User attempts to save without selecting category
- Recovery: Error clears when category selected

**Date Validation**
- Error: "Date cannot be in the future"
- Trigger: User selects future date
- Recovery: Reset to today's date

**Note Length Validation**
- Error: "Note cannot exceed 200 characters"
- Trigger: User enters note longer than limit
- Recovery: Truncate or show character count

### Persistence Errors

**Core Data Save Failure**
- Error: "Unable to save transaction. Please try again."
- Trigger: Core Data save operation fails
- Recovery: Retry mechanism with exponential backoff
- Logging: Log error details for debugging

**Core Data Fetch Failure**
- Error: "Unable to load transactions. Please restart the app."
- Trigger: Core Data fetch operation fails
- Recovery: Show empty state with retry button
- Logging: Log error details for debugging

**Data Corruption**
- Error: "Data integrity issue detected. Some transactions may not display correctly."
- Trigger: Invalid data detected during fetch
- Recovery: Skip corrupted records, log for investigation
- Logging: Detailed error logging with stack trace

### Network Errors (Future Enhancement)

While the current version is offline-only, the architecture supports future cloud sync:

**Sync Failure**
- Error: "Unable to sync with cloud. Changes saved locally."
- Trigger: Network unavailable during sync
- Recovery: Queue changes for later sync
- User Action: Manual retry button

### UI Error States

**Empty States**
- No transactions: "No transactions yet. Tap + to add your first transaction."
- No filtered results: "No transactions found for this category."
- No custom categories: "Create custom categories to organize your transactions."

**Loading States**
- Show skeleton screens during data loading
- Timeout after 5 seconds with error message
- Pull-to-refresh for manual reload

## Testing Strategy

### Overview

The testing strategy employs a dual approach combining property-based testing for business logic and example-based testing for UI components and integration points.

### Property-Based Testing

**Framework**: Swift-Check (Swift port of QuickCheck)

**Configuration**:
- Minimum 100 iterations per property test
- Custom generators for Transaction, Category, and Date ranges
- Shrinking enabled for minimal failing examples

**Property Test Implementation**:

Each correctness property will be implemented as a property-based test with appropriate generators:

1. **Transaction Persistence Round-Trip** (Property 1)
   - Generator: Random transactions with valid amounts, categories, dates, optional notes
   - Test: save(transaction) → load(transaction.id) → verify equivalence
   - Tag: `Feature: expense-tracker-app, Property 1: For any valid transaction, saving then loading SHALL produce equivalent data`

2. **Invalid Amount Validation** (Property 2)
   - Generator: Invalid amounts (negative, zero, extremely large values)
   - Test: validate(transaction) → verify returns error
   - Tag: `Feature: expense-tracker-app, Property 2: For any invalid amount, validation SHALL reject with error`

3. **Transaction List Sorting** (Property 3)
   - Generator: Random lists of transactions with varying dates
   - Test: fetchTransactions() → verify sorted by date descending
   - Tag: `Feature: expense-tracker-app, Property 3: For any transaction list, results SHALL be sorted by date descending`

4. **Category Filtering** (Property 4)
   - Generator: Random transaction lists with various categories
   - Test: filter(category) → verify all results match category
   - Tag: `Feature: expense-tracker-app, Property 4: For any category filter, results SHALL only contain matching transactions`

5. **Custom Category Persistence** (Property 5)
   - Generator: Random custom categories with names, icons, colors
   - Test: save(category) → load() → verify category exists
   - Tag: `Feature: expense-tracker-app, Property 5: For any custom category, saving SHALL persist across launches`

6. **Monthly Income Calculation** (Property 6)
   - Generator: Random income transactions within a month
   - Test: calculateSummary() → verify totalIncome equals sum of amounts
   - Tag: `Feature: expense-tracker-app, Property 6: For any income transactions, total SHALL equal sum of amounts`

7. **Monthly Expense Calculation** (Property 7)
   - Generator: Random expense transactions within a month
   - Test: calculateSummary() → verify totalExpenses equals sum of amounts
   - Tag: `Feature: expense-tracker-app, Property 7: For any expense transactions, total SHALL equal sum of amounts`

8. **Balance Calculation Invariant** (Property 8)
   - Generator: Random mix of income and expense transactions
   - Test: calculateSummary() → verify balance = income - expenses
   - Tag: `Feature: expense-tracker-app, Property 8: For any transactions, balance SHALL equal income minus expenses`

9. **Theme Preference Persistence** (Property 9)
   - Generator: Random theme preferences (light, dark, system)
   - Test: save(theme) → load() → verify theme matches
   - Tag: `Feature: expense-tracker-app, Property 9: For any theme preference, saving SHALL persist to storage`

10. **Transaction Deletion** (Property 10)
    - Generator: Random transactions
    - Test: save(transaction) → delete(transaction) → verify not found
    - Tag: `Feature: expense-tracker-app, Property 10: For any transaction, deletion SHALL remove permanently`

### Unit Testing

**Framework**: XCTest

**Focus Areas**:
- ViewModel logic and state management
- Validation functions with specific edge cases
- Date formatting and calculation utilities
- Category icon and color mapping
- Empty state conditions

**Example Unit Tests**:
- Test transaction form displays all required fields
- Test predefined categories are loaded correctly
- Test empty state message appears when no transactions
- Test keyboard type is numeric for amount field
- Test category has unique icon and color
- Test navigation tabs are present and labeled correctly

### UI Testing

**Framework**: XCTest UI Testing

**Focus Areas**:
- Navigation flows between tabs
- Form submission and validation feedback
- Keyboard appearance and dismissal
- Animation presence (not timing)
- Theme switching
- Swipe gestures (if implemented)

**Example UI Tests**:
- Test user can navigate between all tabs
- Test adding transaction shows confirmation
- Test tapping outside dismisses keyboard
- Test invalid amount shows error message
- Test theme toggle changes appearance

### Integration Testing

**Focus Areas**:
- Core Data stack initialization
- App launch and data loading
- Theme persistence across launches
- Transaction persistence timing
- Month change triggers summary update

**Example Integration Tests**:
- Test app launches and loads saved transactions
- Test transactions persist after app restart
- Test theme preference loads on launch
- Test monthly summary updates when month changes

### Snapshot Testing

**Framework**: swift-snapshot-testing

**Focus Areas**:
- Balance card gradient styling in both themes
- Transaction list item appearance
- Empty state screens
- Category picker layout
- Form validation error states

### Performance Testing

**Focus Areas**:
- Transaction list scrolling performance (60fps)
- Core Data fetch performance with 1000+ transactions
- Monthly summary calculation time
- Animation frame rates

**Benchmarks**:
- Fetch 1000 transactions: < 100ms
- Calculate monthly summary: < 50ms
- Scroll performance: 60fps maintained
- Transition animations: 200-400ms duration

### Test Coverage Goals

- Unit test coverage: > 80% for ViewModels and business logic
- Property test coverage: 100% of correctness properties
- UI test coverage: All critical user flows
- Integration test coverage: All persistence operations

### Continuous Integration

- Run all tests on every pull request
- Property tests run with 100 iterations in CI
- UI tests run on iOS 15.0 and latest iOS version
- Performance tests run weekly with trend tracking
- Snapshot tests fail on any visual regression

