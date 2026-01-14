//
//  MainTabView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import SwiftUI

struct MainTabView: View {
    // We don't need to hold the ViewModel here anymore
    // Each view manages its own data
    @StateObject private var quoteViewModel = QuoteViewModel()
    var body: some View {
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
