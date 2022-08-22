//
//  ProductListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductListDomain {
    struct State: Equatable {
        var shouldOpenCart = false
        var cartState: CartDomain.State?
        var productListState: IdentifiedArrayOf<ProductDomain.State> = []
    }
    
    enum Action: Equatable {
        case fetchProducts
        case fetchProductsResponse(TaskResult<[Product]>)
        case setCartView(isPresented: Bool)
        case cart(CartDomain.Action)
        case product(id: ProductDomain.State.ID, action: ProductDomain.Action)
    }
    
    struct Environment {
        var fetchProducts: () async throws -> [Product]
        var sendOrder: ([CartItem]) async throws -> String
    }
    
    static let reducer = Reducer<
        State, Action, Environment
    >.combine(
        ProductDomain.reducer.forEach(
            state: \.productListState,
            action: /ProductListDomain.Action.product(id:action:),
            environment: { _ in ProductDomain.Environment() }
        ),
        CartDomain.reducer
            .optional()
            .pullback(
                state: \.cartState,
                action: /ProductListDomain.Action.cart,
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
                state.productListState = IdentifiedArrayOf(
                    uniqueElements: products.map {
                        ProductDomain.State(
                            id: UUID(),
                            product: $0
                        )
                    }
                )
                return .none
            case .fetchProductsResponse(.failure):
                print("Error getting products, try again later.")
                return .none
            case .cart:
                return .none
            case .setCartView(let isPresented):
                state.shouldOpenCart = isPresented
                state.cartState = isPresented
                ? CartDomain.State(
                    cartItems: state.productListState.compactMap { state in
                        state.count > 0
                        ? CartItem(
                            id: UUID(),
                            product: state.product,
                            quantity: state.count
                        )
                        : nil
                    }
                )
                : nil
                return .none
            case .product(let id, let action):
                return .none
            }
        }
    )
}
