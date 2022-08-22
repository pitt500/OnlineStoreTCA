//
//  ProductDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 21/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductDomain {
    struct State: Equatable, Identifiable {
        let id: UUID
        let product: Product
        var count: Int = 0
        var addToCartState = AddToCartDomain.State()
    }
    
    enum Action: Equatable {
        case addToCart(AddToCartDomain.Action)
    }
    
    struct Environment {}
    
    static let reducer = Reducer<
        State, Action, Environment
    >.combine(
        AddToCartDomain.reducer
            .pullback(
                state: \.addToCartState,
                action: /ProductDomain.Action.addToCart,
                environment: { _ in
                    AddToCartDomain.Environment()
                }
            ),
        .init { state, action, environment in
            switch action {
            case .addToCart(.didTapPlusButton):
                state.count += 1
                return .none
            case .addToCart(.didTapMinusButton):
                state.count = max(0, state.count - 1)
                return .none
            }
        }
    )
}
