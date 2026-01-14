//
//  QuoteDisplayView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import SwiftUI

struct QuoteDisplayView: View {
    @ObservedObject var viewModel: QuoteViewModel
    
    // 1. Connect to the global font size setting
    @AppStorage("fontSize") private var fontSize: Double = 21.0
    
    var body: some View {
        NavigationView {
            if #available(iOS 16.0, *) {
                ZStack {
                    AnimatedGradientView()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        // Categories
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    CategoryPill(
                                        title: category,
                                        isSelected: viewModel.selectedCategory == category
                                    ) {
                                        withAnimation {
                                            viewModel.selectCategory(category)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        
                        // Content
                        if viewModel.isLoading && viewModel.quotes.isEmpty {
                            Spacer()
                            ProgressView().tint(.primary) // Adaptive tint
                            Spacer()
                        } else if viewModel.quotes.isEmpty {
                            Spacer()
                            VStack(spacing: 15) {
                                Image(systemName: "quote.bubble")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No quotes found in this\ncategory yet!")
                                    .font(.system(.title2, design: .serif))
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary) // Adaptive text
                                
                                Text("- System")
                                    .font(.system(.subheadline, design: .serif))
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(uiColor: .secondarySystemGroupedBackground)) // Adaptive Card
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            .padding(40)
                            Spacer()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 20) {
                                    if let dailyQuote = viewModel.quoteOfTheDay {
                                        DailyHeroSection(quote: dailyQuote, viewModel: viewModel, fontSize: fontSize)
                                            .padding(.bottom, 10)
                                        
                                        Divider()
                                            .padding(.horizontal)
                                            .padding(.bottom, 10)
                                    }
                                    
                                    ForEach(viewModel.quotes) { quote in
                                        // Pass fontSize to the card
                                        HomeQuoteCard(quote: quote, viewModel: viewModel, fontSize: fontSize)
                                            .onAppear {
                                                if quote.id == viewModel.quotes.last?.id {
                                                    Task { await viewModel.fetchQuotes(loadMore: true) }
                                                }
                                            }
                                    }
                                    if viewModel.isLoading {
                                        ProgressView().padding()
                                    }
                                }
                                .padding()
                                .padding(.bottom, 20)
                                
                                // --- QUOTE OF THE DAY SECTION ---
                                if let dailyQuote = viewModel.quoteOfTheDay {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Image(systemName: "sparkles")
                                                .foregroundColor(.yellow)
                                            Text("QUOTE OF THE DAY")
                                                .font(.system(size: 14, weight: .black))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal)
                                        
                                        HomeQuoteCard(quote: dailyQuote, viewModel: viewModel, fontSize: fontSize + 2)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                                            )
                                            .shadow(color: .yellow.opacity(0.2), radius: 10)
                                    }
                                    .padding(.bottom, 10)
                                    
                                    Divider()
                                        .padding(.horizontal)
                                        .padding(.bottom, 10)
                                }
                                // --------------------------------
                            }
                            .refreshable {
                                await viewModel.fetchQuoteOfTheDay() // Add this
                                await viewModel.fetchQuotes(loadMore: false)
                                
                            }
                        }
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.fetchQuoteOfTheDay() // Fetches the hero quote
                        await viewModel.fetchQuotes(loadMore: false) // Fetches the feed
                        await viewModel.fetchBookmarkedStatus()
                        viewModel.refreshBookmarks()
                    }
                }
                .navigationTitle("Daily Wisdom")
            } else {
                // Fallback for older iOS
                Text("Requires iOS 16+")
            }
        }
    }
}

// MARK: - Subviews

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .serif))
                .padding(.vertical, 10)
                .padding(.horizontal, 24)
            // Adaptive Background: Black in Light Mode, White in Dark Mode when selected
                .background(isSelected ? Color.primary : Color(uiColor: .secondarySystemBackground))
            // Adaptive Text: Inverse of background
                .foregroundColor(isSelected ? Color(uiColor: .systemBackground) : Color.primary)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}

struct HomeQuoteCard: View {
    let quote: Quote
    @ObservedObject var viewModel: QuoteViewModel
    @State private var showShareOptions = false
    @State private var showSharePreview = false
    
    // Receive dynamic font size
    var fontSize: Double
    
