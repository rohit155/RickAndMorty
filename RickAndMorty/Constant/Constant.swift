//
//  Constant.swift
//  RickAndMartin
//
//  Created by Rohit on 17/01/25.
//

// Global Constants
enum Constants {
    // API URL
    enum API {
        static let baseURL = "https://rickandmortyapi.com/api/"
    }
    
    enum string {
        static let episodes = "EPISODES"
    }
    
    enum characterStatus {
        static let alive = "Alive"
    }
    
    enum Identifier {
        static let cell = "cell"
    }
    
    static let titleCharacters = "Characters"
    static let titleFavourites = "Favourites"
    static let characterFavourited = "Character has  been favourited! ⭐"
    static let characterAlreayFavourited = "Character has already been favourited! 🔄"
    static let noCharterFavourited = "No character has been favourited! 🥺"
    static let loading = "Loading..."
}

enum ToastPosition {
    case top, center, bottom
}
