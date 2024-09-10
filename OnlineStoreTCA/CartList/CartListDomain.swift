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
	struct State: Equatable {
		var dataLoadingStatus = DataLoadingStatus.notStarted
		var cartItems: IdentifiedArrayOf<CartItemDomain.State> = []
		var totalPrice: Double = 0.0
		var isPayButtonDisable = false
		var confirmationAlert: AlertState<Action>?
		var errorAlert: AlertState<Action>?
		var successAlert: AlertState<Action>?
		
		var totalPriceString: String {
			let roundedValue = round(totalPrice * 100) / 100.0
			return "$\(roundedValue)"
		}
		
		var isRequestInProcess: Bool {
			dataLoadingStatus == .loading
		}
	}
	
	enum Action: Equatable {
		case didPressCloseButton
		case cartItem(id: CartItemDomain.State.ID, action: CartItemDomain.Action)
		case getTotalPrice
		case didPressPayButton
		case didReceivePurchaseResponse(TaskResult<String>)
		case didConfirmPurchase
		case didCancelConfirmation
		case dismissSuccessAlert
		case dismissErrorAlert
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
				case .didPressCloseButton:
					return .none
				case .cartItem(let id, let action):
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
					state.confirmationAlert = AlertState(
						title: TextState("Confirm your purchase"),
						message: TextState("Do you want to proceed with your purchase of \(state.totalPriceString)?"),
						buttons: [
							.default(
								TextState("Pay \(state.totalPriceString)"),
								action: .send(.didConfirmPurchase)
							),
							.cancel(
								TextState("Cancel"),
								action: .send(.didCancelConfirmation)
							)
						]
					)
					return .none
				case .didCancelConfirmation:
					state.confirmationAlert = nil
					return .none
				case .dismissSuccessAlert:
					state.successAlert = nil
					return .none
				case .dismissErrorAlert:
					state.errorAlert = nil
					return .none
				case .didReceivePurchaseResponse(.success(let message)):
					state.dataLoadingStatus = .success
					state.successAlert = AlertState(
						title: TextState("Thank you!"),
						message: TextState("Your order is in process."),
						buttons: [
							.default(TextState("Done"), action: .send(.dismissSuccessAlert))
						]
					)
					print("Success: ", message)
					return .none
				case .didReceivePurchaseResponse(.failure(let error)):
					state.dataLoadingStatus = .error
					state.errorAlert = AlertState(
						title: TextState("Oops!"),
						message: TextState("Unable to send order, try again later."),
						buttons: [
							.default(TextState("Done"), action: .send(.dismissErrorAlert))
						]
					)
					print("Error sending your order:", error.localizedDescription)
					return .none
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
			}
		}
		.forEach(\.cartItems, action: /Action.cartItem) {
			CartItemDomain()
		}
	}
}

