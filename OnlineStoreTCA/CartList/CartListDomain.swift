//
//  CartListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 18/08/22.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CartListDomain {
    @ObservableState
    struct State: Equatable {
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var cartItems: IdentifiedArrayOf<CartItemDomain.State> = []
        var totalPrice: Double = 0.0
        var isPayButtonDisable = false
        @Presents var confirmationAlert: AlertState<Action.Alert>?
        @Presents var errorAlert: AlertState<Action.Alert>?
        @Presents var successAlert: AlertState<Action.Alert>?
        
        var totalPriceString = "0.0"
        
        var isRequestInProcess: Bool {
            dataLoadingStatus == .loading
        }
    }
    
    enum Action: Equatable {
        case didPressCloseButton
        case cartItems(IdentifiedActionOf<CartItemDomain>)
        case getTotalPrice
        case didPressPayButton
        case didReceivePurchaseResponse(TaskResult<String>)
        case alert(PresentationAction<Alert>)
        
        enum Alert: Equatable {
            case confirmPurchase
            case cancelPurchase
            case dismissSuccessAlert
            case dismissErrorAlert
        }
    }
    
    let sendOrder: ([CartItem]) async throws -> String
    
    private func verifyPayButtonVisibility(
        state: inout State
    ) -> Effect<Action> {
        state.isPayButtonDisable = state.totalPrice == 0.0
        return .none
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didPressCloseButton:
                return .none
            case .cartItems(.element(let id, let action)):
                switch action {
                case .deleteCartItem:
                    state.cartItems.remove(id: id)
                    return .send(.getTotalPrice)
                }
            case .getTotalPrice:
                let items = state.cartItems.map { $0.cartItem }
                state.totalPrice = items.reduce(0.0, {
                    $0 + ($1.product.price * Double($1.quantity))
                })
                state.totalPriceString = priceToString(price: state.totalPrice)
                return verifyPayButtonVisibility(state: &state)
            case .didPressPayButton:
                state.confirmationAlert = AlertState {
                    TextState("Confirm your purchase")
                } actions: {
                    ButtonState(action: .confirmPurchase) {
                        TextState("Pay \(state.totalPriceString)")
                    }
                    ButtonState(role: .cancel, action: .cancelPurchase) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Do you want to proceed with your purchase?")
                }
                
                
                return .none
            case .didReceivePurchaseResponse(.success(let message)):
                state.dataLoadingStatus = .success
                state.successAlert = AlertState {
                    TextState("Thank you!")
                } actions: {
                    ButtonState(action: .dismissSuccessAlert) {
                        TextState("Done")
                    }
                } message: {
                    TextState("Your order is in process.")
                }
                
                print("Success: ", message)
                return .none
            case .didReceivePurchaseResponse(.failure(let error)):
                state.dataLoadingStatus = .error
                state.errorAlert = AlertState {
                    TextState("Oops!")
                } actions: {
                    ButtonState(action: .dismissErrorAlert) {
                        TextState("Done")
                    }
                } message: {
                    TextState("Unable to send order, try again later.")
                }
                
                print("Error sending your order:", error.localizedDescription)
                return .none
            case .alert(let action):
                switch action {
                case .presented(.confirmPurchase):
                    state.dataLoadingStatus = .loading
                    let items = state.cartItems.map { $0.cartItem }
                    return .run { send in
                        
                        do {
                            let response = try await sendOrder(items)
                            await send(
                                .didReceivePurchaseResponse(.success(response))
                            )
                        } catch {
                            await send(.didReceivePurchaseResponse(.failure(error)))
                        }
                    }
                case .presented(.cancelPurchase):
                    state.confirmationAlert = nil
                    return .none
                    
                case .presented(.dismissSuccessAlert):
                    state.successAlert = nil
                    return .none
                case .presented(.dismissErrorAlert):
                    state.errorAlert = nil
                    return .none
                case .dismiss:
                    return .none
                }
            }
        }
        .forEach(\.cartItems, action: \.cartItems) {
            CartItemDomain()
        }
    }
    
    private func priceToString(price: Double) -> String {
        let roundedValue = round(price * 100) / 100.0
        return "$\(roundedValue)"
    }
}

