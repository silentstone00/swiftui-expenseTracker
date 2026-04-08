//
//  AddCategorySheet.swift
//  expense_tracker
//

import SwiftUI

struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var categoryViewModel: CategoryViewModel

    @State private var name: String = ""
    @State private var selectedColor: CategoryColor = .blue
    @State private var selectedIcon: String = "star.fill"
    @State private var isSaving: Bool = false
    @State private var showNameError: Bool = false

    // Curated SF Symbols — grouped semantically
    private let iconOptions: [String] = [
        // Food & drink
        "fork.knife", "cup.and.saucer.fill", "carrot.fill", "birthday.cake.fill",
        // Transport
        "car.fill", "bus.fill", "tram.fill", "airplane",
        // Home & utilities
        "house.fill", "lightbulb.fill", "bolt.fill", "drop.fill",
        // Entertainment
        "tv.fill", "gamecontroller.fill", "music.note", "camera.fill",
        // Health & fitness
        "heart.fill", "cross.fill", "pills.fill", "figure.walk",
        // Education & work
        "book.fill", "graduationcap.fill", "briefcase.fill", "pencil",
        // Shopping
        "cart.fill", "bag.fill", "tag.fill", "gift.fill",
        // Finance
        "creditcard.fill", "banknote.fill", "chart.line.uptrend.xyaxis", "building.columns.fill"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        previewCard
                        nameSection
                        colorSection
                        iconSection
                        saveButton
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.primaryText)
                }
            }
        }
    }

    // MARK: - Subviews

    private var previewCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(selectedColor.color.opacity(0.18))
                    .frame(width: 76, height: 76)
                Image(systemName: selectedIcon)
                    .font(.system(size: 34))
                    .foregroundColor(selectedColor.color)
            }
            Text(name.trimmingCharacters(in: .whitespaces).isEmpty ? "Category Name" : name)
                .font(.headline)
                .foregroundColor(name.isEmpty ? .secondaryText : .primaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            TextField("e.g. Gym, Coffee, Netflix", text: $name)
                .padding()
                .background(Color.inputBackground)
                .cornerRadius(12)
                .foregroundColor(.primaryText)
                .onChange(of: name) {
                    if showNameError && !name.isEmpty { showNameError = false }
                }
            if showNameError {
                Text("Please enter a category name")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)

            HStack(spacing: 14) {
                ForEach(CategoryColor.allCases, id: \.self) { color in
                    Button(action: {
                        withAnimation(.spring(response: 0.2)) { selectedColor = color }
                    }) {
                        ZStack {
                            Circle()
                                .fill(color.color)
                                .frame(width: 36, height: 36)
                            if selectedColor == color {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .scaleEffect(selectedColor == color ? 1.15 : 1.0)
                        .animation(.spring(response: 0.2), value: selectedColor == color)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6),
                spacing: 12
            ) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button(action: {
                        withAnimation(.spring(response: 0.2)) { selectedIcon = icon }
                    }) {
                        ZStack {
                            Circle()
                                .fill(selectedIcon == icon
                                    ? selectedColor.color.opacity(0.2)
                                    : Color.elevatedBackground)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            selectedIcon == icon ? selectedColor.color : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            Image(systemName: icon)
                                .font(.system(size: 19))
                                .foregroundColor(selectedIcon == icon ? selectedColor.color : .secondaryText)
                        }
                        .scaleEffect(selectedIcon == icon ? 1.1 : 1.0)
                        .animation(.spring(response: 0.2), value: selectedIcon == icon)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var saveButton: some View {
        Button(action: saveCategory) {
            Group {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("Save Category")
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

    // MARK: - Methods

    private func saveCategory() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            showNameError = true
            return
        }
        Task {
            isSaving = true
            let newCategory = Category(
                name: trimmed,
                icon: selectedIcon,
                color: selectedColor,
                isCustom: true
            )
            try? await categoryViewModel.addCustomCategory(newCategory)
            isSaving = false
            dismiss()
        }
    }
}
