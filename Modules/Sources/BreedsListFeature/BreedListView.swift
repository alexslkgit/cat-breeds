//
//  BreedListView.swift
//  BreedsListFeature
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import SwiftUI
import Domain

public struct BreedListView: View {
    private static let navigationTitle = "Cat Breeds"
    private static let searchPrompt = "Search breeds"
    private static let dismissTitle = "Dismiss"
    private static let tryAgainTitle = "Try Again"

    @State private var viewModel: BreedListViewModel

    public init(viewModel: BreedListViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        content
            .navigationTitle(Self.navigationTitle)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .searchable(text: $viewModel.searchQuery, prompt: Self.searchPrompt)
            .onChange(of: viewModel.searchQuery) { _, _ in
                viewModel.queryDidChange()
            }
            .task {
                if viewModel.breeds.isEmpty {
                    await viewModel.loadNextPage()
                }
            }
            .task {
                await viewModel.startObservingFavourites()
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.breeds.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.breeds.isEmpty {
            errorView(message: errorMessage)
        } else {
            list
        }
    }

    private var list: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                errorBanner(message: errorMessage)
            }

            ForEach(viewModel.breeds) { breed in
                BreedRowView(
                    breed: breed,
                    isFavourite: viewModel.favouriteIDs.contains(breed.id),
                    onToggleFavourite: { id in
                        Task { await viewModel.toggleFavourite(breedId: id) }
                    }
                )
                .onAppear {
                    if breed.id == viewModel.breeds.last?.id {
                        Task { await viewModel.loadNextPage() }
                    }
                }
            }

            if viewModel.isLoading && !viewModel.breeds.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
    }

    private func errorBanner(message: String) -> some View {
        HStack {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
            Spacer()
            Button(Self.dismissTitle) {
                viewModel.errorMessage = nil
            }
            .font(.footnote)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button(Self.tryAgainTitle) {
                viewModel.errorMessage = nil
                Task { await viewModel.loadNextPage() }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
