//
//  QuoteViewModel.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

//import Foundation
//import SwiftUI
//internal import Combine
//
//@MainActor
//class QuoteViewModel: ObservableObject {
//    @Published var currentQuote: Quote = Quote.fallback
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    
//    @Published var favoriteQuotes: [Quote] = []
//    
//    private let quoteService = QuoteService.shared
//    
//    init() {
//        Task {
//            await refreshQuote()
//        }
//    }
//    
//    func refreshQuote() async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            let quote = try await quoteService.fetchRandomQuote()
//            currentQuote = quote
//        } catch {
//            errorMessage = error.localizedDescription
//            // Keep fallback quote on error
//            currentQuote = Quote.fallback
//        }
//        
//        isLoading = false
//    }
//    
//    func toggleFavorite(_ quote: Quote) {
//        if let index = favoriteQuotes.firstIndex(where: { $0.id == quote.id }) {
//            favoriteQuotes.remove(at: index)
//        } else {
//            favoriteQuotes.append(quote)
//        }
//    }
//    
//    func isFavorite(_ quote: Quote) -> Bool {
//        favoriteQuotes.contains(where: { $0.id == quote.id })
//    }
//}


// MARK: GEMINI PRO VERSION
//
//  QuoteViewModel.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

//import Foundation
//import SwiftUI
//import Combine
//internal import Auth
//
//@MainActor
//class QuoteViewModel: ObservableObject {
//    @Published var currentQuote: Quote = Quote.fallback
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    @Published var favoriteQuotes: [Quote] = []
//    
//    // New: Selected Category
//    @Published var selectedCategory: String = "All"
//    
//    // ⚠️ IMPORTANT: These must match your Supabase "category" column EXACTLY.
//    // Based on your screenshots, they are Capitalized.
//    let categories = ["All", "Motivation", "Love", "Wisdom", "Success", "Humor"]
//    
//    private let quoteService = QuoteService.shared
//    
//    init() {
//        Task {
//            await refreshQuote()
//            await loadFavorites()
//        }
//    }
//    
//    //    func refreshQuote() async {
//    //        isLoading = true
//    //        errorMessage = nil
//    //        do {
//    //            // Pass the selected category to the service
//    //            let quote = try await quoteService.fetchRandomQuote(category: selectedCategory)
//    //            currentQuote = quote
//    //        } catch {
//    //            errorMessage = error.localizedDescription
//    //            print("Error fetching quote: \(error)") // Check your Xcode Console if this happens!
//    //            
//    //            // Fallback UI
//    //            if selectedCategory != "All" {
//    //                currentQuote = Quote(id: 0, content: "No quotes found for '\(selectedCategory)'. Check spelling in Supabase!", author: "System", category: "System")
//    //            }
//    //        }
//    //        isLoading = false
//    //    }
//    
//    func refreshQuote() async {
//        // Do NOT set isLoading = true here. It kills the pull-to-refresh animation.
//        errorMessage = nil
//        do {
//            let quote = try await quoteService.fetchRandomQuote(category: selectedCategory)
//            
//            // Only update if we got a valid quote
//            if quote.id != 0 {
//                // Ensure UI updates on main thread
//                await MainActor.run {
//                    self.currentQuote = quote
//                }
//            }
//        } catch {
//            let nsError = error as NSError
//            if nsError.code == -999 {
//                return // Ignore cancellations
//            }
//            errorMessage = error.localizedDescription
//            print("Error: \(error)")
//        }
//    }
//    
//    // Change category and refresh immediately
//    func selectCategory(_ category: String) {
//        selectedCategory = category
//        Task {
//            await refreshQuote()
//        }
//    }
//    
//    // MARK: - Favorites Logic
//    func loadFavorites() async {
//        guard let userId = AuthService.shared.userSession?.user.id else { return }
//        do {
//            let cloudFavorites = try await quoteService.fetchFavorites(userId: userId)
//            self.favoriteQuotes = cloudFavorites
//        } catch {
//            print("Error loading favorites: \(error)")
//        }
//    }
//    
//    func toggleFavorite(_ quote: Quote) {
//        guard let userId = AuthService.shared.userSession?.user.id,
//              let quoteId = quote.id else { return }
//        
//        if isFavorite(quote) {
//            favoriteQuotes.removeAll { $0.id == quote.id }
//            Task.detached(priority: .userInitiated) {
//                try? await QuoteService.shared.removeFavorite(quoteId: quoteId, userId: userId)
//            }
//        } else {
//            favoriteQuotes.append(quote)
//            Task.detached(priority: .userInitiated) {
//                try? await QuoteService.shared.addFavorite(quoteId: quoteId, userId: userId)
//            }
//        }
//    }
//    
//    func isFavorite(_ quote: Quote) -> Bool {
//        return favoriteQuotes.contains(where: { $0.id == quote.id })
//    }
//}


import Foundation
import SwiftUI
import Combine
internal import Auth
internal import PostgREST
import Supabase

