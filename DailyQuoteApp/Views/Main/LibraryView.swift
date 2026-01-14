//
//  LibraryView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

import SwiftUI

struct LibraryView: View {
    @StateObject var collectionsVM = CollectionsViewModel()
    @ObservedObject var quotesVM: QuoteViewModel
    
    @State private var showingAddAlert = false
    @State private var newCollectionName = ""
    
    var body: some View {
        ZStack { // 1. Wrap in ZStack
            // 2. Add the shared background
            AnimatedGradientView()
                .ignoresSafeArea()
            
            if #available(iOS 16.0, *) {
                List {
                    // SECTION 1: SYSTEM FAVORITES
                    Section(header: Text("Saved Content").font(.subheadline).fontWeight(.semibold)) {
                        NavigationLink(destination: FavoritesDetailView(viewModel: quotesVM)) {
                            HStack(spacing: 15) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color.green)
                                    .font(.system(size: 18))
                                Text("Favorites")
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    // Make section backgrounds transparent to show gradient (Optional, purely aesthetic)
                    .listRowBackground(Color(uiColor: .systemBackground).opacity(0.8))
                    
                    // SECTION 2: CUSTOM COLLECTIONS
                    Section(header: Text("My Collections").font(.subheadline).fontWeight(.semibold)) {
                        if collectionsVM.collections.isEmpty && !collectionsVM.isLoading {
                            Text("No folders yet. Tap + to create one.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                                .listRowBackground(Color.clear) // Clear background for empty text
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
                    // Make collection rows slightly transparent
                    .listRowBackground(Color(uiColor: .systemBackground).opacity(0.8))
                }
                .scrollContentBackground(.hidden)
            } else {
                // Fallback on earlier versions
            } // 3. IMPORTANT: Hides the default flat white list background
        }
        .navigationTitle("Library")
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
    
    private func deleteCollection(at offsets: IndexSet) {
        offsets.forEach { index in
            let collection = collectionsVM.collections[index]
            Task {
                await collectionsVM.deleteCollection(id: collection.id)
            }
        }
    }
}
