//
//  NetworkService.swift
//  RickAndMartin
//
//  Created by Rohit on 17/01/25.
//

import UIKit

// Protocol for making network requests
protocol NetworkService {
    func request<T: Codable>(_ endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void)
    func downloadImage(_ urlString: String, completion: @escaping (UIImage?) -> Void)
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

enum Endpoint {
    case character(Int)
    case episode(Int)
    case characterName(String, Int)
    
    // Define the HTTP method for each endpoint
    var method: HTTPMethod {
        switch self {
        default:
            return .GET
        }
    }
    
    // Path for the endpoint
    var path: String {
        switch self {
        case .character: return "/character"
        case .episode(let episodeNumber): return "/episode/\(episodeNumber)"
        case .characterName: return "/character"
        }
    }
    
    // Parameters for the request (query parameters for GET, body for POST)
    var parameters: [String: Any] {
        switch self {
        case .character(let pageNumber): return ["page":pageNumber]
        case .episode: return [:]
        case .characterName(let characterName, let pageNumber): return ["name": characterName, "page": pageNumber]
        }
    }
}
