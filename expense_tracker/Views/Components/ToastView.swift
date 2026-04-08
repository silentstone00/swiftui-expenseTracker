//
//  ToastView.swift
//  expense_tracker
//

import SwiftUI

// MARK: - Toast Pill

struct ToastView: View {
    let message: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(
            Capsule()
                .fill(Color.cardBackground)
                .overlay(Capsule().stroke(color.opacity(0.40), lineWidth: 1))
        )
        .shadow(color: .black.opacity(0.30), radius: 14, x: 0, y: 6)
    }
}

// MARK: - Home Toast Overlay (bottom, with haptics)

struct HomeToastModifier: ViewModifier {
    @EnvironmentObject private var appState: AppState
    @State private var visible = false
    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            if visible, let msg = appState.toastMessage {
                ToastView(message: msg, icon: appState.toastIcon, color: appState.toastColor)
                    .padding(.bottom, 90)        // just above the tab bar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(999)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: visible)
        .onChange(of: appState.toastMessage) {
            guard appState.toastMessage != nil else { return }

            // Haptic
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            // Show
            withAnimation { visible = true }

            // Auto-dismiss after 2.5 s
            dismissTask?.cancel()
            dismissTask = Task {
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    withAnimation { visible = false }
                    // Small delay before clearing message so fade-out completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        appState.toastMessage = nil
                    }
                }
            }
        }
    }
}

extension View {
    func homeToast() -> some View {
        modifier(HomeToastModifier())
    }
}
