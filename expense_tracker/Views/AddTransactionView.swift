//
//  AddTransactionView.swift
//  expense_tracker
//
//  Form view for adding new transactions with validation
//

import SwiftUI

struct AddTransactionView: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - ViewModels
    
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var categoryViewModel = CategoryViewModel()
    
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
    
    // MARK: - Field Enum
    
    enum Field: Hashable {
        case amount
        case note
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background matching Figma
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
                        
                        // Amount Field
                        amountField
                        
                        // Category Picker
                        categoryPickerSection
                        
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
            .toolbarBackground(Color(red: 0.05, green: 0.05, blue: 0.05), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                // Set default category
                if selectedCategory == nil {
                    selectedCategory = categoryViewModel.categories.first
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Transaction type toggle (Income/Expense)
    private var transactionTypeToggle: some View {
        Picker("Type", selection: $transactionType) {
            Text("Expense").tag(TransactionType.expense)
            Text("Income").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
    }
    
    /// Amount input field with numeric keyboard
    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
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
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
            .cornerRadius(12)
            
            // Validation error for amount
            if let error = validationErrors.first(where: { $0 == .invalidAmount }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    /// Category picker section
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
                        // Selected category display
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
            
            // Category picker grid
            if showCategoryPicker {
                categoryPickerGrid
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Validation error for category
            if let error = validationErrors.first(where: { $0 == .missingCategory }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    /// Category picker grid with icons and colors
    private var categoryPickerGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(categoryViewModel.categories) { category in
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
            
            // Validation error for date
            if let error = validationErrors.first(where: { $0 == .futureDateNotAllowed }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    /// Note input field with character limit
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
            
            TextField("Add a note...", text: $note, axis: .vertical)
                .lineLimit(3...5)
                .focused($focusedField, equals: .note)
                .padding()
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .cornerRadius(12)
                .foregroundColor(.white)
                .onChange(of: note) { oldValue, newValue in
                    // Enforce character limit
                    if newValue.count > noteCharacterLimit {
                        note = String(newValue.prefix(noteCharacterLimit))
                    }
                }
            
            // Validation error for note
            if let error = validationErrors.first(where: { $0 == .noteTooLong }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    /// Save button with validation
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
                        .tint(Color(red: 0.05, green: 0.05, blue: 0.05))
                } else {
                    Text("Save Transaction")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSaving ? Color.gray : Color.white)
            .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.05))
            .cornerRadius(12)
        }
        .disabled(isSaving)
    }
    
    // MARK: - Methods
    
    /// Save transaction with validation
    private func saveTransaction() async {
        // Clear previous errors
        validationErrors = []
        
        // Dismiss keyboard
        focusedField = nil
        
        // Parse amount
        guard let amountDecimal = Decimal(string: amount), amountDecimal > 0 else {
            validationErrors.append(.invalidAmount)
            return
        }
        
        // Validate category
        guard let category = selectedCategory else {
            validationErrors.append(.missingCategory)
            return
        }
        
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
            
            // Success - dismiss view
            dismiss()
        } catch {
            // Handle error
            print("Error saving transaction: \(error)")
            // Show error to user (could add an alert here)
            isSaving = false
        }
    }
}

// MARK: - Preview

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
    }
}
