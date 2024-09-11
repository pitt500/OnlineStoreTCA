//
//  PlusMinusButton.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import SwiftUI
import ComposableArchitecture

struct PlusMinusButton: View {
    let store: StoreOf<AddToCartDomain>
    
    var body: some View {
        WithPerceptionTracking {
            HStack {
                Button {
                    store.send(.didTapMinusButton)
                } label: {
                    Text("-")
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Text(store.count.description)
                    .padding(5)
                
                Button {
                    store.send(.didTapPlusButton)
                } label: {
                    Text("+")
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct PlusMinusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusMinusButton(
            store: Store(
                initialState: AddToCartDomain.State(),
                reducer: { AddToCartDomain() }
            )
        )
    }
}
