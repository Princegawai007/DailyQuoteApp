//
//  MainTabView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

//import SwiftUI
//
//struct MainTabView: View {
//    @StateObject private var viewModel = QuoteViewModel()
//    @State private var selectedTab = 0
//    
//    var body: some View {
//        ZStack {
//            TabView(selection: $selectedTab) {
//                QuoteDisplayView(viewModel: viewModel)
//                    .tag(0)
//                
//                FavoritesListView(viewModel: viewModel)
//                    .tag(1)
//            }
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            
//            // Custom Bottom Navigation
//            VStack {
//                Spacer()
//                
//                HStack {
//                    Spacer()
//                    
//                    // Home Tab
//                    Button(action: { selectedTab = 0 }) {
//                        VStack(spacing: 4) {
//                            Image(systemName: "house.fill")
//                                .font(.system(size: 24))
//                            Text("Home")
//                                .font(.system(size: 10, weight: .medium))
//                        }
//                        .foregroundColor(selectedTab == 0 ? Color(hex: "#13ec92") : Color.gray.opacity(0.4))
//                    }
//                    
//                    Spacer()
//                    
//                    // Explore Tab
//                    Button(action: {}) {
//                        VStack(spacing: 4) {
//                            Image(systemName: "square.grid.2x2")
//                                .font(.system(size: 24))
//                            Text("Explore")
//                                .font(.system(size: 10, weight: .medium))
//                        }
//                        .foregroundColor(Color.gray.opacity(0.4))
//                    }
//                    
//                    Spacer()
//                    
//                    // Saved Tab
//                    Button(action: { selectedTab = 1 }) {
//                        VStack(spacing: 4) {
//                            Image(systemName: selectedTab == 1 ? "bookmark.fill" : "bookmark")
//                                .font(.system(size: 24))
//                            Text("Saved")
//                                .font(.system(size: 10, weight: .medium))
//                        }
//                        .foregroundColor(selectedTab == 1 ? Color(hex: "#13ec92") : Color.gray.opacity(0.4))
//                    }
//                    
//                    Spacer()
//                    
//                    // Profile Tab
//                    Button(action: {}) {
//                        VStack(spacing: 4) {
//                            Image(systemName: "person")
//                                .font(.system(size: 24))
//                            Text("Profile")
//                                .font(.system(size: 10, weight: .medium))
//                        }
//                        .foregroundColor(Color.gray.opacity(0.4))
//                    }
//                    
//                    Spacer()
//                }
//                .frame(height: 60)
//                .background(
//                    Rectangle()
//                        .fill(Color.white.opacity(0.9))
//                        .background(.ultraThinMaterial)
//                        .overlay(
//                            Rectangle()
//                                .frame(height: 1)
//                                .foregroundColor(Color.gray.opacity(0.1)),
//                            alignment: .top
//                        )
//                )
//            }
////            .ignoresSafeArea(edges: .bottom)
//        }
//    }
//}



import SwiftUI

struct MainTabView: View {
    // We don't need to hold the ViewModel here anymore
    // Each view manages its own data
    @StateObject private var quoteViewModel = QuoteViewModel()
    var body: some View {
//        TabView {
//            // Tab 1: Home Feed
//            QuoteDisplayView() // ✅ FIX: No arguments passed here
//                .tabItem {
//                    Label("Daily Wisdom", systemImage: "quote.bubble.fill")
//                }
//            
//            // Tab 2: Favorites
//            FavoritesListView()
//                .tabItem {
//                    Label("Favorites", systemImage: "heart.fill")
//                }
//            
//            // Tab 3: Settings (Profile is inside here now)
//            SettingsView()
//                .tabItem {
//                    Label("Settings", systemImage: "gear")
//                }
//        }
        TabView {
            QuoteDisplayView(viewModel: quoteViewModel)
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble")
                }

            // UPDATE THIS TAB:
            NavigationView {
                LibraryView(quotesVM: quoteViewModel) // Pass your shared ViewModel
            }
            .tabItem {
                Label("Library", systemImage: "books.vertical")
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.blue) // Optional: customize tab color
    }
}
