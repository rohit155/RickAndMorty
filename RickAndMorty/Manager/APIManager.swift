//
//  RMAPI.swift
//  RickAndMartin
//
//  Created by Rohit on 17/01/25.
//

import UIKit

class APIManager: NetworkManager {
    init() {
        let baseURL = URL(string: Constants.API.baseURL)!
        super.init(baseURL: baseURL)
    }
    
    func getCharters(pageNumber: Int, completion: @escaping (Result<CharacterResponseModel, Error>) -> Void) {
        request(.character(pageNumber), completion: completion)
    }
    
    func getEpisodeDetail(episodeNumber: Int, completion: @escaping (Result<EpisodeDetail, Error>) -> Void) {
        request(.episode(episodeNumber), completion: completion)
    }
    
    func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        downloadImage(url, completion: completion)
    }
    
    func getCharacters(by name: String, pageNumber: Int, completion: @escaping (Result<CharacterResponseModel, Error>) -> Void) {
        request(.characterName(name, pageNumber), completion: completion)
    }
}

