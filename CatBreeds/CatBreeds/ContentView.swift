import SwiftUI
import Domain
import BreedsListFeature
import BreedDetailFeature
import FavouritesFeature

struct ContentView: View {
    let breedRepository: BreedRepository
    let favouritesStore: FavouritesStore

    var body: some View {
        TabView {
            NavigationStack {
                BreedListView(
                    viewModel: BreedListViewModel(
                        breedRepository: breedRepository,
                        favouritesStore: favouritesStore
                    )
                )
                .navigationDestination(for: String.self) { breedId in
                    BreedDetailView(
                        breedId: breedId,
                        viewModel: BreedDetailViewModel(
                            breedRepository: breedRepository,
                            favouritesStore: favouritesStore
                        )
                    )
                }
            }
            .tabItem {
                Label("Breeds", systemImage: "list.bullet")
            }

            FavouritesView(
                viewModel: FavouritesViewModel(
                    breedRepository: breedRepository,
                    favouritesStore: favouritesStore
                ),
                makeDetailViewModel: {
                    BreedDetailViewModel(
                        breedRepository: breedRepository,
                        favouritesStore: favouritesStore
                    )
                }
            )
            .tabItem {
                Label("Favourites", systemImage: "star")
            }
        }
    }
}
