//
//  MainTabView.swift
//  expense_tracker
//
//  Root view with native bottom tab navigation
//

import SwiftUI

struct MainTabView: View {
    // MARK: - State
    
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: Int = 0
    @State private var showAddTransaction: Bool = false

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Balance Tab (Transactions + Stats)
            BalanceView()
                .tabItem {
                    Label("Balance", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(Color.accentColor)
        .overlay(alignment: .bottomTrailing) {
            Button {
                showAddTransaction = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .frame(width: 50, height: 50)
            }
            .buttonStyle(.glassProminent)
            .tint(.accentColor)
            .buttonBorderShape(.circle)
            .controlSize(.small)
            .shadow(color: Color.accentColor.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.trailing, 20)
            .padding(.bottom, 90)
            .opacity(appState.showFAB && selectedTab != 2 ? 1 : 0)
            .allowsHitTesting(appState.showFAB && selectedTab != 2)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
