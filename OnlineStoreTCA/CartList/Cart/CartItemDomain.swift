//
//  CartItemDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 22/08/22.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CartItemDomain {
	@ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        let cartItem: CartItem
    }
    
    enum Action: Equatable {
        case deleteCartItem(product: Product)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .deleteCartItem:
            return .none
        }
    }
}
