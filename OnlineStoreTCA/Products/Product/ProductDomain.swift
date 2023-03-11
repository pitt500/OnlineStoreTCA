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
        var addToCartState = AddToCartDomain.State()
        
        var count: Int {
            get { addToCartState.count }
            set { addToCartState.count = newValue }
        }
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
                return .none
            case .addToCart(.didTapMinusButton):
                state.addToCartState.count = max(0, state.addToCartState.count)
                return .none
            }
        }
    )
}
