//
//  CartItemDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 22/08/22.
//

import Foundation
import ComposableArchitecture

struct CartItemDomain {
    struct State: Equatable, Identifiable {
        let id: UUID
        let cartItem: CartItem
    }
    
    enum Action: Equatable {
        case deleteCartItem(product: Product)
    }
    
    struct Environment {}
    
    static let reducer = AnyReducer<
        State, Action, Environment
    > { state, action, environment in
        switch action {
        case .deleteCartItem:
            return .none
        }
    }
}
