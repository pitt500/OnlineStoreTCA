//
//  ProductDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductDomain {
    struct State: Equatable {
        var products: [Product] = []
    }
    
    enum Action: Equatable {
        case fetchProducts
        case fetchProductsResponse(TaskResult<[Product]>)
    }
    
    struct Environment {
        var fetchProducts: () async throws -> [Product]
    }
    
    static let reducer = Reducer<
        State, Action, Environment
    > { state, action, environment in
        switch action {
        case .fetchProducts:
            return .task {
                await .fetchProductsResponse(
                    TaskResult { try await environment.fetchProducts() }
                )
            }
        case .fetchProductsResponse(.success(let products)):
            state.products = products
            return .none
        case .fetchProductsResponse(.failure):
            print("Error getting products, try again later.")
            return .none
        }
    }
}
