//
//  LaunchScreenView.swift
//  expense_tracker
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var titleOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()

            // Subtle radial glow behind logo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.45, blue: 0.1).opacity(0.25),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .opacity(glowOpacity)
                .scaleEffect(ringScale)

            VStack(spacing: 0) {
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.55, blue: 0.15).opacity(0.4),
                                    Color(red: 1.0, green: 0.35, blue: 0.05).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 110, height: 110)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Logo circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.55, blue: 0.15),
                                    Color(red: 0.95, green: 0.3, blue: 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 82, height: 82)
                        .shadow(color: Color(red: 1.0, green: 0.45, blue: 0.1).opacity(0.5), radius: 24, x: 0, y: 8)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    // ₹ symbol
                    Text("₹")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                Spacer().frame(height: 28)

                // App name
                Text("Expense Tracker")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Spacer().frame(height: 8)

                // Tagline
                Text("Track every rupee")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.4))
                    .opacity(taglineOpacity)
            }
        }
        .onAppear { animate() }
    }

    private func animate() {
        // Ring + glow
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.05)) {
            ringScale = 1.0
            ringOpacity = 1.0
            glowOpacity = 1.0
        }
        // Logo bounces in
        withAnimation(.spring(response: 0.55, dampingFraction: 0.58).delay(0.15)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        // Title slides up
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.35)) {
            titleOffset = 0
            titleOpacity = 1.0
        }
        // Tagline fades in
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            taglineOpacity = 1.0
        }
    }
}
