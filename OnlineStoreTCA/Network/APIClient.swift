//
//  APIClient.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 23/08/22.
//

import Foundation
import ComposableArchitecture

struct APIClient {
    var fetchProducts: () async throws -> [Product]
    var sendOrder: ([CartItem]) async throws -> String

  struct Failure: Error, Equatable {}
}

// This is the "live" fact dependency that reaches into the outside world to fetch the data from network.
// Typically this live implementation of the dependency would live in its own module so that the
// main feature doesn't need to compile it.
extension APIClient {
  static let live = Self(
    fetchProducts: {
        let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://fakestoreapi.com/products")!)
        let products = try JSONDecoder().decode([Product].self, from: data)
        return products
    },
    sendOrder: { cartItems in
        "OK"
    }
  )
}
