//
//  FavoritesListView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import SwiftUI
import UIKit

struct FavoritesListView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @State private var searchText = ""
    
    var filteredQuotes: [Quote] {
        if searchText.isEmpty {
            return viewModel.favoriteQuotes
        }
        return viewModel.favoriteQuotes.filter { quote in
            quote.text.localizedCaseInsensitiveContains(searchText) ||
            quote.author.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#f6f8f7")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Collection")
                        .font(.system(size: 36, weight: .heavy, design: .default))
                        .tracking(-0.5)
                        .foregroundColor(Color(hex: "#10221a"))
                    
                    Text("Your daily dose of saved wisdom")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 48)
                .padding(.bottom, 16)
                
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "#13ec92"))
                        .font(.system(size: 24))
                        .padding(.leading, 16)
                    
                    TextField("Search quotes, authors...", text: $searchText)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(Color(hex: "#0d1b16"))
                }
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 999)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Quotes List
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredQuotes) { quote in
                            QuoteCard(
                                quote: quote,
                                isFavorite: viewModel.isFavorite(quote),
                                onFavoriteToggle: {
                                    viewModel.toggleFavorite(quote)
                                },
                                onShare: {
                                    shareQuote(quote)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 96) // Space for bottom nav
                }
            }
        }
    }
    
    private func shareQuote(_ quote: Quote) {
        let text = "\"\(quote.text)\" - \(quote.author)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}
