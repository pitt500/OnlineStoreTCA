//
//  PlusMinusDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import Foundation
import ComposableArchitecture

struct AddToCartDomain {
    struct State: Equatable {
        var count = 0
    }
    
    enum Action: Equatable {
        case didTapPlusButton
        case didTapMinusButton
    }
    
    struct Environment {}
    
    static let reducer = Reducer<
        State, Action, Environment
    > { state, action, environment in
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