    // States for sheets
    @State private var shareItem: ShareableImage?
    @State private var showTextShareSheet = false
    @State private var showAddToCollectionSheet = false // <--- NEW STATE
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // Quote Text with Dynamic Size and Serif
            Text("“\(quote.content)”")
                .font(.system(size: fontSize, weight: .medium, design: .serif))
                .foregroundColor(.primary) // Adaptive Black/White
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .animation(.spring(), value: fontSize)
            
            // Author
            Text("- \(quote.author)")
                .font(.system(.subheadline, design: .serif))
                .italic()
                .foregroundColor(.secondary)
            
            Divider()
                .background(Color.gray.opacity(0.2))
                .padding(.vertical, 5)
            
            // Actions
            HStack {
                // 1. LIKE BUTTON
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        viewModel.toggleFavorite(quote)
                    }
                }) {
                    Image(systemName: viewModel.isFavorite(quote) ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(viewModel.isFavorite(quote) ? .green : .green)
                }
                
                // 2. SAVE TO COLLECTION BUTTON (NEW)
                Button(action: {
                    showAddToCollectionSheet = true
                }) {
                    // Check if this quote's ID is in our bookmarked list
                    Image(systemName: viewModel.bookmarkedQuoteIds.contains(quote.id ?? -1) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                    // Change color to Blue (or your preference) when filled
                        .foregroundColor(viewModel.bookmarkedQuoteIds.contains(quote.id ?? -1) ? .green : .green)
                }
                .padding(.leading, 20) // Space between Heart and Bookmark
                
                Spacer()
                // 3. SHARE BUTTON
                Button(action: {
                    showShareOptions = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
                .confirmationDialog("Share Quote", isPresented: $showShareOptions, titleVisibility: .visible) {
                    Button("Share as Text") {
                        shareAsText(quote: quote)
                    }
                    Button("Share as Image Card") {
                        showSharePreview = true // This opens the 3-template picker
                    }
                    Button("Cancel", role: .cancel) { }
                }
                // Keep the sheet attached to the button or the VStack
                .sheet(isPresented: $showSharePreview) {
                    SharePreviewView(quote: quote, shareItem: $shareItem)
                }
            }
        }
        .padding(20)
        // Adaptive Background: White in Light, Dark Grey in Dark
        //        .background(Color(uiColor: .secondarySystemGroupedBackground))
        //        .background(Color.black) // This makes it OLED Black
        .background(Color(uiColor: .systemBackground))
        // Note: In Dark Mode, .systemBackground is pure black on most iOS devices.
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        // --- SHEETS ---
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
        }
        .sheet(isPresented: $showTextShareSheet) {
            ShareSheet(items: ["“\(quote.content)” - \(quote.author)"])
        }
        .sheet(isPresented: $showAddToCollectionSheet) {
            if let quoteId = quote.id {
                // Pass BOTH the quoteId and the viewModel
                if #available(iOS 16.0, *) {
                    AddToCollectionView(quoteId: quoteId, quotesVM: viewModel)
                        .presentationDetents([.medium, .large])
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    @MainActor
    private func generateAndShareImage() {
        if #available(iOS 16.0, *) {
            // Change  to .minimal (default)
            let viewToRender = renderView(for: quote, theme: .minimal)
            let renderer = ImageRenderer(content: viewToRender)
            renderer.scale = UIScreen.main.scale
            if let image = renderer.uiImage {
                self.shareItem = ShareableImage(image: image)
            }
        } else {
            showTextShareSheet = true
        }
    }
    
    private func renderView(for quote: Quote, theme: QuoteTheme) -> some View {
        VStack(spacing: 20) {
            Text("“\(quote.content)”")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("- \(quote.author)")
                .font(.headline)
                .foregroundColor(theme.textColor.opacity(0.8))
        }
        .frame(width: 400, height: 400)
        .background(LinearGradient(colors: theme.backgroundColors , startPoint: .top, endPoint: .bottom))
    }
    private func shareAsText(quote: Quote) {
        let textToShare = "“\(quote.content)” — \(quote.author)\n\nShared via Daily Wisdom"
        let av = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        // Finding the root view controller to present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
    }
}
// This is the missing piece that was causing your error!
struct DailyHeroSection: View {
    let quote: Quote
    @ObservedObject var viewModel: QuoteViewModel
    var fontSize: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("QUOTE OF THE DAY")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            HomeQuoteCard(quote: quote, viewModel: viewModel, fontSize: fontSize + 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
                .shadow(color: .yellow.opacity(0.2), radius: 10)
        }
    }
}
