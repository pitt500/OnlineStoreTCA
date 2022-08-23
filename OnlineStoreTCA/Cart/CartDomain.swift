//
//  CartDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 18/08/22.
//

import Foundation
import ComposableArchitecture

struct CartDomain {
    struct State: Equatable {
        var cartItems: [CartItem] = []
        var totalPrice: Double = 0.0
        var alert: AlertState<CartDomain.Action>?
        
        var totalPriceString: String {
            let roundedValue = round(totalPrice * 100) / 100.0
            return "$\(roundedValue)"
        }
    }
    
    enum Action: Equatable {
        case fetchCartItems([CartItem])
        case didPressCloseButton
        case didReceivePurchaseResponse(TaskResult<String>)
        case getTotalPrice
        case didPressPayButton
        case didCancelConfirmation
        case didConfirmPurchase
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
        case .didPressCloseButton:
            return .none
        case .didReceivePurchaseResponse(.success(let message)):
            print("Success: \(message)")
            return .none
        case .didReceivePurchaseResponse(.failure):
            print("Unable to send order")
            return .none
        case .getTotalPrice:
            state.totalPrice = state.cartItems.reduce(0.0, {
                $0 + ($1.product.price * Double($1.quantity))
            })
            return .none
        case .didPressPayButton:
            state.alert = AlertState(
                title: TextState("Confirm your purchase"),
                message: TextState("Do you want to proceed with your purchase of \(state.totalPriceString)?"),
                buttons: [
                    .default(
                        TextState("Pay \(state.totalPriceString)"),
                        action: .send(.didConfirmPurchase)),
                    .cancel(TextState("Cancel"), action: .send(.didCancelConfirmation))
                ]
            )
            return .none
        case .didCancelConfirmation:
            state.alert = nil
            return .none
        case .didConfirmPurchase:
            let items = state.cartItems
            return .task {
                await .didReceivePurchaseResponse(
                    TaskResult { try await environment.sendOrder(items) }
                )
            }
        }
    }
}
