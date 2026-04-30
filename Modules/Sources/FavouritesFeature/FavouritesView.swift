import SwiftUI
import Domain
import BreedsListFeature
import BreedDetailFeature

public struct FavouritesView: View {
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
                .navigationTitle("Favourites")
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
            VStack(spacing: 12) {
                Image(systemName: "star")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                Text("No favourites yet")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                if let message = viewModel.errorMessage {
                    HStack {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                        Spacer()
                        Button("Dismiss") {
                            viewModel.errorMessage = nil
                        }
                        .font(.footnote)
                    }
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
    }
}
