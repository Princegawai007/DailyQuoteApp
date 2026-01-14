//
//  AddToCollectionView.swift
//  DailyQuoteApp
//
//  Created by Prince Gawai on 13/01/26.
//

// File: DailyQuoteApp/Views/Main/AddToCollectionView.swift
import SwiftUI

struct AddToCollectionView: View {
    let quoteId: Int // The quote we want to save
    @StateObject var viewModel = CollectionsViewModel()
    @Environment(\.dismiss) var dismiss // To close the sheet
    @ObservedObject var quotesVM: QuoteViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.collections.isEmpty {
                    Text("No collections found.")
                }
                
                ForEach(viewModel.collections) { collection in
                    Button(action: {
                        Task {
                            // 1. Add the quote to this collection
                            await viewModel.addQuoteToCollection(
                                collectionId: collection.id,
                                quoteId: quoteId
                            )
                            // 2. REFRESH the home screen icons immediately
                            await quotesVM.fetchBookmarkedStatus()
                            
                            // 3 Close the sheet
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "folder")
                            Text(collection.title)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            .navigationTitle("Save to...")
            .onAppear {
                Task { await viewModel.fetchCollections() }
            }
            .toolbar {
                Button("Cancel") { dismiss() }
            }
            // Inside AddToCollectionView.swift, under the ForEach loop
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
    }
}
