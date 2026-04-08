//
//  EditTransactionView.swift
//  expense_tracker
//

import SwiftUI

struct EditTransactionView: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var transactionViewModel: TransactionViewModel
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    @EnvironmentObject private var appState: AppState

    // MARK: - Transaction to Edit

    let transaction: Transaction

    // MARK: - Form State

    @State private var amount: String = ""
    @State private var transactionType: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var date: Date = Date()
    @State private var note: String = ""

    // MARK: - UI State

    @State private var validationErrors: [ValidationError] = []
    @State private var isSaving: Bool = false
    @State private var showAddCategory: Bool = false
    @State private var showAllCategories: Bool = false
    @FocusState private var focusedField: Field?

    // MARK: - Constants

    private let noteCharacterLimit = 200
    private let quickAmounts: [Decimal] = [10, 50, 100, 500]

    enum Field: Hashable { case amount; case note }

    // MARK: - Initialization

    init(transaction: Transaction) {
        self.transaction = transaction
        _amount = State(initialValue: String(describing: transaction.amount))
        _transactionType = State(initialValue: transaction.type)
        _selectedCategory = State(initialValue: transaction.category)
        _date = State(initialValue: transaction.date)
        _note = State(initialValue: transaction.note ?? "")
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { focusedField = nil }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        transactionTypeToggle
                            .padding(.top, 8)
                            .onChange(of: transactionType) {
                                if transactionType == .income { selectedCategory = nil }
                            }

                        amountSection

                        if transactionType == .expense {
                            categoryPickerSection
                        }

                        datePickerSection
                        noteField
                        saveButton.padding(.top, 8)
                    }
                    .padding()
                    .gesture(
                        DragGesture(minimumDistance: 40, coordinateSpace: .local)
                            .onEnded { value in
                                guard abs(value.translation.width) > abs(value.translation.height) * 1.5 else { return }
                                let newType: TransactionType = value.translation.width < 0 ? .income : .expense
                                guard newType != transactionType else { return }
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    transactionType = newType
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                    )
                }
                .simultaneousGesture(TapGesture().onEnded { focusedField = nil })
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.primaryText)
                }
            }
            .task { await categoryViewModel.loadCategories() }
            .sheet(isPresented: $showAddCategory) {
                AddCategorySheet()
                    .environmentObject(categoryViewModel)
            }
            .sheet(isPresented: $showAllCategories, onDismiss: nil) {
                AllCategoriesSheet(selectedCategory: $selectedCategory)
                    .environmentObject(categoryViewModel)
            }
            .onChange(of: showAllCategories) {
                if showAllCategories { Task { await categoryViewModel.loadCategories() } }
            }
        }
    }

    // MARK: - Subviews

    private var transactionTypeToggle: some View {
        Picker("Type", selection: $transactionType) {
            Text("Expense").tag(TransactionType.expense)
            Text("Income").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
    }

    private var amountSection: some View {
        VStack(spacing: 20) {
            // Large centered amount — custom placeholder avoids font mismatch
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("₹")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(amount.isEmpty ? .secondaryText : .primaryText)

                ZStack(alignment: .leading) {
                    if amount.isEmpty {
                        Text("0")
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundColor(.secondaryText)
                    }
                    TextField("", text: $amount)
                        .font(.system(size: 64, weight: .semibold))
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                        .foregroundColor(.primaryText)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .amount }

            // Suggestion pills — expense only
            if transactionType == .expense {
                HStack(spacing: 8) {
                    ForEach(quickAmounts, id: \.self) { q in
                        Button(action: { addQuickAmount(q) }) {
                            Text("+₹\(formatQuickAmount(q))")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.elevatedBackground))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            if let error = validationErrors.first(where: { $0 == .invalidAmount }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var categoryPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)

            // Top 4 frequent categories — scrollable row, full names visible
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(sortedCategories.prefix(4))) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory?.id == category.id
                        )
                        .onTapGesture {
                            selectedCategory = category
                            focusedField = nil
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            // View All + Add New
            HStack(spacing: 10) {
                Button(action: { showAllCategories = true }) {
                    HStack(spacing: 6) {
                        Text("View All")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.elevatedBackground)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Button(action: { showAddCategory = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("Add New")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.accentColor.opacity(0.08))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            if let error = validationErrors.first(where: { $0 == .missingCategory }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)

            HStack {
                DatePicker(
                    "",
                    selection: $date,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                Spacer()
            }
            .padding()
            .background(Color.fieldBackground)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.gray.opacity(0.25), lineWidth: 1)
            )

            if let error = validationErrors.first(where: { $0 == .futureDateNotAllowed }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Note (Optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryText)
                Spacer()
                Text("\(note.count)/\(noteCharacterLimit)")
                    .font(.caption)
                    .foregroundColor(note.count > noteCharacterLimit ? .red : .gray)
            }

            TextField("Add a note...", text: $note)
                .lineLimit(3)
                .focused($focusedField, equals: .note)
                .padding()
                .background(Color.fieldBackground)
                .cornerRadius(12)
                .foregroundColor(.primaryText)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.gray.opacity(0.25), lineWidth: 1)
                )
                .onChange(of: note) {
                    if note.count > noteCharacterLimit {
                        note = String(note.prefix(noteCharacterLimit))
                    }
                }

            if let error = validationErrors.first(where: { $0 == .noteTooLong }) {
                Text(error.errorDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var saveButton: some View {
        Button(action: {
            Task { await updateTransaction() }
        }) {
            HStack {
                if isSaving {
                    ProgressView().progressViewStyle(.circular).tint(.white)
                } else {
                    Text("Update Transaction")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .foregroundColor(.primaryText)
            .cornerRadius(12)
        }
        .disabled(isSaving)
    }

    // MARK: - Computed Properties

    private var sortedCategories: [Category] {
        let recentIds = transactionViewModel.transactions.prefix(10).map { $0.category.id }
        let recent = categoryViewModel.categories.filter { recentIds.contains($0.id) }
        let other = categoryViewModel.categories.filter { !recentIds.contains($0.id) }
        return recent + other
    }

    // MARK: - Methods

    private func addQuickAmount(_ quickAmount: Decimal) {
        let currentAmount = Decimal(string: amount) ?? 0
        amount = String(describing: currentAmount + quickAmount)
    }

    private func formatQuickAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSNumber) ?? "0"
    }

    private func updateTransaction() async {
        validationErrors = []
        focusedField = nil

        guard let amountDecimal = Decimal(string: amount), amountDecimal > 0 else {
            validationErrors.append(.invalidAmount)
            return
        }

        if transactionType == .expense {
            guard selectedCategory != nil else {
                validationErrors.append(.missingCategory)
                return
            }
        }

        let category = transactionType == .income
            ? Category.income
            : selectedCategory!

        let updatedTransaction = Transaction(
            id: transaction.id,
            amount: amountDecimal,
            type: transactionType,
            category: category,
            date: date,
            note: note.isEmpty ? nil : note,
            createdAt: transaction.createdAt,
            updatedAt: Date()
        )

        let validationResult = TransactionValidator.validate(updatedTransaction)
        if !validationResult.isValid {
            validationErrors = validationResult.errors
            return
        }

        isSaving = true

        do {
            try await transactionViewModel.updateTransaction(updatedTransaction)
            appState.showToast(
                message: "Transaction updated",
                icon: "checkmark.circle.fill",
                color: Color.accentColor
            )
            dismiss()
        } catch {
            print("Error updating transaction: \(error)")
            isSaving = false
        }
    }
}

// MARK: - Preview

#Preview {
    EditTransactionView(transaction: Transaction(
        amount: 45.50,
        type: .expense,
        category: Category.predefined[0],
        date: Date(),
        note: "Lunch at cafe"
    ))
}
