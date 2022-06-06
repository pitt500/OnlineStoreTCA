//
//  CartDomain.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 05/06/22.
//

import Foundation
import ComposableArchitecture

struct CartDomain {
    struct State: Equatable {
        var orderAmiibos: [OrderItem] = []
    }
    
    enum Action {
        case pay
        case closeCart
    }
    
    struct Environment {}
    
    let reducer = Reducer<
        State,
        Action,
        Environment
    > { state, action, environment in
        
        switch action {
        case .pay:
            print("Pay")
            return .none
        case .closeCart:
            return .none
        }
        
    }
}
