//
//  CharacterDetailViewModel.swift
//  RickAndMorty
//
//  Created by Rohit on 22/01/25.
//

import UIKit

class CharacterDetailViewModel {
    
    let apiManager = APIManager()
    let group = DispatchGroup()
    
    func fetchEpisodes(with episodeURL: [String], completion: @escaping ([EpisodeDetail]) -> Void) {
        var episodes = [EpisodeDetail]()
        let episodeNumbers: [Int] = episodeURL.compactMap{ episode in
            let component = episode.components(separatedBy: "/")
            guard let lastComponent = component.last else { return nil }
            return Int(lastComponent)
        }
        
        for episodeNumber in episodeNumbers {
            group.enter()
            apiManager.getEpisodeDetail(episodeNumber: episodeNumber, completion: { [weak self] result in
                defer { self?.group.leave() }
                
                switch result {
                case .success(let episodeDetail):
                    episodes.append(episodeDetail)
                case .failure(let failure):
                    print("FAIl: \(failure)")
                }
            })
        }
        
        group.notify(queue: .main) {
            completion(episodes)
        }
    }
    
}
