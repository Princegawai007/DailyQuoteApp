//
//  Quote.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import Foundation

struct Quote: Codable, Identifiable, Equatable {
    let id = UUID()
    let text: String
    let author: String
    
    enum CodingKeys: String, CodingKey {
        case text = "q"
        case author = "a"
    }
    
    // Fallback quote
    static let fallback = Quote(text: "The quieter you become, the more you are able to hear.", author: "Rumi")
}
