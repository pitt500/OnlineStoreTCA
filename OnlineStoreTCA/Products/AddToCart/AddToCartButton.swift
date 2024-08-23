//
//  AddToCartButton.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import SwiftUI
import ComposableArchitecture

struct AddToCartButton: View {
    let store: StoreOf<AddToCartDomain>
    
    var body: some View {
        if store.count > 0 {
            PlusMinusButton(store: self.store)
        } else {
            Button {
                store.send(.didTapPlusButton)
            } label: {
                Text("Add to Cart")
                    .padding(10)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }
}

struct AddToCartButton_Previews: PreviewProvider {
    static var previews: some View {
        AddToCartButton(
            store: Store(
                initialState: AddToCartDomain.State()) {
                    AddToCartDomain()
                }
        )
    }
}
