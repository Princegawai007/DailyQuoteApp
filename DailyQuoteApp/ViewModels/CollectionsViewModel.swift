//
//  CollectionsViewModel.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import Foundation
import Supabase
import Combine

@MainActor
class CollectionsViewModel: ObservableObject {
    @Published var collections: [QuoteCollection] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 1. Fetch all collections for the user
    func fetchCollections() async {
        self.isLoading = true
        do {
            let user = try await supabase.auth.session.user
            
            let fetched: [QuoteCollection] = try await supabase
                .from("collections")
                .select()
                .eq("user_id", value: user.id)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.collections = fetched
            self.isLoading = false
        } catch {
            self.errorMessage = "Error loading collections: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    // 2. Create a new collection (e.g., "Morning Motivation")
    func createCollection(title: String) async {
        do {
            let user = try await supabase.auth.session.user
            
            // Define the data to insert
            struct NewCollection: Encodable {
                let user_id: UUID
                let title: String
            }
            
            let newCollection = NewCollection(user_id: user.id, title: title)
            
            try await supabase
                .from("collections")
                .insert(newCollection)
                .execute()
            
            // Refresh the list
            await fetchCollections()
        } catch {
            self.errorMessage = "Failed to create collection."
        }
    }
    
    func addQuoteToCollection(collectionId: UUID, quoteId: Int) async {
        do {
            // 1. Create an instance of our save model
            let itemToSave = CollectionItemInsert(collection_id: collectionId, quote_id: quoteId)
            
            // 2. Pass the struct directly to .insert()
            try await supabase
                .from("collection_items")
                .insert(itemToSave) // Swift is happy now because it knows the types!
                .execute()
            
            print("Successfully added to collection!")
            
            // Clear any previous error messages on success
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
        } catch {
            let errorString = String(describing: error)
            DispatchQueue.main.async {
                if errorString.contains("23505") {
                    self.errorMessage = "This quote is already in this collection!"
                } else {
                    self.errorMessage = "Could not save quote."
                }
            }
            print("Error adding quote: \(error)")
        }
    }
    
    func deleteCollection(id: UUID) async {
        do {
            // 1. Tell Supabase to delete the row with this ID
            try await supabase
                .from("collections")
                .delete()
                .eq("id", value: id)
                .execute()
            
            // 2. Remove it from the local list so the UI updates immediately
            DispatchQueue.main.async {
                self.collections.removeAll { $0.id == id }
            }
            print("Successfully deleted from database")
        } catch {
            print("Error deleting collection: \(error)")
            self.errorMessage = "Failed to delete from database."
        }
    }
}



// This tells Swift exactly what types to expect for the database
struct CollectionItemInsert: Encodable {
    let collection_id: UUID
    let quote_id: Int
}
