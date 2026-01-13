//
//  FavoritesListView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

//import SwiftUI
//import UIKit
//
//struct FavoritesListView: View {
//    @ObservedObject var viewModel: QuoteViewModel
//    @State private var searchText = ""
//    
//    var filteredQuotes: [Quote] {
//        if searchText.isEmpty {
//            return viewModel.favoriteQuotes
//        }
//        return viewModel.favoriteQuotes.filter { quote in
//            quote.text.localizedCaseInsensitiveContains(searchText) ||
//            quote.author.localizedCaseInsensitiveContains(searchText)
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            // Background
//            Color(hex: "#f6f8f7")
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Header Section
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("My Collection")
//                        .font(.system(size: 36, weight: .heavy, design: .default))
//                        .tracking(-0.5)
//                        .foregroundColor(Color(hex: "#10221a"))
//                    
//                    Text("Your daily dose of saved wisdom")
//                        .font(.system(size: 14, weight: .medium, design: .default))
//                        .foregroundColor(Color.gray.opacity(0.5))
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 24)
//                .padding(.top, 48)
//                .padding(.bottom, 16)
//                
//                // Search Bar
//                HStack(spacing: 12) {
//                    Image(systemName: "magnifyingglass")
//                        .foregroundColor(Color(hex: "#13ec92"))
//                        .font(.system(size: 24))
//                        .padding(.leading, 16)
//                    
//                    TextField("Search quotes, authors...", text: $searchText)
//                        .font(.system(size: 16, weight: .medium, design: .default))
//                        .foregroundColor(Color(hex: "#0d1b16"))
//                }
//                .frame(height: 56)
//                .background(
//                    RoundedRectangle(cornerRadius: 999)
//                        .fill(Color.white)
//                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 999)
//                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//                        )
//                )
//                .padding(.horizontal, 24)
//                .padding(.bottom, 24)
//                
//                // Quotes List
//                ScrollView {
//                    LazyVStack(spacing: 20) {
//                        ForEach(filteredQuotes) { quote in
//                            QuoteCard(
//                                quote: quote,
//                                isFavorite: viewModel.isFavorite(quote),
//                                onFavoriteToggle: {
//                                    viewModel.toggleFavorite(quote)
//                                },
//                                onShare: {
//                                    shareQuote(quote)
//                                }
//                            )
//                        }
//                    }
//                    .padding(.horizontal, 24)
//                    .padding(.bottom, 96) // Space for bottom nav
//                }
//            }
//        }
//    }
//    
//    private func shareQuote(_ quote: Quote) {
//        let text = "\"\(quote.text)\" - \(quote.author)"
//        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
//        
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let rootViewController = windowScene.windows.first?.rootViewController {
//            rootViewController.present(activityVC, animated: true)
//        }
//    }
//}


//import SwiftUI
//import UIKit
//
//struct FavoritesListView: View {
//    @ObservedObject var viewModel: QuoteViewModel
//    @Environment(\.colorScheme) var colorScheme
//    
//    // Sharing State
////    @State private var showShareSheet = false
////    @State private var sharedImage: UIImage?
//    // Replace the old showShareSheet/sharedImage state with:
//    @State private var shareItem: ShareableImage?
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Background
//                AnimatedGradientView()
//                    .ignoresSafeArea()
//                
//                if viewModel.favoriteQuotes.isEmpty {
//                    VStack(spacing: 20) {
//                        Image(systemName: "heart.slash")
//                            .font(.largeTitle)
//                            .foregroundColor(.gray)
//                        Text("No favorites yet")
//                            .foregroundColor(.gray)
//                    }
//                } else {
//                    ScrollView {
//                        LazyVStack(spacing: 16) {
//                            ForEach(viewModel.favoriteQuotes) { quote in
//                                VStack(alignment: .leading, spacing: 12) {
//                                    // Quote Content
//                                    Text("\"\(quote.content)\"")
//                                        .font(.system(size: 18, weight: .medium, design: .serif))
//                                        .foregroundColor(.primary)
//                                        .multilineTextAlignment(.leading)
//                                    
//                                    // Author & Category
//                                    HStack {
//                                        Text("- \(quote.author)")
//                                            .font(.caption)
//                                            .italic()
//                                            .foregroundColor(.secondary)
//                                        
//                                        Spacer()
//                                        
//                                        Text(quote.category.uppercased())
//                                            .font(.caption2)
//                                            .fontWeight(.bold)
//                                            .foregroundColor(.gray.opacity(0.6))
//                                    }
//                                    
//                                    Divider()
//                                        .background(Color.gray.opacity(0.3))
//                                    
//                                    // Action Buttons
//                                    HStack {
//                                        Button(action: {
//                                            withAnimation {
//                                                viewModel.toggleFavorite(quote)
//                                            }
//                                        }) {
//                                            Label("Remove", systemImage: "heart.fill")
//                                                .font(.caption)
//                                                .foregroundColor(.red)
//                                        }
//                                        
//                                        Spacer()
//                                        
//                                        // ⭐️ NEW: Share Image Button
//                                        Button(action: {
//                                            generateAndShareImage(for: quote)
//                                        }) {
//                                            Label("Share", systemImage: "square.and.arrow.up")
//                                                .font(.caption)
//                                                .foregroundColor(.blue)
//                                        }
//                                    }
//                                }
//                                .padding()
//                                .background(Color(uiColor: .secondarySystemBackground))
//                                .cornerRadius(16)
//                                .shadow(color: Color.primary.opacity(0.05), radius: 5, x: 0, y: 2)
//                                .padding(.horizontal)
//                            }
//                        }
//                        .padding(.top)
//                    }
//                }
//            }
//            .navigationTitle("My Collection")
//            .onAppear {
//                Task { await viewModel.loadFavorites() }
//            }
//            // Add the Sheet Modifier to the main View
////            .sheet(isPresented: $showShareSheet) {
////                if let image = sharedImage {
////                    ShareSheet(items: [image])
////                }
////            }
//            // Replace .sheet(isPresented:...) with:
//            .sheet(item: $shareItem) { item in
//                ShareSheet(items: [item.image])
//            }
//        }
//    }
//    
//    // 🎨 Helper: Create the Card View specifically for the Image Renderer
//    // We force this to look "Light Mode" and clean so it looks good on Instagram/WhatsApp
//    func renderView(for quote: Quote) -> some View {
//        VStack(spacing: 20) {
//            Image(systemName: "quote.opening")
//                .font(.largeTitle)
//                .foregroundColor(.green.opacity(0.6))
//            
//            Text("\"\(quote.content)\"")
//                .font(.system(size: 30, weight: .medium, design: .serif))
//                .multilineTextAlignment(.center)
//                .foregroundColor(.black) // Always black text for the image
//                .padding()
//            
//            Text("- \(quote.author)")
//                .font(.headline)
//                .italic()
//                .foregroundColor(.gray)
//            
//            Text(quote.category.uppercased())
//                .font(.caption2)
//                .fontWeight(.bold)
//                .foregroundColor(.gray.opacity(0.4))
//                .padding(.top, 10)
//            
//            Text("Shared via QuoteVault")
//                .font(.caption2)
//                .foregroundColor(.gray.opacity(0.3))
//                .padding(.top, 20)
//        }
//        .frame(width: 350, height: 450)
//        .background(Color.white) // Always white background for the image
//        .cornerRadius(20)
//    }
//
//    // 📸 Function to Snapshot the View
////    @MainActor
////    private func generateAndShareImage(for quote: Quote) {
////        if #available(iOS 16.0, *) {
////            let viewToRender = renderView(for: quote)
////            
////            let renderer = ImageRenderer(content: viewToRender)
////            renderer.scale = UIScreen.main.scale
////            
////            if let image = renderer.uiImage {
////                self.sharedImage = image
////                self.showShareSheet = true
////            }
////        } else {
////            // Fallback for older iOS
////            print("Image rendering not supported on this iOS version")
////        }
////    }
//    @MainActor
//    private func generateAndShareImage(for quote: Quote) {
//        if #available(iOS 16.0, *) {
//            let viewToRender = renderView(for: quote)
//            let renderer = ImageRenderer(content: viewToRender)
//            renderer.scale = UIScreen.main.scale
//
//            if let image = renderer.uiImage {
//                // Trigger the sheet by setting the item
//                self.shareItem = ShareableImage(image: image)
//            }
//        } else {
//             print("Image rendering not supported on this iOS version")
//        }
//    }
//}




//MARK: THIS CODE IS WORKING FINE
//
//import SwiftUI
//import UIKit
//
//struct FavoritesListView: View {
//    // Using StateObject to manage data
//    @StateObject private var viewModel = QuoteViewModel()
//    
//    // Search State
//    @State private var searchText = ""
//    
//    // Sharing State
//    @State private var shareItem: ShareableImage?
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // 1. The Beautiful Gradient Background
//                // If AnimatedGradientView exists in your project, this will work.
//                // If not, replace with: LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                AnimatedGradientView()
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 20) {
//                    // 2. Custom Header & Search
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("My Collection")
//                            .font(.system(size: 34, weight: .bold))
//                            .foregroundColor(.primary)
//                        
//                        Text("Your daily dose of saved wisdom")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        
//                        // Search Bar
//                        HStack {
//                            Image(systemName: "magnifyingglass")
//                                .foregroundColor(.gray)
//                            TextField("Search quotes, authors...", text: $searchText)
//                        }
//                        .padding()
//                        .background(Color(uiColor: .systemBackground))
//                        .cornerRadius(12)
//                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                    
//                    // 3. The List of Favorites
//                    if filteredQuotes.isEmpty {
//                        Spacer()
//                        VStack(spacing: 15) {
//                            Image(systemName: searchText.isEmpty ? "heart.slash" : "magnifyingglass")
//                                .font(.system(size: 50))
//                                .foregroundColor(.gray.opacity(0.5))
//                            Text(searchText.isEmpty ? "No favorites yet" : "No results found")
//                                .font(.headline)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer()
//                    } else {
//                        ScrollView {
//                            LazyVStack(spacing: 16) {
//                                ForEach(filteredQuotes) { quote in
//                                    FavoriteCard(quote: quote, viewModel: viewModel) {
//                                        // Share Action
//                                        if #available(iOS 16.0, *) {
//                                            generateAndShareImage(for: quote)
//                                        } else {
//                                            // Fallback on earlier versions
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                            .padding(.bottom, 20)
//                        }
//                    }
//                }
//            }
//            .navigationBarHidden(true) // Hide default nav bar to use our custom header
//            .onAppear {
//                Task { await viewModel.loadFavorites() }
//            }
//            .sheet(item: $shareItem) { item in
//                ShareSheet(items: [item.image])
//            }
//        }
//    }
//    
//    // Logic to filter quotes
//    var filteredQuotes: [Quote] {
//        if searchText.isEmpty {
//            return viewModel.favoriteQuotes
//        } else {
//            return viewModel.favoriteQuotes.filter { quote in
//                quote.content.localizedCaseInsensitiveContains(searchText) ||
//                quote.author.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//    }
//    
//    // 📸 Snapshot Logic (Same as before)
//    @available(iOS 16.0, *)
//    @MainActor
//    private func generateAndShareImage(for quote: Quote) {
//        let viewToRender = renderView(for: quote)
//        let renderer = ImageRenderer(content: viewToRender)
//        renderer.scale = UIScreen.main.scale
//
//        if let image = renderer.uiImage {
//            self.shareItem = ShareableImage(image: image)
//        }
//    }
//    
//    func renderView(for quote: Quote) -> some View {
//        VStack(spacing: 20) {
//            Image(systemName: "quote.opening")
//                .font(.largeTitle)
//                .foregroundColor(.green.opacity(0.6))
//            Text("\"\(quote.content)\"").font(.title2).multilineTextAlignment(.center).padding()
//            Text("- \(quote.author)").font(.headline).italic().foregroundColor(.gray)
//            Text("Shared via QuoteVault").font(.caption2).foregroundColor(.gray.opacity(0.4))
//        }
//        .frame(width: 350, height: 400).background(Color.white).cornerRadius(20)
//    }
//}
//
//// MARK: - Subviews
//
//struct FavoriteCard: View {
//    let quote: Quote
//    @ObservedObject var viewModel: QuoteViewModel
//    var onShare: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            HStack(alignment: .top) {
//                // Quote Icon / Decorator
//                Image(systemName: "quote.opening")
//                    .font(.title3)
//                    .foregroundColor(Color.green.opacity(0.3))
//                
//                Text(quote.content)
//                    .font(.system(size: 18, weight: .medium, design: .serif))
//                    .foregroundColor(.primary)
//                    .lineLimit(nil)
//                    .fixedSize(horizontal: false, vertical: true)
//                
//                Spacer()
//                
//                // Heart Icon
//                Button(action: {
//                    withAnimation { viewModel.toggleFavorite(quote) }
//                }) {
//                    Image(systemName: "heart.fill")
//                        .foregroundColor(Color.green) // Matches your screenshot
//                        .font(.title3)
//                }
//            }
//            
//            Divider().background(Color.gray.opacity(0.1))
//            
//            HStack {
//                // Author Initials Circle
//                HStack(spacing: 8) {
//                    ZStack {
//                        Circle()
//                            .fill(Color.green.opacity(0.2))
//                            .frame(width: 32, height: 32)
//                        Text(getInitials(name: quote.author))
//                            .font(.caption)
//                            .fontWeight(.bold)
//                            .foregroundColor(.green)
//                    }
//                    
//                    Text(quote.author)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                // Share Button
//                Button(action: onShare) {
//                    Image(systemName: "square.and.arrow.up")
//                        .foregroundColor(.gray)
//                }
//            }
//        }
//        .padding()
//        .background(Color(uiColor: .systemBackground))
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
//    }
//    
//    func getInitials(name: String) -> String {
//        let parts = name.components(separatedBy: " ")
//        if let first = parts.first?.prefix(1), let last = parts.last?.prefix(1) {
//            return "\(first)\(last)"
//        }
//        return String(name.prefix(2))
//    }
//}


//MARK: ABOVE CODE IS WORKING FINE


import SwiftUI
import UIKit

struct FavoritesListView: View {
    @StateObject private var viewModel = QuoteViewModel()
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                Image(systemName: "quote.opening")
                    .font(.title3)
                    .foregroundColor(Color.green.opacity(0.3))
                
                // Dynamic Font Size + Serif
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
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    func getInitials(name: String) -> String {
        let parts = name.components(separatedBy: " ")
        if let first = parts.first?.prefix(1), let last = parts.last?.prefix(1) {
            return "\(first)\(last)"
        }
        return String(name.prefix(2))
    }
}
