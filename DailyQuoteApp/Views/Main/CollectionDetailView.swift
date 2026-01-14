//
//  CollectionDetailView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import SwiftUI
import Supabase

struct CollectionDetailView: View {
    let collection: QuoteCollection
    @State private var savedQuotes: [Quote] = []
    @State private var isLoading = true
    
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView()
//            } else if savedQuotes.isEmpty {
//                VStack(spacing: 20) {
//                    Image(systemName: "folder.badge.questionmark")
//                        .font(.largeTitle)
//                        .foregroundColor(.gray)
//                    Text("No quotes in this collection yet.")
//                        .foregroundColor(.gray)
//                }
//            } else {
//                List(savedQuotes) { quote in
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("“\(quote.content)”")
//                            .font(.system(.body, design: .serif))
//                            .fontWeight(.medium)
//                        Text("- \(quote.author)")
//                            .font(.caption)
//                            .italic()
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.vertical, 8)
//                    .onDelete(perform: deleteQuote)
//                }
//            }
//        }
//        .navigationTitle(collection.title)
//        .onAppear {
//            fetchSavedQuotes()
//        }
//    }
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if savedQuotes.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No quotes in this collection yet.")
                        .foregroundColor(.gray)
                }
            } else {
                List {
                    // IMPORTANT: .onDelete MUST be attached to ForEach
                    ForEach(savedQuotes) { quote in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("“\(quote.content)”")
                                .font(.system(.body, design: .serif))
                                .fontWeight(.medium)
                            Text("- \(quote.author)")
                                .font(.caption)
                                .italic()
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: deleteQuote) // This now works!
                }
            }
        }
        .navigationTitle(collection.title)
        .onAppear {
            fetchSavedQuotes()
        }
    }
    
    func fetchSavedQuotes() {
        Task {
            do {
                // 1. We fetch the 'collection_items' and ask Supabase to
                //    automatically join the 'quotes' table to get the actual content.
                struct ItemResponse: Decodable {
                    let quotes: Quote // Nested quote object
                }
                
                let items: [ItemResponse] = try await supabase
                    .from("collection_items")
                    .select("quotes(*)") // <--- The Magic Join
                    .eq("collection_id", value: collection.id)
                    .execute()
                    .value
                
                // 2. Unwrap the nested quotes into a flat array
                DispatchQueue.main.async {
                    self.savedQuotes = items.map { $0.quotes }
                    self.isLoading = false
                }
            } catch {
                print("Error loading collection items: \(error)")
                self.isLoading = false
            }
        }
    }
    // Inside CollectionDetailView.swift

    private func deleteQuote(at offsets: IndexSet) {
        offsets.forEach { index in
            let quoteToDelete = savedQuotes[index]
            
            Task {
                do {
                    // Remove from Supabase
                    try await supabase
                        .from("collection_items")
                        .delete()
                        .eq("collection_id", value: collection.id)
                        .eq("quote_id", value: quoteToDelete.id)
                        .execute()
                    
                    // Remove from local UI list
                    DispatchQueue.main.async {
                        savedQuotes.remove(at: index)
                    }
                } catch {
                    print("Error removing bookmark: \(error)")
                }
            }
        }
    }
}
