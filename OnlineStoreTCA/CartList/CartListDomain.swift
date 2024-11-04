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
        @Presents var alert: AlertState<Action.Alert>?
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var cartItems: IdentifiedArrayOf<CartItemDomain.State> = []
        var totalPrice: Double = 0.0
        var isPayButtonDisable = false
        
        var totalPriceString: String {
            let roundedValue = round(totalPrice * 100) / 100.0
            return "$\(roundedValue)"
        }
        
        var isRequestInProcess: Bool {
            dataLoadingStatus == .loading
        }
    }
    
    enum Action: Equatable {
        case alert(PresentationAction<Alert>)
        case didPressCloseButton
        case cartItem(IdentifiedActionOf<CartItemDomain>)
        case getTotalPrice
        case didPressPayButton
        case didReceivePurchaseResponse(TaskResult<String>)
        
        enum Alert: Equatable {
            case didConfirmPurchase
            case didCancelConfirmation
            case dismissSuccessAlert
            case dismissErrorAlert
        }
    }
    
    @Dependency(\.apiClient.sendOrder) var sendOrder
    
    private func verifyPayButtonVisibility(
        state: inout State
    ) -> Effect<Action> {
        state.isPayButtonDisable = state.totalPrice == 0.0
        return .none
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case let .alert(.presented(alertAction)):
                    switch alertAction {
                        case .didConfirmPurchase:
                            state.dataLoadingStatus = .loading
                            let items = state.cartItems.map { $0.cartItem }
                            return .run { send in
                                await send(
                                    .didReceivePurchaseResponse(
                                        TaskResult{
                                            try await sendOrder(items)
                                        }
                                    )
                                )
                            }
                        case .didCancelConfirmation:
                            state.alert = nil
                            return .none
                        case .dismissSuccessAlert:
                            state.alert = nil
                            return .none
                        case .dismissErrorAlert:
                            state.alert = nil
                            return .none
                    }
				case .alert:
					return .none
                case .didPressCloseButton:
                    return .none
                case let .cartItem(.element(id: id, action: action)):
                    switch action {
                        case .deleteCartItem:
                            state.cartItems.remove(id: id)
                            return.send(.getTotalPrice)
                    }
                case .getTotalPrice:
                    let items = state.cartItems.map { $0.cartItem }
                    state.totalPrice = items.reduce(0.0, {
                        $0 + ($1.product.price * Double($1.quantity))
                    })
                    return verifyPayButtonVisibility(state: &state)
                case .didPressPayButton:
                    state.alert = .confirmationAlert(totalPriceString: state.totalPriceString)
                    return .none
                case .didReceivePurchaseResponse(.success(let message)):
                    state.dataLoadingStatus = .success
                    state.alert = .successAlert
                    print("Success: ", message)
                    return .none
                case .didReceivePurchaseResponse(.failure(let error)):
                    state.dataLoadingStatus = .error
                    state.alert = .errorAlert
                    print("Error sending your order:", error.localizedDescription)
                    return .none
            }
        }
		.ifLet(\.$alert, action: \.alert)
        .forEach(\.cartItems, action: \.cartItem) {
            CartItemDomain()
        }
    }
}

extension AlertState where Action == CartListDomain.Action.Alert {
    static func confirmationAlert(totalPriceString: String) -> AlertState {
        AlertState {
            TextState("Confirm your purchase")
        } actions: {
            ButtonState(action: .didConfirmPurchase, label: { TextState("Pay \(totalPriceString)") })
            ButtonState(role: .cancel, action: .didCancelConfirmation, label: { TextState("Cancel") })
        } message: {
            TextState("Do you want to proceed with your purchase of \(totalPriceString)?")
        }
    }
    
    static var successAlert: AlertState {
        AlertState {
            TextState("Thank you!")
        } actions: {
            ButtonState(action: .dismissSuccessAlert, label: { TextState("Done") })
        } message: {
            TextState("Your order is in process.")
        }
    }
    
    static var errorAlert: AlertState {
        AlertState {
            TextState("Oops!")
        } actions: {
            ButtonState(action: .dismissErrorAlert, label: { TextState("Done") })
        } message: {
            TextState("Unable to send order, try again later.")
        }
    }
}

