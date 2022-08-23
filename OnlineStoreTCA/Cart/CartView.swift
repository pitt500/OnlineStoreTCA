//
//  CartView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 18/08/22.
//

import SwiftUI
import ComposableArchitecture

struct CartView: View {
    let store: Store<CartDomain.State, CartDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                List(viewStore.cartItems) { item in
                    CartCell(cartItem: item)
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
                }
                .onAppear {
                    viewStore.send(.getTotalPrice)
                }
                .navigationTitle("Cart")
                .alert(
                    self.store.scope(state: \.alert),
                    dismiss: .didCancelConfirmation
                )
                
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(
            store: Store(
                initialState: CartDomain.State(
                    cartItems: CartItem.sample,
                    isCartViewOpen: true
                ),
                reducer: CartDomain.reducer,
                environment: CartDomain.Environment(
                    sendOrder: { _ in "OK" }
                )
            )
        )
    }
}
