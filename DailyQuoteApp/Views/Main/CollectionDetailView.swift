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
    
    var body: some View {
        ZStack { // 1. Main container for layering
            // 2. The shared animated background
            AnimatedGradientView()
                .ignoresSafeArea()
            
            VStack {
                if isLoading {
                    ProgressView()
                        .tint(.primary) // Ensures visibility on colored backgrounds
                } else if savedQuotes.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.largeTitle)
                            .foregroundColor(.secondary) // Adaptive color looks better on gradients
                        Text("No quotes in this collection yet.")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    // Optional: Adds a subtle frosted glass effect behind the empty message
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                } else {
                    // Content List
                    if #available(iOS 16.0, *) {
                        List {
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
                                // 3. Semi-transparent card style for rows
                                .listRowBackground(Color(uiColor: .systemBackground).opacity(0.8))
                            }
                            .onDelete(perform: deleteQuote)
                        }
                        // 4. Hides the default opaque list background
                        .scrollContentBackground(.hidden)
                    } else {
                        // Fallback on earlier versions
                    }
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
                struct ItemResponse: Decodable {
                    let quotes: Quote
                }
                
                let items: [ItemResponse] = try await supabase
                    .from("collection_items")
                    .select("quotes(*)")
                    .eq("collection_id", value: collection.id)
                    .execute()
                    .value
                
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
                        if savedQuotes.indices.contains(index) {
                            savedQuotes.remove(at: index)
                        }
                    }
                } catch {
                    print("Error removing bookmark: \(error)")
                }
            }
        }
    }
}
