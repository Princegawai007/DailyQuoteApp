//
//  Quote.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 12/01/26.
//

import Foundation

//struct Quote: Codable, Identifiable, Equatable {
//    let id = UUID()
//    let text: String
//    let author: String
//    
//    enum CodingKeys: String, CodingKey {
//        case text = "q"
//        case author = "a"
//    }
//    
//    // Fallback quote
//    static let fallback = Quote(text: "The quieter you become, the more you are able to hear.", author: "Rumi")
//}
import Foundation

struct Quote: Identifiable, Codable {
    var id: Int?
    let content: String  // This used to be 'text', now it is 'content' to match DB
    let author: String
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case id, content, author, category
    }
    
    // Fix: Add this fallback quote for when the app first loads
    static let fallback = Quote(
        id: 0,
        content: "Believe you can and you're halfway there.",
        author: "Theodore Roosevelt",
        category: "Motivation"
    )
}