@MainActor
class QuoteViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var quotes: [Quote] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var favoriteQuotes: [Quote] = []
    @Published var quoteOfTheDay: Quote?
    @Published var bookmarkedQuoteIds: Set<Int> = []
    
    // Category Filter
    @Published var selectedCategory: String = "All"
    let categories = ["All", "Motivation", "Love", "Wisdom", "Success", "Humor"]
    
    // MARK: - Pagination State
    private var currentPage = 0
    private let limit = 20
    private var canLoadMore = true
    
    // Dependencies
    private let authService = AuthService.shared
    private let quoteService = QuoteService.shared
    
    // MARK: - Init
    init() {
        Task {
            await fetchQuotes() // Initial fetch
            await loadFavorites()
        }
    }
    
    // MARK: - Fetch Logic
    func fetchQuotes(loadMore: Bool = false) async {
        guard !isLoading else { return }
        if loadMore && !canLoadMore { return }
        
        isLoading = true
        errorMessage = nil
        
        if !loadMore {
            currentPage = 0
            canLoadMore = true
        }
        
        do {
            // FIX: Call the Service instead of AuthService.supabase
            let newQuotes = try await quoteService.fetchQuotes(
                page: currentPage,
                limit: limit,
                category: selectedCategory
            )
            
            await MainActor.run {
                if loadMore {
                    self.quotes.append(contentsOf: newQuotes)
                } else {
                    self.quotes = newQuotes
                }
                
                self.canLoadMore = newQuotes.count == limit
                if self.canLoadMore {
                    self.currentPage += 1
                }
                
                self.isLoading = false
            }
            
        } catch {
            let nsError = error as NSError
            if nsError.code == -999 {
                isLoading = false
                return
            }
            
            print("Error fetching quotes: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Category Selection
    func selectCategory(_ category: String) {
        guard selectedCategory != category else { return }
        selectedCategory = category
        
        // Reset and fetch
        quotes = []
        currentPage = 0
        canLoadMore = true
        
        Task {
            await fetchQuotes()
        }
    }
    
    // MARK: - Favorites Logic
    func loadFavorites() async {
        guard let userId = authService.userSession?.user.id else { return }
        do {
            let cloudFavorites = try await quoteService.fetchFavorites(userId: userId)
            self.favoriteQuotes = cloudFavorites
        } catch {
            print("Error loading favorites: \(error)")
        }
    }
    
//    func toggleFavorite(_ quote: Quote) {
//        guard let userId = authService.userSession?.user.id,
//              let quoteId = quote.id else { return }
//        
//        if isFavorite(quote) {
//            favoriteQuotes.removeAll { $0.id == quote.id }
//            Task.detached(priority: .userInitiated) {
//                try? await QuoteService.shared.removeFavorite(quoteId: quoteId, userId: userId)
//            }
//        } else {
//            favoriteQuotes.append(quote)
//            Task.detached(priority: .userInitiated) {
//                try? await QuoteService.shared.addFavorite(quoteId: quoteId, userId: userId)
//            }
//        }
//    }
    func toggleFavorite(_ quote: Quote) {
        guard let userId = authService.userSession?.user.id,
              let quoteId = quote.id else { return }
        
        // Use withAnimation for the "Real-time" feel
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if isFavorite(quote) {
                // Remove locally
                favoriteQuotes.removeAll { $0.id == quote.id }
                
                // Sync with Database in background
                Task { try? await QuoteService.shared.removeFavorite(quoteId: quoteId, userId: userId) }
            } else {
                // Add locally
                favoriteQuotes.append(quote)
                
                // Sync with Database in background
                Task { try? await QuoteService.shared.addFavorite(quoteId: quoteId, userId: userId) }
            }
        }
    }
    
    func isFavorite(_ quote: Quote) -> Bool {
        return favoriteQuotes.contains(where: { $0.id == quote.id })
    }
    
    func fetchQuoteOfTheDay() async {
        do {
            // 1. Fetch a pool of quotes (or all quotes)
            let allQuotes: [Quote] = try await supabase
                .from("quotes")
                .select()
                .execute()
                .value
            
            if !allQuotes.isEmpty {
                // 2. Use the current date to create a stable index
                let calendar = Calendar.current
                let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
                
                // 3. Pick a quote based on the day (it will be the same all day)
                let index = dayOfYear % allQuotes.count
                self.quoteOfTheDay = allQuotes[index]
            }
        } catch {
            print("Error fetching daily quote: \(error)")
        }
    }
    
    func fetchBookmarkedStatus() async {
        do {
            // We only need the quote_ids from the collection_items table
            struct BookmarkResponse: Decodable { let quote_id: Int }
            
            let response: [BookmarkResponse] = try await supabase
                .from("collection_items")
                .select("quote_id")
                .execute()
                .value
            
            DispatchQueue.main.async {
                self.bookmarkedQuoteIds = Set(response.map { $0.quote_id })
            }
        } catch {
            print("Error fetching bookmarks: \(error)")
        }
    }
    
    func refreshBookmarks() {
        Task {
            await fetchBookmarkedStatus()
        }
    }
}
