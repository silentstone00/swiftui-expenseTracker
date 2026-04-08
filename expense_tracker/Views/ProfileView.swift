//
//  ProfileView.swift
//  expense_tracker
//
//  Profile and settings view
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var themeViewModel: ThemeViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(Color.accentColor)
                            }
                            Text("User Profile")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                        }
                        .padding(.top, 20)

                        // Settings Sections
                        VStack(spacing: 16) {
                            SettingsSection(title: "Appearance") {
                                SettingsRow(icon: "moon.fill", title: "Dark Mode", iconColor: .purple) {
                                    Toggle("", isOn: $themeViewModel.isDarkMode).labelsHidden()
                                }
                            }

                            SettingsSection(title: "General") {
                                SettingsRow(icon: "bell.fill", title: "Notifications", iconColor: .orange) {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondaryText)
                                }
                                SettingsRow(icon: "lock.fill", title: "Privacy", iconColor: .blue) {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondaryText)
                                }
                            }

                            SettingsSection(title: "About") {
                                SettingsRow(icon: "info.circle.fill", title: "Version", iconColor: .gray) {
                                    Text("1.0.0")
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Settings Section Component

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondaryText)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primaryText.opacity(0.05), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Settings Row Component

struct SettingsRow<Accessory: View>: View {
    let icon: String
    let title: String
    let iconColor: Color
    let accessory: Accessory

    init(icon: String, title: String, iconColor: Color, @ViewBuilder accessory: () -> Accessory) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.accessory = accessory()
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }

            Text(title)
                .font(.body)
                .foregroundColor(.primaryText)

            Spacer()
            accessory
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

#Preview { ProfileView() }
