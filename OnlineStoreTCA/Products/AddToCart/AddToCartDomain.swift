//
//  PlusMinusDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import Foundation
import ComposableArchitecture

struct AddToCartDomain: Reducer {
    struct State: Equatable {
        var count = 0
    }
    
    enum Action: Equatable {
        case didTapPlusButton
        case didTapMinusButton
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .didTapPlusButton:
            state.count += 1
            return .none
        case .didTapMinusButton:
            state.count -= 1
            return .none
        }
    }
}
