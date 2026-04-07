//
//  MainTabView.swift
//  expense_tracker
//
//  Root view with native bottom tab navigation
//

import SwiftUI

struct MainTabView: View {
    // MARK: - State
    
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
        .accentColor(Color(red: 0.4, green: 0.8, blue: 0.75))
        .overlay(alignment: .bottomTrailing) {
            // Native floating + button with teal background
            Button(action: {
                showAddTransaction = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(red: 0.4, green: 0.8, blue: 0.75))
                    .cornerRadius(30) // Half of width/height to make it circular
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
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
