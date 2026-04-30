import SwiftUI
import Domain

public struct BreedRowView: View {
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

            Button {
                onToggleFavourite(breed.id)
            } label: {
                Image(systemName: isFavourite ? "star.fill" : "star")
                    .foregroundStyle(isFavourite ? Color.yellow : Color.secondary)
                    .imageScale(.large)
                    .accessibilityLabel(isFavourite ? "Remove from favourites" : "Add to favourites")
            }
            .buttonStyle(.borderless)
        }
        .contentShape(Rectangle())
    }
}
