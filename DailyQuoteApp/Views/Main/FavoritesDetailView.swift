//
//  FavoritesListView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import SwiftUI
import UIKit

struct FavoritesDetailView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @State private var searchText = ""
    @State private var shareItem: ShareableImage?
    
    // 1. Connect to the global font size setting
    @AppStorage("fontSize") private var fontSize: Double = 21.0
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientView()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("My Collection")
                            .font(.system(size: 34, weight: .bold, design: .serif)) // Serif
                            .foregroundColor(.primary)
                        
                        Text("Your daily dose of saved wisdom")
                            .font(.system(.subheadline, design: .serif)) // Serif
                            .foregroundColor(.secondary)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search quotes...", text: $searchText)
                                .font(.system(.body, design: .serif)) // Serif input
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // List
                    if filteredQuotes.isEmpty {
                        Spacer()
                        VStack(spacing: 15) {
                            Image(systemName: searchText.isEmpty ? "heart.slash" : "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            Text(searchText.isEmpty ? "No favorites yet" : "No results found")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredQuotes) { quote in
                                    // Pass fontSize
                                    FavoriteCard(quote: quote, viewModel: viewModel, fontSize: fontSize) {
                                        if #available(iOS 16.0, *) {
                                            generateAndShareImage(for: quote)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task { await viewModel.loadFavorites() }
            }
            .sheet(item: $shareItem) { item in
                ShareSheet(items: [item.image])
            }
        }
    }
    
    var filteredQuotes: [Quote] {
        if searchText.isEmpty {
            return viewModel.favoriteQuotes
        } else {
            return viewModel.favoriteQuotes.filter { quote in
                quote.content.localizedCaseInsensitiveContains(searchText) ||
                quote.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    @available(iOS 16.0, *)
    @MainActor
    private func generateAndShareImage(for quote: Quote) {
        let viewToRender = renderView(for: quote)
        let renderer = ImageRenderer(content: viewToRender)
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            self.shareItem = ShareableImage(image: image)
        }
    }
    
    func renderView(for quote: Quote) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "quote.opening")
                .font(.largeTitle)
                .foregroundColor(.green.opacity(0.6))
            Text("\"\(quote.content)\"")
                .font(.system(size: 30, weight: .medium, design: .serif))
                .multilineTextAlignment(.center).padding()
            Text("- \(quote.author)")
                .font(.system(.headline, design: .serif))
                .italic().foregroundColor(.gray)
            Text("Shared via QuoteVault")
                .font(.system(.caption2, design: .serif))
                .foregroundColor(.gray.opacity(0.4))
        }
        .frame(width: 350, height: 400).background(Color.white).cornerRadius(20)
    }
}

struct FavoriteCard: View {
    let quote: Quote
    @ObservedObject var viewModel: QuoteViewModel
    
    // Receive dynamic font size
    var fontSize: Double
    var onShare: () -> Void
    
    // --- ADDED STATES FOR SHARE ---
    @State private var showShareOptions = false
    @State private var showSharePreview = false
    @State private var shareItem: ShareableImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                Image(systemName: "quote.opening")
                    .font(.title3)
                    .foregroundColor(Color.green.opacity(0.3))
                
                Text(quote.content)
                    .font(.system(size: fontSize, weight: .medium, design: .serif))
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .animation(.spring(), value: fontSize)
                
                Spacer()
                
                Button(action: {
                    withAnimation { viewModel.toggleFavorite(quote) }
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(Color.green)
                        .font(.title3)
                }
            }
            
            Divider().background(Color.gray.opacity(0.1))
            
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 32, height: 32)
                        Text(getInitials(name: quote.author))
                            .font(.system(.caption, design: .serif))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    Text(quote.author)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // --- UPDATED SHARE BUTTON ACTION ---
                // --- UPDATED SHARE BUTTON WITH ANCHORED DIALOG ---
                Button(action: { showShareOptions = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.green)
                }
                // Attach the dialog HERE so it anchors to this button
                .confirmationDialog("Share Quote", isPresented: $showShareOptions, titleVisibility: .visible) {
                    Button("Share as Text") {
                        shareAsText(quote: quote)
                    }
                    Button("Share as Image Card") {
                        showSharePreview = true
                    }
                    Button("Cancel", role: .cancel) { }
                }
                // Sheets can remain here or move to the outer VStack
                .sheet(isPresented: $showSharePreview) {
                    SharePreviewView(quote: quote, shareItem: $shareItem)
                }
                .sheet(item: $shareItem) { item in
                    ShareSheet(items: [item.image])
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // --- HELPER FUNCTION ---
    private func shareAsText(quote: Quote) {
        let textToShare = "“\(quote.content)” — \(quote.author)\n\nShared via Daily Wisdom"
        let av = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
    }
    
    func getInitials(name: String) -> String {
        let parts = name.components(separatedBy: " ")
        if let first = parts.first?.prefix(1), let last = parts.last?.prefix(1) {
            return "\(first)\(last)"
        }
        return String(name.prefix(2))
    }
}
