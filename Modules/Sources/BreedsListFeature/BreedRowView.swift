//
//  BreedRowView.swift
//  BreedsListFeature
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import SwiftUI
import Domain

public struct BreedRowView: View {
    private static let addToFavouritesLabel = "Add to favourites"
    private static let removeFromFavouritesLabel = "Remove from favourites"

    private static let thumbnailSize: CGFloat = 56
    private static let thumbnailCornerRadius: CGFloat = 8
    private static let placeholderIconSize: CGFloat = 18
    private static let placeholderFillOpacity: Double = 0.15

    private let breed: Breed
    private let isFavourite: Bool
    private let onToggleFavourite: (String) -> Void

    public init(
        breed: Breed,
        isFavourite: Bool,
        onToggleFavourite: @escaping (String) -> Void
    ) {
        self.breed = breed
        self.isFavourite = isFavourite
        self.onToggleFavourite = onToggleFavourite
    }

    public var body: some View {
        HStack(spacing: 12) {
            NavigationLink(value: breed.id) {
                HStack(spacing: 12) {
                    thumbnail(for: breed)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(breed.name)
                            .font(.headline)
                        Text(breed.origin)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(breed.temperament)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Button {
                onToggleFavourite(breed.id)
            } label: {
                Image(systemName: isFavourite ? "star.fill" : "star")
                    .foregroundStyle(isFavourite ? Color.yellow : Color.secondary)
                    .imageScale(.large)
                    .accessibilityLabel(
                        isFavourite ? Self.removeFromFavouritesLabel : Self.addToFavouritesLabel
                    )
            }
            .buttonStyle(.borderless)
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func thumbnail(for breed: Breed) -> some View {
        if let url = breed.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: Self.thumbnailCornerRadius))
                case .failure:
                    placeholderThumbnail
                @unknown default:
                    placeholderThumbnail
                }
            }
        } else {
            placeholderThumbnail
        }
    }

    private var placeholderThumbnail: some View {
        RoundedRectangle(cornerRadius: Self.thumbnailCornerRadius)
            .fill(Color.secondary.opacity(Self.placeholderFillOpacity))
            .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: Self.placeholderIconSize))
                    .foregroundStyle(.secondary)
            )
    }
}
