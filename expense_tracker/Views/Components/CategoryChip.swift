//
//  CategoryChip.swift
//  expense_tracker
//

import SwiftUI

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: category.icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : category.color.color)
            Text(category.name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? category.color.color : Color.elevatedBackground)
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    isSelected ? Color.clear : category.color.color.opacity(0.25),
                    lineWidth: 1
                )
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}
