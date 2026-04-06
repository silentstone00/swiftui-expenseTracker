//
//  MainTabView.swift
//  expense_tracker
//
//  Root view with bottom tab navigation for Home, Transactions, and Add Transaction
//

import SwiftUI

struct MainTabView: View {
    // MARK: - State
    
    @State private var selectedTab: Tab = .home
    @State private var showAddTransaction: Bool = false
    
    // MARK: - Tab Enum
    
    enum Tab {
        case home
        case transactions
        case stats
        case add
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Dark background
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()
            
            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .transactions:
                    TransactionListView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .stats:
                    StatsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .add:
                    Color.clear // Placeholder, sheet will show
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
            
            // Floating + button (Figma style)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showAddTransaction = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.05))
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
                }
            }
            
            // Custom bottom tab bar
            customTabBar
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            // Home Tab
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == .home
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = .home
                }
            }
            
            Spacer()
            
            // Transactions Tab
            TabBarButton(
                icon: "list.bullet",
                title: "Transactions",
                isSelected: selectedTab == .transactions
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = .transactions
                }
            }
            
            Spacer()
            
            // Stats Tab
            TabBarButton(
                icon: "chart.bar.fill",
                title: "Stats",
                isSelected: selectedTab == .stats
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = .stats
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: -5)
        )
    }
}

// MARK: - Tab Bar Button Component

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(buttonColor)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(buttonColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var buttonColor: Color {
        return isSelected ? Color(red: 0.4, green: 0.8, blue: 0.75) : .gray
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
