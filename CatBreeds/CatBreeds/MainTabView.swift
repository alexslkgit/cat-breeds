//
//  MainTabView.swift
//  CatBreeds
//
//  Created by Slobodianiuk Oleksandr on 29.04.2026.
//

import SwiftUI
import Domain
import BreedsListFeature
import BreedDetailFeature
import FavouritesFeature

struct MainTabView: View {
    private static let breedsTabTitle = "Breeds"
    private static let favouritesTabTitle = "Favourites"

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
                Label(Self.breedsTabTitle, systemImage: "list.bullet")
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
                Label(Self.favouritesTabTitle, systemImage: "star")
            }
        }
    }
}
