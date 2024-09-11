//
//  APIClient.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 23/08/22.
//

import Foundation
import ComposableArchitecture
import DependenciesMacros

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}


@DependencyClient
struct APIClient {
    var fetchProducts:  @Sendable () async throws -> [Product]
    var sendOrder:  @Sendable ([CartItem]) async throws -> String
    var fetchUserProfile:  @Sendable () async throws -> UserProfile
    
    struct Failure: Error, Equatable {}
}

extension APIClient: TestDependencyKey {
    static let testValue = Self()
}

// This is the "live" fact dependency that reaches into the outside world to fetch the data from network.
// Typically this live implementation of the dependency would live in its own module so that the
// main feature doesn't need to compile it.
extension APIClient: DependencyKey {
    static let liveValue = Self(
        fetchProducts: {
            let (data, _) = try await URLSession.shared
                .data(from: URL(string: "https://fakestoreapi.com/products")!)
            let products = try JSONDecoder().decode([Product].self, from: data)
            return products
        },
        sendOrder: { cartItems in
            let payload = try JSONEncoder().encode(cartItems)
            var urlRequest = URLRequest(url: URL(string: "https://fakestoreapi.com/carts")!)
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            
            let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: payload)
            
            guard let httpResponse = (response as? HTTPURLResponse) else {
                throw Failure()
            }
            
            return "Status: \(httpResponse.statusCode)"
        },
        fetchUserProfile: {
            let (data, _) = try await URLSession.shared
                .data(from: URL(string: "https://fakestoreapi.com/users/1")!)
            let profile = try JSONDecoder().decode(UserProfile.self, from: data)
            return profile
        }
    )
}
