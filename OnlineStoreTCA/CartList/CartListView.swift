//
//  CartListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 18/08/22.
//

import SwiftUI
import ComposableArchitecture

struct CartListView: View {
	let store: StoreOf<CartListDomain>
	
	var body: some View {
		WithPerceptionTracking {
			ZStack {
				NavigationStack {
					Group {
						if store.cartItems.isEmpty {
							Text("Oops, your cart is empty! \n")
								.font(.custom("AmericanTypewriter", size: 25))
						} else {
							List {
								ForEach(
									store.scope(state: \.cartItems, action: \.cartItem),
									id: \.id
								) { store in
									CartCell(store: store)
								}
							}
							.safeAreaInset(edge: .bottom) {
								Button {
									store.send(.didPressPayButton)
								} label: {
									HStack(alignment: .center) {
										Spacer()
										Text("Pay \(store.totalPriceString)")
											.font(.custom("AmericanTypewriter", size: 30))
											.foregroundColor(.white)
										
										Spacer()
									}
									
								}
								.frame(maxWidth: .infinity, minHeight: 60)
								.background(
									store.isPayButtonDisable
									? .gray
									: .blue
								)
								.cornerRadius(10)
								.padding()
								.disabled(store.isPayButtonDisable)
							}
						}
					}
					.navigationTitle("Cart")
					.toolbar {
						ToolbarItem(placement: .navigationBarLeading) {
							Button {
								store.send(.didPressCloseButton)
							} label: {
								Text("Close")
							}
						}
					}
					.onAppear {
						store.send(.getTotalPrice)
					}
					.alert(store: store.scope(state: \.$alert, action: \.alert))
				}
				if store.isRequestInProcess {
					Color.black.opacity(0.2)
						.ignoresSafeArea()
					ProgressView()
				}
			}
		}
	}
}

struct CartListView_Previews: PreviewProvider {
	static var previews: some View {
		CartListView(
			store: Store(
				initialState: CartListDomain.State(
					cartItems: IdentifiedArrayOf(
						uniqueElements: CartItem.sample
							.map {
								CartItemDomain.State(
									id: UUID(),
									cartItem: $0
								)
							}
					)
				),
				reducer: { CartListDomain() },
				withDependencies: {
					$0.apiClient.sendOrder = { _ in "OK" }
				}
			)
		)
	}
}
