//
//  AddTransactionView.swift
//  expense_tracker
//
//  Enhanced add transaction view with quick amount buttons and improved UX
//

import SwiftUI

struct AddTransactionView: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - ViewModels
    
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    
    // MARK: - Form State
    
    @State private var amount: String = ""
    @State private var transactionType: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    // MARK: - UI State
    
    @State private var validationErrors: [ValidationError] = []
    @State private var isSaving: Bool = false
    @State private var showCategoryPicker: Bool = false
    @FocusState private var focusedField: Field?
    
    // MARK: - Constants
    
    private let noteCharacterLimit = 200
    private let quickAmounts: [Decimal] = [10, 50, 100, 500]
    
    // MARK: - Field Enum
    
    enum Field: Hashable {
        case amount
        case note
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                Color(red: 0.05, green: 0.05, blue: 0.05)
                    .ignoresSafeArea()
                
                // Dismiss keyboard on tap outside
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = nil
                    }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Transaction Type Toggle
                        transactionTypeToggle
                            .padding(.top, 8)
                            .onChange(of: transactionType) { newType in
                                // Clear category when switching to income
                                if newType == .income {
                                    selectedCategory = nil
                                }
                            }
                        
                        // Amount Field with Quick Buttons
                        amountSection
                        
                        // Category Picker (only for expenses)
                        if transactionType == .expense {
                            categoryPickerSection
                        }
                        
                        // Date Picker
                        datePickerSection
                        
                        // Note Field
                        noteField
                        
                        // Save Button
                        saveButton
                            .padding(.top, 16)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .task {
                await categoryViewModel.loadCategories()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Transaction type toggle with color coding
    private var transactionTypeToggle: some View {
        Picker("Type", selection: $transactionType) {
            Text("Expense").tag(TransactionType.expense)
            Text("Income").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
        .colorMultiply(transactionType == .expense ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
    }
    
    /// Amount section with quick buttons
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            // Amount input
            HStack {
                Text("$")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                TextField("0.00", text: $amount)
                    .font(.title2)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .amount)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(transactionType == .expense ? Color.red.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Quick amount buttons (only for expenses)
            if transactionType == .expense {
                HStack(spacing: 12) {
                    ForEach(quickAmounts, id: \.self) { quickAmount in
                        Button(action: {
                            addQuickAmount(quickAmount)
                        }) {
                            Text("+$\(formatQuickAmount(quickAmount))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(red: 0.4, green: 0.8, blue: 0.75).opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            
            // Validation error
            if let error = validationErrors.first(where: { $0 == .invalidAmount }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    /// Category picker section (only for expenses)
    private var categoryPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Button(action: {
                showCategoryPicker.toggle()
                focusedField = nil
            }) {
                HStack {
                    if let category = selectedCategory {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(category.color.color.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: category.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(category.color.color)
                            }
                            
                            Text(category.name)
                                .font(.body)
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("Select a category")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .cornerRadius(12)
            }
            
            // Category picker grid (recent categories first)
            if showCategoryPicker {
                categoryPickerGrid
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Validation error
            if let error = validationErrors.first(where: { $0 == .missingCategory }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    /// Category picker grid with recent categories first
    private var categoryPickerGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(sortedCategories) { category in
                Button(action: {
                    selectedCategory = category
                    withAnimation {
                        showCategoryPicker = false
                    }
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(category.color.color.opacity(0.2))
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: category.icon)
                                .font(.system(size: 24))
                                .foregroundColor(category.color.color)
                        }
                        
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(12)
    }
    
    /// Date picker section
    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            DatePicker(
                "",
                selection: $date,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .padding()
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
            .cornerRadius(12)
            .colorScheme(.dark)
            
            // Validation error
            if let error = validationErrors.first(where: { $0 == .futureDateNotAllowed }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    /// Note input field
    private var noteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Note (Optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(note.count)/\(noteCharacterLimit)")
                    .font(.caption)
                    .foregroundColor(note.count > noteCharacterLimit ? .red : .gray)
            }
            
            TextField("Add a note...", text: $note)
                .lineLimit(3)
                .focused($focusedField, equals: .note)
                .padding()
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .cornerRadius(12)
                .foregroundColor(.white)
                .onChange(of: note) { newValue in
                    if newValue.count > noteCharacterLimit {
                        note = String(newValue.prefix(noteCharacterLimit))
                    }
                }
            
            // Validation error
            if let error = validationErrors.first(where: { $0 == .noteTooLong }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    /// Save button
    private var saveButton: some View {
        Button(action: {
            Task {
                await saveTransaction()
            }
        }) {
            HStack {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Save Transaction")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: transactionType == .expense ? [.red, .red.opacity(0.8)] : [.green, .green.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isSaving)
    }
    
    // MARK: - Computed Properties
    
    /// Sort categories with recent ones first
    private var sortedCategories: [Category] {
        let recentCategoryIds = transactionViewModel.transactions
            .prefix(10)
            .map { $0.category.id }
        
        let recentCategories = categoryViewModel.categories.filter { recentCategoryIds.contains($0.id) }
        let otherCategories = categoryViewModel.categories.filter { !recentCategoryIds.contains($0.id) }
        
        return recentCategories + otherCategories
    }
    
    // MARK: - Methods
    
    /// Add quick amount to current amount
    private func addQuickAmount(_ quickAmount: Decimal) {
        let currentAmount = Decimal(string: amount) ?? 0
        let newAmount = currentAmount + quickAmount
        amount = String(describing: newAmount)
    }
    
    /// Format quick amount for display
    private func formatQuickAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSNumber) ?? "0"
    }
    
    /// Save transaction with validation
    private func saveTransaction() async {
        validationErrors = []
        focusedField = nil
        
        // Parse amount
        guard let amountDecimal = Decimal(string: amount), amountDecimal > 0 else {
            validationErrors.append(.invalidAmount)
            return
        }
        
        // Validate category for expenses only
        if transactionType == .expense {
            guard selectedCategory != nil else {
                validationErrors.append(.missingCategory)
                return
            }
        }
        
        // Use a default category for income or the selected one for expense
        let category = transactionType == .income
            ? Category(name: "Income", icon: "dollarsign.circle.fill", color: .green)
            : selectedCategory!
        
        // Create transaction
        let transaction = Transaction(
            amount: amountDecimal,
            type: transactionType,
            category: category,
            date: date,
            note: note.isEmpty ? nil : note
        )
        
        // Validate transaction
        let validationResult = TransactionValidator.validate(transaction)
        if !validationResult.isValid {
            validationErrors = validationResult.errors
            return
        }
        
        // Save transaction
        isSaving = true
        
        do {
            try await transactionViewModel.addTransaction(transaction)
            dismiss()
        } catch {
            print("Error saving transaction: \(error)")
            isSaving = false
        }
    }
}

// MARK: - Preview

#Preview {
    AddTransactionView()
}
