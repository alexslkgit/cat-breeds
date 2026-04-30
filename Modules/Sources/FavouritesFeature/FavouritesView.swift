//
//  FavouritesView.swift
//  FavouritesFeature
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import SwiftUI
import Domain
import BreedsListFeature
import BreedDetailFeature

public struct FavouritesView: View {
    private static let navigationTitle = "Favourites"
    private static let emptyTitle = "No favourites yet"
    private static let dismissTitle = "Dismiss"
    private static let averageLifespanTitle = "Average lifespan"
    private static let averageLifespanFormat = "%.1f years"

    @State private var viewModel: FavouritesViewModel
    private let makeDetailViewModel: () -> BreedDetailViewModel

    public init(
        viewModel: FavouritesViewModel,
        makeDetailViewModel: @escaping () -> BreedDetailViewModel
    ) {
        self._viewModel = State(wrappedValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle(Self.navigationTitle)
                .navigationDestination(for: String.self) { breedId in
                    BreedDetailView(breedId: breedId, viewModel: makeDetailViewModel())
                }
                .task {
                    await viewModel.load()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.breeds.isEmpty {
            ContentUnavailableView(Self.emptyTitle, systemImage: "star")
        } else {
            populatedList
        }
    }

    private var populatedList: some View {
        List {
            if let average = viewModel.averageLifespan {
                averageLifespanHeader(value: average)
            }

            if let message = viewModel.errorMessage {
                errorBanner(message: message)
            }

            ForEach(viewModel.breeds) { breed in
                BreedRowView(
                    breed: breed,
                    isFavourite: true,
                    onToggleFavourite: { id in
                        Task { await viewModel.removeFavourite(breedId: id) }
                    }
                )
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.load()
        }
    }

    private func averageLifespanHeader(value: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Self.averageLifespanTitle.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(String(format: Self.averageLifespanFormat, value))
                .font(.body)
        }
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
}
