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

import Foundation
import SwiftUI
internal import Combine

@MainActor
class QuoteViewModel: ObservableObject {
    @Published var currentQuote: Quote = Quote.fallback
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var favoriteQuotes: [Quote] = [] {
        didSet {
            saveFavorites() // Auto-save whenever the list changes
        }
    }
    
    private let quoteService = QuoteService.shared
    private let favoritesKey = "saved_favorites_v1"
    
    init() {
        loadFavorites() // Load saved data on launch
        Task {
            await refreshQuote()
        }
    }
    
    func refreshQuote() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let quote = try await quoteService.fetchRandomQuote()
            currentQuote = quote
        } catch {
            errorMessage = error.localizedDescription
            // Keep fallback quote on error, but maybe show an alert in a real app
            // currentQuote = Quote.fallback
        }
        
        isLoading = false
    }
    
    func toggleFavorite(_ quote: Quote) {
        if let index = favoriteQuotes.firstIndex(where: { $0.text == quote.text }) { // Match by text since ID changes
            favoriteQuotes.remove(at: index)
        } else {
            favoriteQuotes.append(quote)
        }
    }
    
    func isFavorite(_ quote: Quote) -> Bool {
        favoriteQuotes.contains(where: { $0.text == quote.text })
    }
    
    // MARK: - Persistence Logic
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteQuotes) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
            favoriteQuotes = decoded
        }
    }
}
