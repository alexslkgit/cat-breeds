import SwiftUI
import Domain

public struct BreedDetailView: View {
    private let breedId: String
    @State private var viewModel: BreedDetailViewModel

    public init(breedId: String, viewModel: BreedDetailViewModel) {
        self.breedId = breedId
        self._viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        content
            .navigationTitle(viewModel.breed?.name ?? "Breed")
            .navigationBarTitleDisplayModeIfAvailable(.inline)
            .toolbar {
                if viewModel.breed != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            Task { await viewModel.toggleFavourite() }
                        } label: {
                            Image(systemName: viewModel.isFavourite ? "star.fill" : "star")
                                .foregroundStyle(viewModel.isFavourite ? Color.yellow : Color.accentColor)
                                .accessibilityLabel(viewModel.isFavourite ? "Remove from favourites" : "Add to favourites")
                        }
                    }
                }
            }
            .task {
                await viewModel.load(breedId: breedId)
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.breed == nil {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let breed = viewModel.breed {
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
        } else if let message = viewModel.errorMessage {
            VStack(spacing: 12) {
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button("Try Again") {
                    viewModel.errorMessage = nil
                    Task { await viewModel.load(breedId: breedId) }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func image(for breed: Breed) -> some View {
        if let url = breed.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 220)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.15))
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
            )
    }

    @ViewBuilder
    private func breedInfo(_ breed: Breed) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(breed.name)
                    .font(.title)
                    .fontWeight(.semibold)
                Text(breed.origin)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !breed.temperament.isEmpty {
                infoRow(title: "Temperament", value: breed.temperament)
            }

            if let lifeSpan = breed.lifeSpan {
                infoRow(
                    title: "Life span",
                    value: "\(lifeSpan.minYears) - \(lifeSpan.maxYears) years"
                )
            }

            if !breed.description.isEmpty {
                Text(breed.description)
                    .font(.body)
                    .padding(.top, 4)
            }

            if let url = breed.wikipediaURL {
                Link(destination: url) {
                    Label("Wikipedia", systemImage: "link")
                }
                .padding(.top, 4)
            }
        }
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
}

private extension View {
    @ViewBuilder
    func navigationBarTitleDisplayModeIfAvailable(_ mode: NavigationBarTitleDisplayModeShim) -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(mode.uiKitMode)
        #else
        self
        #endif
    }
}

private enum NavigationBarTitleDisplayModeShim {
    case inline
    case large
    case automatic

    #if os(iOS)
    var uiKitMode: NavigationBarItem.TitleDisplayMode {
        switch self {
        case .inline: return .inline
        case .large: return .large
        case .automatic: return .automatic
        }
    }
    #endif
}
