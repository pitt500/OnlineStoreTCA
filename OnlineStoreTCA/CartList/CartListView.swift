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
            ZStack {
                NavigationStack {
                    Group {
                        if viewStore.cartItems.isEmpty {
                            Text("Oops, your cart is empty! \n")
                                .font(.custom("AmericanTypewriter", size: 25))
                        } else {
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
                                .background(
                                    viewStore.isPayButtonDisable
                                    ? .gray
                                    : .blue
                                )
                                .cornerRadius(10)
                                .padding()
                                .disabled(viewStore.isPayButtonDisable)
                            }
                        }
                    }
                    .navigationTitle("Cart")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                viewStore.send(.didPressCloseButton)
                            } label: {
                                Text("Close")
                            }
                        }
                    }
                    .onAppear {
                        viewStore.send(.getTotalPrice)
                    }
                    .alert(
                        self.store.scope(state: \.confirmationAlert),
                        dismiss: .didCancelConfirmation
                    )
                    .alert(
                        self.store.scope(state: \.successAlert),
                        dismiss: .dismissSuccessAlert
                    )
                    .alert(
                        self.store.scope(state: \.errorAlert),
                        dismiss: .dismissErrorAlert
                    )
                }
                if viewStore.isRequestInProcess {
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
                reducer: CartListDomain(sendOrder: { _ in "OK" })
            )
        )
    }
}
