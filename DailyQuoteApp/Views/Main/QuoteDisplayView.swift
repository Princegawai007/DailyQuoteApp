//
//  QuoteDisplayView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

//import SwiftUI
//import UIKit
//
//struct QuoteDisplayView: View {
//    @ObservedObject var viewModel: QuoteViewModel
//    @State private var currentDate = Date()
//    @State private var gradientOffset: CGFloat = 0
//    
//    var body: some View {
//        ZStack {
//            // Background Gradient with animation
//            AnimatedGradientView()
//                .ignoresSafeArea()
//            
//            ScrollView {
//                VStack(spacing: 0) {
//                    // Top Bar / Header
//                    HStack {
//                        // Date Indicator
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("TODAY")
//                                .font(.system(size: 12, weight: .medium, design: .default))
//                                .tracking(2)
//                                .foregroundColor(Color(hex: "#ec1337").opacity(0.8))
//                            
//                            Text(dateFormatter.string(from: currentDate))
//                                .font(.system(size: 14, weight: .regular, design: .default))
//                                .foregroundColor(Color.gray.opacity(0.5))
//                        }
//                        
//                        Spacer()
//                        
//                        // Settings Icon
//                        Button(action: {}) {
//                            Image(systemName: "gearshape")
//                                .font(.system(size: 24))
//                                .foregroundColor(Color.gray.opacity(0.6))
//                                .frame(width: 40, height: 40)
//                                .background(
//                                    Circle()
//                                        .fill(Color.black.opacity(0.05))
//                                )
//                        }
//                    }
//                    .padding(.horizontal, 32)
//                    .padding(.top, 32)
//                    .padding(.bottom, 16)
//                    
//                    // Main Content: Quote
//                    Spacer(minLength: 100)
//                    
//                    VStack(spacing: 0) {
//                        // Quote Icon Decorative
//                        Image(systemName: "quote.opening")
//                            .font(.system(size: 48))
//                            .foregroundColor(Color.gray.opacity(0.2))
//                            .padding(.bottom, 24)
//                        
//                        // Quote Text
//                        if viewModel.isLoading {
//                            ProgressView()
//                                .padding()
//                        } else {
//                            if #available(iOS 16.0, *) {
//                                Text("\"\(viewModel.currentQuote.content)\"")
//                                    .font(.system(size: 36, weight: .regular, design: .serif))
//                                    .lineSpacing(8)
//                                    .tracking(-0.5)
//                                    .foregroundColor(Color(hex: "#1b0d10"))
//                                    .multilineTextAlignment(.center)
//                                    .padding(.horizontal, 32)
//                            } else {
//                                // Fallback on earlier versions
//                            }
//                        }
//                        
//                        // Separator
//                        Rectangle()
//                            .fill(Color(hex: "#ec1337").opacity(0.4))
//                            .frame(width: 48, height: 1)
//                            .padding(.vertical, 32)
//                        
//                        // Author
//                        Text("- \(viewModel.currentQuote.author)")
//                            .font(.system(size: 18, weight: .regular, design: .serif))
//                            .italic()
//                            .foregroundColor(Color.gray.opacity(0.6))
//                    }
//                    
//                    Spacer(minLength: 100)
//                }
//                .frame(minHeight: UIScreen.main.bounds.height)
//            }
//            .refreshable {
//                await viewModel.refreshQuote()
//            }
//            
//            VStack {
//                Spacer()
//                
//                // Actions Bar (Bottom)
//                HStack {
//                    // Share Action
//                    VStack(spacing: 8) {
//                        Button(action: {
//                            shareQuote(viewModel.currentQuote)
//                        }) {
//                            ZStack {
//                                Circle()
//                                    .fill(Color.white.opacity(0.6))
//                                    .frame(width: 56, height: 56)
//                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                                
//                                Image(systemName: "square.and.arrow.up")
//                                    .font(.system(size: 24))
//                                    .foregroundColor(Color(hex: "#1b0d10"))
//                            }
//                        }
//                        .buttonStyle(ScaleButtonStyle())
//                        
//                        Text("Share")
//                            .font(.system(size: 12, weight: .medium, design: .default))
//                            .foregroundColor(Color.gray.opacity(0.5))
//                    }
//                    
//                    Spacer()
//                    
//                    // Navigation Pills (Optional Visual Detail)
//                    HStack(spacing: 4) {
//                        Circle()
//                            .fill(Color.gray.opacity(0.8))
//                            .frame(width: 6, height: 6)
//                        Circle()
//                            .fill(Color.gray.opacity(0.4))
//                            .frame(width: 6, height: 6)
//                        Circle()
//                            .fill(Color.gray.opacity(0.4))
//                            .frame(width: 6, height: 6)
//                    }
//                    .padding(.horizontal, 4)
//                    .padding(.vertical, 4)
//                    .background(
//                        Capsule()
//                            .fill(Color.white.opacity(0.4))
//                    )
//                    .opacity(0) // Hidden on small screens as per design
//                    
//                    Spacer()
//                    
//                    // Favorite Action
//                    VStack(spacing: 8) {
//                        Button(action: {
//                            viewModel.toggleFavorite(viewModel.currentQuote)
//                        }) {
//                            ZStack {
//                                Circle()
//                                    .fill(Color.white.opacity(0.6))
//                                    .frame(width: 56, height: 56)
//                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                                
//                                Image(systemName: viewModel.isFavorite(viewModel.currentQuote) ? "heart.fill" : "heart")
//                                    .font(.system(size: 24))
//                                    .foregroundColor(viewModel.isFavorite(viewModel.currentQuote) ? Color(hex: "#ec1337") : Color(hex: "#1b0d10"))
//                            }
//                        }
//                        .buttonStyle(ScaleButtonStyle())
//                        
//                        Text("Favorite")
//                            .font(.system(size: 12, weight: .medium, design: .default))
//                            .foregroundColor(Color.gray.opacity(0.5))
//                    }
//                }
//                .padding(.horizontal, 32)
////                .padding(.bottom, 32)
//                .padding(.bottom, 100)
//                .padding(.top, 16)
//            }
//        }
//        .onAppear {
//            // Refresh quote when view appears
//            Task {
//                await viewModel.refreshQuote()
//            }
//        }
//    }
//    
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM d"
//        return formatter
//    }
//    
//    private func shareQuote(_ quote: Quote) {
//        let text = "\"\(quote.content)\" - \(quote.author)"
//        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
//        
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let rootViewController = windowScene.windows.first?.rootViewController {
//            rootViewController.present(activityVC, animated: true)
//        }
//    }
//}
//
//struct ScaleButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//struct AnimatedGradientView: View {
//    @State private var animateGradient = false
//    
//    var body: some View {
//        LinearGradient(
//            colors: [
//                Color(hex: "#FFF5F0"),
//                Color(hex: "#FDF2EC"),
//                Color(hex: "#FAE8E0")
//            ],
//            startPoint: animateGradient ? .topLeading : .bottomTrailing,
//            endPoint: animateGradient ? .bottomTrailing : .topLeading
//        )
//        .onAppear {
//            withAnimation(
//                Animation.easeInOut(duration: 15)
//                    .repeatForever(autoreverses: true)
//            ) {
//                animateGradient.toggle()
//            }
//        }
//    }
//}

//import SwiftUI
//import UIKit
//
//struct QuoteDisplayView: View {
//    @ObservedObject var viewModel: QuoteViewModel
//    @State private var currentDate = Date()
////    @State private var showShareSheet = false
////    @State private var sharedImage: UIImage?
//    // New State using the Identifiable wrapper
//        @State private var shareItem: ShareableImage?
//    @Environment(\.colorScheme) var colorScheme
//    @AppStorage("fontSize") private var fontSize: Double = 36.0
//    
//    var body: some View {
//        ZStack {
//            // Background
//            AnimatedGradientView()
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Header
//                HStack {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("TODAY")
//                            .font(.caption)
//                            .tracking(2)
//                            .foregroundColor(.red.opacity(0.8))
//                        Text(dateFormatter.string(from: currentDate))
//                            .foregroundColor(.secondary)
//                    }
//                    Spacer()
//                }
//                .padding(.horizontal)
//                .padding(.top)
//                
//                // Category Selector
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(viewModel.categories, id: \.self) { category in
//                            Button(action: {
//                                withAnimation {
//                                    viewModel.selectCategory(category)
//                                }
//                            }) {
//                                Text(category)
//                                    .font(.system(size: 14, weight: .medium))
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 16)
//                                    .background(
//                                        viewModel.selectedCategory == category
//                                        ? Color.primary
//                                        : Color.primary.opacity(0.05)
//                                    )
//                                    .foregroundColor(
//                                        viewModel.selectedCategory == category
//                                        ? (colorScheme == .dark ? .black : .white)
//                                        : .primary
//                                    )
//                                    .cornerRadius(20)
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.vertical, 10)
//                }
//                
//                // Main Content
//                ScrollView {
//                    VStack {
//                        Spacer(minLength: 20)
//                        
//                        quoteCardView
//                            .padding()
//                            .onTapGesture {
//                                Task { await viewModel.refreshQuote() }
//                            }
//                        
//                        // ⭐️ FIX 1: Huge spacer ensures content can scroll WAY up, clearing buttons
//                        Spacer(minLength: 150)
//                    }
//                    .frame(minHeight: UIScreen.main.bounds.height * 0.7) // Ensures scrollview is tall enough
//                }
//                // ⭐️ FIX 2: Refreshable acts better when attached to the list/scroll content directly
//                .refreshable {
//                    // We artificially delay slightly to ensure the animation plays nicely
//                    try? await Task.sleep(nanoseconds: 500_000_000)
//                    await viewModel.refreshQuote()
//                }
//            }
//            
//            // Floating Action Buttons
//            VStack {
//                Spacer()
//                HStack(spacing: 40) {
//                    Button(action: generateAndShareImage) {
//                        ActionIcon(name: "square.and.arrow.up", label: "Share")
//                    }
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        withAnimation {
//                            viewModel.toggleFavorite(viewModel.currentQuote)
//                        }
//                    }) {
//                        VStack {
//                            Circle()
//                                .fill(Color(uiColor: .systemBackground).opacity(0.95)) // Increased opacity
//                                .frame(width: 56, height: 56)
//                                .overlay(
//                                    Image(systemName: viewModel.isFavorite(viewModel.currentQuote) ? "heart.fill" : "heart")
//                                        .foregroundColor(viewModel.isFavorite(viewModel.currentQuote) ? .red : .primary)
//                                )
//                                .shadow(radius: 4)
//                            Text("Favorite").font(.caption).foregroundColor(.secondary)
//                        }
//                    }
//                }
////                .padding(.bottom, 10)
//                .padding(.leading, 20)
//                .padding(.trailing, 20)
//            }
//        }
////        .sheet(isPresented: $showShareSheet) {
////            if let image = sharedImage {
////                ShareSheet(items: [image])
////            }
////        }
//        // Using 'item' ensures the sheet only opens when data is ready
//                .sheet(item: $shareItem) { item in
//                    ShareSheet(items: [item.image])
//                }
//    }
//    
//    // Components
//    var quoteCardView: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "quote.opening")
//                .font(.largeTitle)
//                .foregroundColor(.green.opacity(0.6))
//            
//            Text("\"\(viewModel.currentQuote.content)\"")
//                .font(.system(size: fontSize, weight: .medium, design: .serif))
//                .multilineTextAlignment(.center)
//                .foregroundColor(.primary)
//                .padding()
//                .animation(.spring(), value: fontSize)
//                .id(viewModel.currentQuote.id)
//            
//            Text("- \(viewModel.currentQuote.author)")
//                .font(.headline)
//                .italic()
//                .foregroundColor(.secondary)
//            
//            Text(viewModel.currentQuote.category.uppercased())
//                .font(.caption2)
//                .fontWeight(.bold)
//                .foregroundColor(.secondary.opacity(0.5))
//                .padding(.top, 10)
//        }
//        .padding(40)
//        .background(Color(uiColor: .secondarySystemBackground))
//        .cornerRadius(20)
//        .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 5)
//    }
//    
////    @MainActor
////    private func generateAndShareImage() {
////        if #available(iOS 16.0, *) {
////            let renderer = ImageRenderer(content: quoteCardView.frame(width: 350, height: 450).environment(\.colorScheme, .light))
////            renderer.scale = UIScreen.main.scale
////            if let image = renderer.uiImage {
////                self.sharedImage = image
////                self.showShareSheet = true
////            }
////        } else {
////            let textToShare = "\"\(viewModel.currentQuote.content)\" - \(viewModel.currentQuote.author)"
////            let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
////            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
////               let rootVC = windowScene.windows.first?.rootViewController {
////                rootVC.present(activityVC, animated: true)
////            }
////        }
////    }
//    @MainActor
//        private func generateAndShareImage() {
//            if #available(iOS 16.0, *) {
//                let renderer = ImageRenderer(content: quoteCardView.frame(width: 350, height: 450).environment(\.colorScheme, .light))
//                renderer.scale = UIScreen.main.scale
//                
//                if let image = renderer.uiImage {
//                    // Set the item directly. This triggers the sheet automatically.
//                    self.shareItem = ShareableImage(image: image)
//                }
//            } else {
//                // ... (keep your existing fallback code) ...
//            }
//        }
//    
//    private var dateFormatter: DateFormatter {
//        let f = DateFormatter()
//        f.dateFormat = "MMMM d"
//        return f
//    }
//}

//
//
//
////MARK: THIS CODE IS WORKING FINE
//import SwiftUI
//
//struct QuoteDisplayView: View {
//    // We use the ViewModel designed for the Feed
//    @StateObject private var viewModel = QuoteViewModel()
//    
//    var body: some View {
//        NavigationView {
//            if #available(iOS 16.0, *) {
//                ZStack {
//                    // 1. Background: Your Custom Gradient
//                    AnimatedGradientView()
//                        .ignoresSafeArea()
//                    
//                    VStack(spacing: 0) {
//                        
//                        // 2. Categories (Horizontal Scroll)
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 12) {
//                                ForEach(viewModel.categories, id: \.self) { category in
//                                    CategoryPill(
//                                        title: category,
//                                        isSelected: viewModel.selectedCategory == category
//                                    ) {
//                                        withAnimation {
//                                            viewModel.selectCategory(category)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                            .padding(.vertical, 10)
//                        }
//                        
//                        // 3. Feed Content
//                        if viewModel.isLoading && viewModel.quotes.isEmpty {
//                            Spacer()
//                            ProgressView()
//                                .tint(.black)
//                            Spacer()
//                        } else if viewModel.quotes.isEmpty {
//                            // Empty State
//                            Spacer()
//                            VStack(spacing: 15) {
//                                Image(systemName: "quote.bubble")
//                                    .font(.system(size: 50))
//                                    .foregroundColor(.gray.opacity(0.5))
//                                
//                                Text("No quotes found in this\ncategory yet!")
//                                    .font(.system(.title2, design: .serif)) // ✅ Fixed: Correct font design syntax
//                                    .fontWeight(.medium)
//                                    .multilineTextAlignment(.center) // ✅ Fixed: Now inferred correctly
//                                    .foregroundColor(.black)
//                                
//                                Text("- System")
//                                    .font(.subheadline)
//                                    .italic()
//                                    .foregroundColor(.gray)
//                                
//                                Text("SYSTEM")
//                                    .font(.caption2)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.gray.opacity(0.4))
//                                    .padding(.top, 20)
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            .padding(40)
//                            Spacer()
//                        } else {
//                            // Infinite Scroll List
//                            ScrollView {
//                                LazyVStack(spacing: 20) {
//                                    ForEach(viewModel.quotes) { quote in
//                                        HomeQuoteCard(quote: quote, viewModel: viewModel)
//                                            .onAppear {
//                                                // Infinite Scroll Logic
//                                                if quote.id == viewModel.quotes.last?.id {
//                                                    Task {
//                                                        await viewModel.fetchQuotes(loadMore: true)
//                                                    }
//                                                }
//                                            }
//                                    }
//                                    
//                                    // Bottom Loading Spinner
//                                    if viewModel.isLoading {
//                                        ProgressView()
//                                            .padding()
//                                    }
//                                }
//                                .padding()
//                                .padding(.bottom, 20)
//                            }
//                            .refreshable {
//                                await viewModel.fetchQuotes(loadMore: false)
//                            }
//                        }
//                    }
//                }
//                .navigationTitle("Daily Wisdom")
//                .navigationBarTitleDisplayMode(.inline)
//                // Fix for transparent nav bar to show gradient
//                .toolbarBackground(.hidden, for: .navigationBar)
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//    }
//}
//
//// MARK: - Subviews
//
//struct CategoryPill: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.system(size: 15, weight: .medium))
//                .padding(.vertical, 10)
//                .padding(.horizontal, 24)
//                .background(isSelected ? Color.black : Color.white)
//                .foregroundColor(isSelected ? .white : .black)
//                .cornerRadius(25)
//                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
//        }
//    }
//}
//
//struct HomeQuoteCard: View {
//    let quote: Quote
//    @ObservedObject var viewModel: QuoteViewModel
//    
//    // State to hold the generated image for sharing
//    @State private var shareItem: ShareableImage?
//    @State private var showTextShareSheet = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            
//            // Quote Text
//            Text("“\(quote.content)”")
//                .font(.system(size: 20, weight: .semibold, design: .serif))
//                .foregroundColor(.black)
//                .lineSpacing(4)
//                .fixedSize(horizontal: false, vertical: true)
//            
//            // Author
//            Text("- \(quote.author)")
//                .font(.subheadline)
//                .italic()
//                .foregroundColor(.gray)
//            
//            Divider()
//                .background(Color.gray.opacity(0.2))
//                .padding(.vertical, 5)
//            
//            // Actions
//            HStack {
//                // Like Button
//                Button(action: {
//                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                    impactMed.impactOccurred()
//                    
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                        viewModel.toggleFavorite(quote)
//                    }
//                }) {
//                    Image(systemName: viewModel.isFavorite(quote) ? "heart.fill" : "heart")
//                        .font(.system(size: 20))
//                        .foregroundColor(viewModel.isFavorite(quote) ? .red : .gray)
//                }
//                
//                Spacer()
//                
//                // Share Button (Triggers image generation or fallback)
//                Button(action: {
//                    generateAndShareImage()
//                }) {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.system(size: 20))
//                        .foregroundColor(.gray)
//                }
//            }
//        }
//        .padding(20)
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
//        // ✅ Fixed: iOS 16+ Image Share Sheet
//        .sheet(item: $shareItem) { item in
//            ShareSheet(items: [item.image]) // ✅ Fixed: changed activityItems to items
//        }
//        // ✅ Fixed: iOS 15 Fallback Text Share Sheet
//        .sheet(isPresented: $showTextShareSheet) {
//            ShareSheet(items: ["“\(quote.content)” - \(quote.author)"])
//        }
//    }
//    
//    // MARK: - Image Generation Logic
//    
//    @MainActor
//    private func generateAndShareImage() {
//        // ✅ Fixed: Check if ImageRenderer is supported (iOS 16+)
//        if #available(iOS 16.0, *) {
//            let viewToRender = renderView(for: quote)
//            
//            let renderer = ImageRenderer(content: viewToRender)
//            renderer.scale = UIScreen.main.scale
//            
//            if let image = renderer.uiImage {
//                self.shareItem = ShareableImage(image: image)
//            }
//        } else {
//            // Fallback for iOS 15: Share text only
//            showTextShareSheet = true
//        }
//    }
//    
//    // The view we want to snapshot (The clean white card look)
//    private func renderView(for quote: Quote) -> some View {
//        VStack(spacing: 20) {
//            Image(systemName: "quote.opening")
//                .font(.largeTitle)
//                .foregroundColor(.green.opacity(0.6))
//            
//            Text("“\(quote.content)”")
//                .font(.system(size: 30, weight: .medium, design: .serif))
//                .multilineTextAlignment(.center)
//                .foregroundColor(.black)
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
//        .background(Color.white)
//        .cornerRadius(20)
//    }
//}
//
////MARK: ABOVE CODE IS WORKING FINE


//
//import SwiftUI
//
//struct QuoteDisplayView: View {
//    @StateObject private var viewModel = QuoteViewModel()
//    
//    // 1. Connect to the global font size setting
//    @AppStorage("fontSize") private var fontSize: Double = 21.0
//    
//    var body: some View {
//        NavigationView {
//            if #available(iOS 16.0, *) {
//                ZStack {
//                    AnimatedGradientView()
//                        .ignoresSafeArea()
//                    
//                    VStack(spacing: 0) {
//                        
//                        // Categories
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 12) {
//                                ForEach(viewModel.categories, id: \.self) { category in
//                                    CategoryPill(
//                                        title: category,
//                                        isSelected: viewModel.selectedCategory == category
//                                    ) {
//                                        withAnimation {
//                                            viewModel.selectCategory(category)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                            .padding(.vertical, 10)
//                        }
//                        
//                        // Content
//                        if viewModel.isLoading && viewModel.quotes.isEmpty {
//                            Spacer()
//                            ProgressView().tint(.black)
//                            Spacer()
//                        } else if viewModel.quotes.isEmpty {
//                            Spacer()
//                            VStack(spacing: 15) {
//                                Image(systemName: "quote.bubble")
//                                    .font(.system(size: 50))
//                                    .foregroundColor(.gray.opacity(0.5))
//                                
//                                Text("No quotes found in this\ncategory yet!")
//                                    .font(.system(.title2, design: .serif))
//                                    .fontWeight(.medium)
//                                    .multilineTextAlignment(.center)
//                                    .foregroundColor(.black)
//                                
//                                Text("- System")
//                                    .font(.system(.subheadline, design: .serif))
//                                    .italic()
//                                    .foregroundColor(.gray)
//                            }
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.white)
//                            .cornerRadius(20)
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                            .padding(40)
//                            Spacer()
//                        } else {
//                            ScrollView {
//                                LazyVStack(spacing: 20) {
//                                    ForEach(viewModel.quotes) { quote in
//                                        // Pass fontSize to the card
//                                        HomeQuoteCard(quote: quote, viewModel: viewModel, fontSize: fontSize)
//                                            .onAppear {
//                                                if quote.id == viewModel.quotes.last?.id {
//                                                    Task { await viewModel.fetchQuotes(loadMore: true) }
//                                                }
//                                            }
//                                    }
//                                    if viewModel.isLoading {
//                                        ProgressView().padding()
//                                    }
//                                }
//                                .padding()
//                                .padding(.bottom, 20)
//                            }
//                            .refreshable {
//                                await viewModel.fetchQuotes(loadMore: false)
//                            }
//                        }
//                    }
//                }
//                .navigationTitle("Daily Wisdom")
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbarBackground(.hidden, for: .navigationBar)
//            } else {
//                // Fallback for older iOS
//                Text("Requires iOS 16+")
//            }
//        }
//    }
//}
//
//// MARK: - Subviews
//
//struct CategoryPill: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.system(size: 15, weight: .medium, design: .serif)) // Applied Serif
//                .padding(.vertical, 10)
//                .padding(.horizontal, 24)
//                .background(isSelected ? Color.black : Color.white)
//                .foregroundColor(isSelected ? .white : .black)
//                .cornerRadius(25)
//                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
//        }
//    }
//}
//
//struct HomeQuoteCard: View {
//    let quote: Quote
//    @ObservedObject var viewModel: QuoteViewModel
//    
//    // Receive dynamic font size
//    var fontSize: Double
//    
//    @State private var shareItem: ShareableImage?
//    @State private var showTextShareSheet = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            
//            // Quote Text with Dynamic Size and Serif
//            Text("“\(quote.content)”")
//                .font(.system(size: fontSize, weight: .medium, design: .serif))
//                .foregroundColor(.black)
//                .lineSpacing(4)
//                .fixedSize(horizontal: false, vertical: true)
//                .animation(.spring(), value: fontSize) // Smooth resize animation
//            
//            // Author
//            Text("- \(quote.author)")
//                .font(.system(.subheadline, design: .serif))
//                .italic()
//                .foregroundColor(.gray)
//            
//            Divider()
//                .background(Color.gray.opacity(0.2))
//                .padding(.vertical, 5)
//            
//            // Actions
//            HStack {
//                Button(action: {
//                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                    impactMed.impactOccurred()
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                        viewModel.toggleFavorite(quote)
//                    }
//                }) {
//                    Image(systemName: viewModel.isFavorite(quote) ? "heart.fill" : "heart")
//                        .font(.system(size: 20))
//                        .foregroundColor(viewModel.isFavorite(quote) ? .red : .gray)
//                }
//                
//                Spacer()
//                
//                Button(action: { generateAndShareImage() }) {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.system(size: 20))
//                        .foregroundColor(.gray)
//                }
//            }
//        }
//        .padding(20)
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
//        .sheet(item: $shareItem) { item in
//            ShareSheet(items: [item.image])
//        }
//        .sheet(isPresented: $showTextShareSheet) {
//            ShareSheet(items: ["“\(quote.content)” - \(quote.author)"])
//        }
//    }
//    
//    @MainActor
//    private func generateAndShareImage() {
//        if #available(iOS 16.0, *) {
//            let viewToRender = renderView(for: quote)
//            let renderer = ImageRenderer(content: viewToRender)
//            renderer.scale = UIScreen.main.scale
//            if let image = renderer.uiImage {
//                self.shareItem = ShareableImage(image: image)
//            }
//        } else {
//            showTextShareSheet = true
//        }
//    }
//    
//    private func renderView(for quote: Quote) -> some View {
//        VStack(spacing: 20) {
//            Image(systemName: "quote.opening")
//                .font(.largeTitle)
//                .foregroundColor(.green.opacity(0.6))
//            Text("“\(quote.content)”")
//                .font(.system(size: 30, weight: .medium, design: .serif))
//                .multilineTextAlignment(.center)
//                .foregroundColor(.black)
//                .padding()
//            Text("- \(quote.author)")
//                .font(.system(.headline, design: .serif))
//                .italic()
//                .foregroundColor(.gray)
//            Text(quote.category.uppercased())
//                .font(.system(.caption2, design: .serif))
//                .fontWeight(.bold)
//                .foregroundColor(.gray.opacity(0.4))
//                .padding(.top, 10)
//            Text("Shared via QuoteVault")
//                .font(.system(.caption2, design: .serif))
//                .foregroundColor(.gray.opacity(0.3))
//                .padding(.top, 20)
//        }
//        .frame(width: 350, height: 450)
//        .background(Color.white)
//        .cornerRadius(20)
//    }
//}

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
//                .navigationTitle("Daily Wisdom")
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbarBackground(.hidden, for: .navigationBar)
                .navigationTitle("Daily Wisdom")
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        NavigationLink(destination: CollectionsListView()) {
//                            Image(systemName: "folder")
//                                .foregroundColor(.primary)
//                        }
//                    }
//                }
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
//                Button(action: { generateAndShareImage() }) {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.system(size: 20))
//                        .foregroundColor(.gray)
//                }
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
        // New Sheet for Collections
//        .sheet(isPresented: $showAddToCollectionSheet) {
//            if #available(iOS 16.0, *) {
//                AddToCollectionView(quoteId: quote.id)
//                    .presentationDetents([.medium, .large]) // Nice half-sheet effect
//            } else {
//                AddToCollectionView(quoteId: quote.id)
//            }
//        }
        // ... inside HomeQuoteCard ...

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
    
//    MARK: OLD WAY OF SHOWING BACKGROUND CARD
    
    // NOTE: The Render View stays explicitly White/Black because generated images
    // usually look best on white regardless of the user's phone theme.
//    private func renderView(for quote: Quote) -> some View {
//        VStack(spacing: 20) {
//            Image(systemName: "quote.opening")
//                .font(.largeTitle)
//                .foregroundColor(.green.opacity(0.6))
//            Text("“\(quote.content)”")
//                .font(.system(size: 30, weight: .medium, design: .serif))
//                .multilineTextAlignment(.center)
//                .foregroundColor(.black)
//                .padding()
//            Text("- \(quote.author)")
//                .font(.system(.headline, design: .serif))
//                .italic()
//                .foregroundColor(.gray)
//            Text(quote.category.uppercased())
//                .font(.system(.caption2, design: .serif))
//                .fontWeight(.bold)
//                .foregroundColor(.gray.opacity(0.4))
//                .padding(.top, 10)
//            Text("Shared via QuoteVault")
//                .font(.system(.caption2, design: .serif))
//                .foregroundColor(.gray.opacity(0.3))
//                .padding(.top, 20)
//        }
//        .frame(width: 350, height: 450)
//        .background(Color.white)
//        .cornerRadius(20)
//    }
    
//    MARK: NEW WAY FOR ADDING BACKGROUD
    
//    private func renderView(for quote: Quote) -> some View {
//        VStack(spacing: 20) {
//            Image(systemName: "quote.opening")
//                .font(.largeTitle)
//                .foregroundColor(.white.opacity(0.6)) // White for contrast
//            
//            Text("“\(quote.content)”")
//                .font(.system(size: 28, weight: .bold, design: .serif))
//                .multilineTextAlignment(.center)
//                .foregroundColor(.white) // White text
//                .padding()
//            
//            Text("- \(quote.author)")
//                .font(.system(.headline, design: .serif))
//                .italic()
//                .foregroundColor(.white.opacity(0.8))
//                
//            Text("Shared via Daily Wisdom")
//                .font(.caption2)
//                .foregroundColor(.white.opacity(0.5))
//        }
//        .frame(width: 400, height: 400)
//        // ADD THE STYLED BACKGROUND HERE:
//        .background(
//            LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
//        )
//    }
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
