//
//  ProductDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 21/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductDomain: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        let product: Product
        var addToCartState = AddToCartDomain.State()
        
        var count: Int {
            addToCartState.count
        }
    }
    
    enum Action: Equatable {
        case addToCart(AddToCartDomain.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.addToCartState, action: /Action.addToCart) {
            AddToCartDomain()
        }
        Reduce { state, action in
            switch action {
            case .addToCart(.didTapPlusButton):
                return .none
            case .addToCart(.didTapMinusButton):
                state.addToCartState.count = max(0, state.addToCartState.count)
                return .none
            }
        }
    }
}
