//
//  LibraryView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

// File: DailyQuoteApp/Views/Main/LibraryView.swift
// File: DailyQuoteApp/Views/Main/LibraryView.swift
import SwiftUI

struct LibraryView: View {
    @StateObject var collectionsVM = CollectionsViewModel()
    @ObservedObject var quotesVM: QuoteViewModel
    
    @State private var showingAddAlert = false
    @State private var newCollectionName = ""
    
    var body: some View {
        List {
            // SECTION 1: SYSTEM FAVORITES
            Section(header: Text("Saved Content").font(.subheadline).fontWeight(.semibold)) {
                NavigationLink(destination: FavoritesDetailView(viewModel: quotesVM)) {
                    HStack(spacing: 15) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color.green)
                            .font(.system(size: 18))
                        Text("Favorites")
                            .font(.body) // This matches the system font perfectly
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // SECTION 2: CUSTOM COLLECTIONS
            Section(header: Text("My Collections").font(.subheadline).fontWeight(.semibold)) {
                if collectionsVM.collections.isEmpty && !collectionsVM.isLoading {
                    Text("No folders yet. Tap + to create one.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
                
                ForEach(collectionsVM.collections) { collection in
                    NavigationLink(destination: CollectionDetailView(collection: collection)) {
                        HStack(spacing: 15) {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 18))
                            Text(collection.title)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteCollection)
            }
        }
        .navigationTitle("Library") // This creates the large, standard system title
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddAlert = true }) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(.green)
                }
            }
        }
        .onAppear {
            Task { await collectionsVM.fetchCollections() }
        }
        .alert("New Collection", isPresented: $showingAddAlert) {
            TextField("Name", text: $newCollectionName)
            Button("Cancel", role: .cancel) { }
            Button("Create") {
                Task {
                    await collectionsVM.createCollection(title: newCollectionName)
                    newCollectionName = ""
                }
            }
        }
    }
    
    // Optional: Add delete logic
    // File: DailyQuoteApp/Views/Main/LibraryView.swift

    private func deleteCollection(at offsets: IndexSet) {
        // 1. Find the collection(s) being swiped
        offsets.forEach { index in
            let collection = collectionsVM.collections[index]
            
            // 2. Call the ViewModel to delete from Supabase
            Task {
                await collectionsVM.deleteCollection(id: collection.id)
            }
        }
    }}
