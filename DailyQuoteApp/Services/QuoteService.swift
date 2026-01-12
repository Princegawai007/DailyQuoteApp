//
//  QuoteService.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import Foundation

class QuoteService {
    static let shared = QuoteService()
    
    private let baseURL = "https://zenquotes.io/api/random"
    
    private init() {}
    
    func fetchRandomQuote() async throws -> Quote {
        guard let url = URL(string: baseURL) else {
            throw QuoteError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw QuoteError.invalidResponse
            }
            
            let quotes = try JSONDecoder().decode([Quote].self, from: data)
            
            guard let quote = quotes.first else {
                throw QuoteError.noQuote
            }
            
            return quote
        } catch {
            throw QuoteError.networkError(error)
        }
    }
}

enum QuoteError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noQuote
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noQuote:
            return "No quote found"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
