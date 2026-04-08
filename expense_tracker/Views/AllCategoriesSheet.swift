//
//  AllCategoriesSheet.swift
//  expense_tracker
//

import SwiftUI

struct AllCategoriesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    @Binding var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(categoryViewModel.categories) { category in
                            Button(action: {
                                selectedCategory = category
                                dismiss()
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(category.color.color.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: category.icon)
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(category.color.color)
                                    }

                                    Text(category.name)
                                        .font(.body)
                                        .foregroundColor(.primaryText)

                                    Spacer()

                                    if selectedCategory?.id == category.id {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(
                                    selectedCategory?.id == category.id
                                        ? category.color.color.opacity(0.06)
                                        : Color.clear
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .padding(.leading, 78)
                                .opacity(0.3)
                        }
                    }
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .padding()
                }
            }
            .navigationTitle("All Categories")
            .navigationBarTitleDisplayMode(.inline)
            .task { await categoryViewModel.loadCategories() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.primaryText)
                }
            }
        }
    }
}
