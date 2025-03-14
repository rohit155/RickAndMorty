//
//  PersistenceManager.swift
//  RickAndMorty
//
//  Created by Rohit on 21/02/25.
//

import Foundation

enum PersistenceActionType {
    case add, remove
}

enum RMError: String, Error {
    case unableToFavourite  = "There was an error favouriting the user. Please try again."
    case alreadyInFavourits = "You've already favourited this user."
}

enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let favourites = "favourites"
    }
    
    static func updateWith(favourite: Character, actionType: PersistenceActionType, completion: @escaping (RMError?) -> Void) {
        retrieveFavourites { result in
            switch result {
            case .success(var favourites):
                
                switch actionType {
                case .add:
                    guard !favourites.contains(where: { $0.name == favourite.name }) else {
                        completion(.alreadyInFavourits)
                        return
                    }
                    
                    favourites.append(favourite)
                case .remove:
                    favourites.removeAll { $0.name == favourite.name }
                }
                
                completion(save(favourites: favourites))
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    static func retrieveFavourites(completion: @escaping (Result<[Character], RMError>) -> Void) {
        guard let favouritesData = defaults.object(forKey: Keys.favourites) as? Data else {
            completion(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favourites = try decoder.decode([Character].self, from: favouritesData)
            completion(.success(favourites))
        } catch {
            completion(.failure(.unableToFavourite))
        }
    }
    
    static func save(favourites: [Character]) -> RMError? {
        do {
            let encoder = JSONEncoder()
            let encoderFavourites = try encoder.encode(favourites)
            defaults.set(encoderFavourites, forKey: Keys.favourites)
            return nil
        } catch {
            return .unableToFavourite
        }
    }
}
