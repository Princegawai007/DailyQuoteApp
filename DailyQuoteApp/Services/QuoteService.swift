//
//  QuoteService.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

//import Foundation
//
//class QuoteService {
//    static let shared = QuoteService()
//    
//    private let baseURL = "https://zenquotes.io/api/random"
//    
//    private init() {}
//    
//    func fetchRandomQuote() async throws -> Quote {
//        guard let url = URL(string: baseURL) else {
//            throw QuoteError.invalidURL
//        }
//        
//        do {
//            let (data, response) = try await URLSession.shared.data(from: url)
//            
//            guard let httpResponse = response as? HTTPURLResponse,
//                  httpResponse.statusCode == 200 else {
//                throw QuoteError.invalidResponse
//            }
//            
//            let quotes = try JSONDecoder().decode([Quote].self, from: data)
//            
//            guard let quote = quotes.first else {
//                throw QuoteError.noQuote
//            }
//            
//            return quote
//        } catch {
//            throw QuoteError.networkError(error)
//        }
//    }
//}
//
//enum QuoteError: Error, LocalizedError {
//    case invalidURL
//    case invalidResponse
//    case noQuote
//    case networkError(Error)
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "Invalid URL"
//        case .invalidResponse:
//            return "Invalid response from server"
//        case .noQuote:
//            return "No quote found"
//        case .networkError(let error):
//            return "Network error: \(error.localizedDescription)"
//        }
//    }
//}

//import Foundation
//import Supabase
//
//class QuoteService {
//    static let shared = QuoteService()
//    
//    // Fetch quotes, optionally filtered by a category
//    func fetchQuotes(category: String? = nil) async throws -> [Quote] {
//        var query = supabase.from("quotes").select()
//        
//        // Only apply filter if category is NOT "All" and NOT nil
//        if let category = category, category != "All" {
//            // Note: This matches exactly. If your DB has "motivation" (lowercase),
//            // and you search "Motivation" (uppercase), it might fail.
//            // Check your Supabase table to ensure case matches!
//            query = query.eq("category", value: category)
//        }
//        
//        let quotes: [Quote] = try await query.execute().value
//        return quotes
//    }
//    
//    // Fetch a single random quote
//    func fetchRandomQuote(category: String? = nil) async throws -> Quote {
//        let quotes = try await fetchQuotes(category: category)
//        
//        guard !quotes.isEmpty else {
//            // Throw a specific error if empty so ViewModel knows
//            throw NSError(domain: "QuoteService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No quotes found for category: \(category ?? "All")"])
//        }
//        
//        guard let randomQuote = quotes.randomElement() else {
//            return Quote.fallback
//        }
//        return randomQuote
//    }
//    
//    // MARK: - Favorites
//    
//    func addFavorite(quoteId: Int, userId: UUID) async throws {
//        let data: [String: AnyEncodable] = [
//            "user_id": AnyEncodable(userId),
//            "quote_id": AnyEncodable(quoteId)
//        ]
//        try await supabase.from("favorites").insert(data).execute()
//    }
//    
//    func removeFavorite(quoteId: Int, userId: UUID) async throws {
//        try await supabase.from("favorites").delete()
//            .eq("user_id", value: userId)
//            .eq("quote_id", value: quoteId)
//            .execute()
//    }
//    
//    func fetchFavorites(userId: UUID) async throws -> [Quote] {
//        struct FavoriteResponse: Decodable {
//            let quote: Quote
//        }
//        
//        let response: [FavoriteResponse] = try await supabase
//            .from("favorites")
//            .select("quote:quotes(*)")
//            .eq("user_id", value: userId)
//            .execute()
//            .value
//        
//        return response.map { $0.quote }
//    }
//}
//
//struct AnyEncodable: Encodable {
//    let value: Encodable
//    func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
//    init(_ value: Encodable) { self.value = value }
//}

import Foundation
import Supabase

// Helper struct for decoding the "Join" table (Favorites + Quote)
struct FavoriteResponse: Decodable {
    let quote: Quote
}

// Helper for encoding dynamic data (Keep this if you use it, or use Supabase's built-in support)
struct AnyEncodable: Encodable {
    let value: Encodable
    func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
    init(_ value: Encodable) { self.value = value }
}

class QuoteService {
    static let shared = QuoteService()
    
    // Initialize the Supabase Client securely here
    // This fixes the "Value of type 'AuthService' has no member 'supabase'" errors
    let client = SupabaseClient(
        supabaseURL: Secrets.supabaseURL,
        supabaseKey: Secrets.supabaseKey
    )
    
    private init() {}
    
    // MARK: - 1. Infinite Scroll Fetch (The New Requirement)
    
    // In QuoteService.swift

        func fetchQuotes(page: Int, limit: Int, category: String) async throws -> [Quote] {
            // 1. Calculate Range
            let start = page * limit
            let end = start + limit - 1
            
            // 2. Start the query with the Table and Select
            // We capture the "FilterBuilder" type here
            var query = client.from("quotes").select()
            
            // 3. Apply Filters FIRST (Before Order/Range)
            if category != "All" {
                query = query.eq("category", value: category)
            }
            
            // 4. Apply Transforms LAST (Order -> Range -> Execute)
            // We chain these directly at the end to avoid type mismatch errors
            let quotes: [Quote] = try await query
                .order("created_at", ascending: false)
                .range(from: start, to: end)
                .execute()
                .value
                
            return quotes
        }
    
    // MARK: - 2. Random Quote (Legacy Support)
    
    func fetchRandomQuote(category: String? = nil) async throws -> Quote {
        // We fetch just 1 item to be efficient
        var query = client.from("quotes").select()
        
        if let category = category, category != "All" {
            query = query.eq("category", value: category)
        }
        
        // In a real app, you might use a random DB function, but this works for now
        let quotes: [Quote] = try await query.limit(1).execute().value
        
        guard let quote = quotes.first else {
             throw NSError(domain: "QuoteService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No quotes found"])
        }
        return quote
    }
    
    // MARK: - 3. Favorites (Your Existing Logic Preserved)
    
    func addFavorite(quoteId: Int, userId: UUID) async throws {
        let data: [String: AnyEncodable] = [
            "user_id": AnyEncodable(userId),
            "quote_id": AnyEncodable(quoteId)
        ]
        // Note: Using "favorites" table as per your code.
        try await client.from("favorites").insert(data).execute()
    }
    
    func removeFavorite(quoteId: Int, userId: UUID) async throws {
        try await client.from("favorites").delete()
            .eq("user_id", value: userId)
            .eq("quote_id", value: quoteId)
            .execute()
    }
    
    func fetchFavorites(userId: UUID) async throws -> [Quote] {
        // Using the join syntax to fetch the actual Quote data
        let response: [FavoriteResponse] = try await client
            .from("favorites")
            .select("quote:quotes(*)") // This assumes your Foreign Key is named 'quote_id' linking to 'quotes'
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return response.map { $0.quote }
    }
}
