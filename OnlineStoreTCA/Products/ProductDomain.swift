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
        var shouldOpenCart = false
        var cartState: CartDomain.State?
    }
    
    enum Action: Equatable {
        case fetchProducts
        case fetchProductsResponse(TaskResult<[Product]>)
        case setCartView(isPresented: Bool)
        case cart(CartDomain.Action)
    }
    
    struct Environment {
        var fetchProducts: () async throws -> [Product]
        var sendOrder: ([CartItem]) async throws -> String
    }
    
    static let reducer = Reducer<
        State, Action, Environment
    >.combine(
        CartDomain.reducer
            .optional()
            .pullback(
                state: \.cartState,
                action: /ProductDomain.Action.cart,
                environment: {
                    CartDomain.Environment(
                        sendOrder: $0.sendOrder
                    )
                }
            ),
        .init { state, action, environment in
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
            case .cart:
                return .none
            case .setCartView(let isPresented):
                print("setCartView: \(isPresented)")
                state.shouldOpenCart = isPresented
                state.cartState = isPresented
                ? CartDomain.State(cartItems: CartItem.sample)
                : nil
                return .none
            }
        }
    )
}
