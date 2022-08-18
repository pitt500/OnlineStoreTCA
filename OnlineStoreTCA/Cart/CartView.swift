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
                    Text("\(item.product.title), \(item.quantity)")
                }
                .navigationTitle("Products")
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
