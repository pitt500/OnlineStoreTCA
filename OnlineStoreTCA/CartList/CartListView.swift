//
//  CartListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 18/08/22.
//

import SwiftUI
import ComposableArchitecture

struct CartListView: View {
    let store: Store<CartListDomain.State, CartListDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                Group {
                    if viewStore.cartItems.count > 0 {
                        List {
                            ForEachStore(
                                self.store.scope(
                                    state: \.cartItems,
                                    action: CartListDomain.Action
                                        .cartItem(id:action:)
                                )
                            ) {
                                CartCell(store: $0)
                            }
                        }
                        .safeAreaInset(edge: .bottom) {
                            Button {
                                viewStore.send(.didPressPayButton)
                            } label: {
                                HStack(alignment: .center) {
                                    Spacer()
                                    Text("Pay \(viewStore.totalPriceString)")
                                        .font(.custom("AmericanTypewriter", size: 30))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                
                            }
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(.blue)
                            .cornerRadius(10)
                            .padding()
                            .opacity(viewStore.isPayButtonHidden ? 0 : 1)
                        }
                    } else {
                        Text("Oops, your cart is empty! \n")
                            .font(.custom("AmericanTypewriter", size: 25))
                    }
                }
                .onAppear {
                    viewStore.send(.getTotalPrice)
                }
                .navigationTitle("Cart")
                .alert(
                    self.store.scope(state: \.confirmationAlert),
                    dismiss: .didCancelConfirmation
                )
                .alert(
                    self.store.scope(state: \.successAlert),
                    dismiss: .dismissSuccessAlert
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.didPressCloseButton)
                        } label: {
                            Text("Close")
                        }
                    }
                }
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartListView(
            store: Store(
                initialState: CartListDomain.State(
                    cartItems: IdentifiedArrayOf(
                        uniqueElements: CartItem.sample
                            .compactMap {
                                CartItemDomain.State(
                                    id: UUID(),
                                    cartItem: $0
                                )
                            }
                    )
                ),
                reducer: CartListDomain.reducer,
                environment: CartListDomain.Environment(
                    sendOrder: { _ in "OK" }
                )
            )
        )
    }
}
