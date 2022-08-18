//
//  CartDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 18/08/22.
//

import Foundation
import ComposableArchitecture

struct CartDomain {
    struct State:Equatable {
        var cartItems: [CartItem] = []
        var isCartViewOpen = false
    }
    
    enum Action {
        case fetchCartItems([CartItem])
        case didPressPurchaseButton
        case didPressCloseButton
        case fetchPurchaseResponse(TaskResult<String>)
    }
    
    struct Environment {
        var sendOrder: ([CartItem]) async throws -> String
    }
    
    static let reducer = Reducer<
        State, Action, Environment
    >
    { state, action, environment in
        switch action {
        case .fetchCartItems(let items):
            state.cartItems = items
            return .none
        case .didPressPurchaseButton:
            let items = state.cartItems
            return .task {
                await .fetchPurchaseResponse(
                    TaskResult { try await environment.sendOrder(items) }
                )
            }
        case .didPressCloseButton:
            state.isCartViewOpen = false
            return .none
        case .fetchPurchaseResponse(.success(let message)):
            print("Success: \(message)")
            return .none
        case .fetchPurchaseResponse(.failure):
            print("Unable to send order")
            return .none
        }
    }
}
