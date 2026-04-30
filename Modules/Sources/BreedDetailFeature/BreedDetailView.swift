//
//  BreedDetailView.swift
//  BreedDetailFeature
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import SwiftUI
import Domain

public struct BreedDetailView: View {
    private static let fallbackTitle = "Breed"
    private static let temperamentTitle = "Temperament"
    private static let lifeSpanTitle = "Life span"
    private static let wikipediaTitle = "Wikipedia"
    private static let tryAgainTitle = "Try Again"
    private static let addToFavouritesLabel = "Add to favourites"
    private static let removeFromFavouritesLabel = "Remove from favourites"

    private static let imageHeight: CGFloat = 240
    private static let imagePlaceholderMinHeight: CGFloat = 220
    private static let imageCornerRadius: CGFloat = 12
    private static let placeholderIconSize: CGFloat = 40
    private static let placeholderFillOpacity: Double = 0.15

    private let breedId: String
    @State private var viewModel: BreedDetailViewModel

    public init(breedId: String, viewModel: BreedDetailViewModel) {
        self.breedId = breedId
        self._viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        let view = content
            .navigationTitle(viewModel.breed?.name ?? Self.fallbackTitle)
            .toolbar {
                if viewModel.breed != nil {
                    ToolbarItem(placement: .primaryAction) {
                        favouriteButton
                    }
                }
            }
            .task {
                await viewModel.load(breedId: breedId)
            }
            .task {
                await viewModel.startObservingFavourites()
            }
        #if os(iOS)
        return view.navigationBarTitleDisplayMode(.inline)
        #else
        return view
        #endif
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.breed == nil {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let breed = viewModel.breed {
            loadedContent(breed)
        } else if let message = viewModel.errorMessage {
            errorView(message: message)
        } else {
            EmptyView()
        }
    }

    private func loadedContent(_ breed: Breed) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                image(for: breed)
                breedInfo(breed)
                if let message = viewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button(Self.tryAgainTitle) {
                viewModel.errorMessage = nil
                Task { await viewModel.load(breedId: breedId) }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var favouriteButton: some View {
        Button {
            Task { await viewModel.toggleFavourite() }
        } label: {
            Image(systemName: viewModel.isFavourite ? "star.fill" : "star")
                .foregroundStyle(viewModel.isFavourite ? Color.yellow : Color.accentColor)
                .accessibilityLabel(
                    viewModel.isFavourite ? Self.removeFromFavouritesLabel : Self.addToFavouritesLabel
                )
        }
    }

    @ViewBuilder
    private func image(for breed: Breed) -> some View {
        if let url = breed.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: Self.imagePlaceholderMinHeight)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: Self.imageHeight)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: Self.imageCornerRadius))
                case .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: Self.imageCornerRadius)
            .fill(Color.secondary.opacity(Self.placeholderFillOpacity))
            .frame(maxWidth: .infinity)
            .frame(height: Self.imageHeight)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: Self.placeholderIconSize))
                    .foregroundStyle(.secondary)
            )
    }

    @ViewBuilder
    private func breedInfo(_ breed: Breed) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            header(breed)
            if !breed.temperament.isEmpty {
                infoRow(title: Self.temperamentTitle, value: breed.temperament)
            }
            if let lifeSpan = breed.lifeSpan {
                infoRow(title: Self.lifeSpanTitle, value: Self.lifeSpanText(for: lifeSpan))
            }
            if !breed.description.isEmpty {
                Text(breed.description)
                    .font(.body)
                    .padding(.top, 4)
            }
            if let url = breed.wikipediaURL {
                wikipediaLink(url: url)
            }
        }
    }

    private func header(_ breed: Breed) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(breed.name)
                .font(.title)
                .fontWeight(.semibold)
            Text(breed.origin)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func wikipediaLink(url: URL) -> some View {
        Link(destination: url) {
            Label(Self.wikipediaTitle, systemImage: "link")
        }
        .padding(.top, 4)
    }

    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
    }

    private static func lifeSpanText(for lifeSpan: LifeSpan) -> String {
        "\(lifeSpan.minYears) - \(lifeSpan.maxYears) years"
    }
}
