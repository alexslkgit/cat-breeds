import SwiftUI
import Domain

public struct BreedListView: View {
    @State private var viewModel: BreedListViewModel
    @State private var searchTask: Task<Void, Never>?

    public init(viewModel: BreedListViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        content
            .navigationTitle("Cat Breeds")
            .searchable(text: $viewModel.searchQuery, prompt: "Search breeds")
            .onChange(of: viewModel.searchQuery) { _, _ in
                scheduleSearch()
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
            Button("Dismiss") {
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
            Button("Try Again") {
                viewModel.errorMessage = nil
                Task { await viewModel.loadNextPage() }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            await viewModel.search()
        }
    }
}
