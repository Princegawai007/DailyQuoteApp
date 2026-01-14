//
//  QuoteService.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import Foundation
import Supabase

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
