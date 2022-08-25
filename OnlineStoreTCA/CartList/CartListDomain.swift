//
//  CartListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 18/08/22.
//

import Foundation
import ComposableArchitecture

struct CartListDomain {
    struct State: Equatable {
        var cartItems: IdentifiedArrayOf<CartItemDomain.State> = []
        var totalPrice: Double = 0.0
        var confirmationAlert: AlertState<CartListDomain.Action>?
        var successAlert: AlertState<CartListDomain.Action>?
        var isPayButtonHidden = false
        
        var totalPriceString: String {
            let roundedValue = round(totalPrice * 100) / 100.0
            return "$\(roundedValue)"
        }
    }
    
    enum Action: Equatable {
        case didPressCloseButton
        case didReceivePurchaseResponse(TaskResult<String>)
        case getTotalPrice
        case didPressPayButton
        case didCancelConfirmation
        case didConfirmPurchase
        case dismissSuccessAlert
        case deleteCartItem(id: CartItemDomain.State.ID)
        case cartItem(id: CartItemDomain.State.ID, action: CartItemDomain.Action)
    }
    
    struct Environment {
        var sendOrder: ([CartItem]) async throws -> String
    }
    
    static let reducer = Reducer<
        State, Action, Environment
    >.combine(
        CartItemDomain.reducer.forEach(
            state: \.cartItems,
            action: /CartListDomain.Action.cartItem(id:action:),
            environment: { _ in CartItemDomain.Environment() }
        ),
        .init { state, action, environment in
            switch action {
            case .didPressCloseButton:
                return .none
            case .didReceivePurchaseResponse(.success(let message)):
                state.successAlert = AlertState(
                    title: TextState("Thank you!"),
                    message: TextState("Your order is in process."),
                    buttons: [
                        .default(TextState("Done"), action: .send(.dismissSuccessAlert))
                    ]
                )
                print("Success: \(message)")
                return .none
            case .didReceivePurchaseResponse(.failure):
                print("Unable to send order")
                return .none
            case .getTotalPrice:
                let items = state.cartItems.map { $0.cartItem }
                state.totalPrice = items.reduce(0.0, {
                    $0 + ($1.product.price * Double($1.quantity))
                })
                return verifyPayButtonVisibility(state: &state)
            case .didPressPayButton:
                state.confirmationAlert = AlertState(
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
                state.confirmationAlert = nil
                return .none
            case .dismissSuccessAlert:
                state.successAlert = nil
                return .none
            case .didConfirmPurchase:
                let items = state.cartItems.map { $0.cartItem }
                return .task {
                    await .didReceivePurchaseResponse(
                        TaskResult { try await environment.sendOrder(items) }
                    )
                }
            case .cartItem(let id,let action):
                switch action {
                case .deleteCartItem:
                    return .task {
                        .deleteCartItem(id: id)
                    }
                }
            case .deleteCartItem(let id):
                state.cartItems.remove(id: id)
                return Effect(value: .getTotalPrice)
            }
        }
    )
    
    private static func verifyPayButtonVisibility(
        state: inout State
    ) -> Effect<Action, Never> {
        state.isPayButtonHidden = state.totalPrice == 0.0
        return .none
    }
}
