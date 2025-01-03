//
//  FavoritesViewModel.swift
//  AtxHealthInspection
//
//  Created by Toph Matta on 11/18/24.
//

import SwiftUI

@MainActor
@Observable final class FavoritesViewModel {
    var favorites: Set<String> = []
    private let manager: FavoritesManager
    
    init(_ manager: FavoritesManager = FavoritesManager()) {
        self.manager = manager
        
        Task {
            favorites = await manager.getValues()
        }
    }
    
    func toggleFavorite(id: String) {
        Task {
            await manager.toggleValue(id: id)
            favorites = await manager.getValues()
        }
    }
    
    func isFavorite(_ id: String) -> Bool {
        favorites.contains(id)
    }
}
