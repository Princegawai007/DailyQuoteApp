//
//  Collection.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import Foundation

struct QuoteCollection: Identifiable, Codable {
    let id: UUID
    let title: String
    let created_at: Date
    // We don't need to decode user_id usually, as it's just for security
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case created_at
    }
}
