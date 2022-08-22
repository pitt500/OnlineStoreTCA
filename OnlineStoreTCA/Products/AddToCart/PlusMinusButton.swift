//
//  PlusMinusButton.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import SwiftUI
import ComposableArchitecture

struct PlusMinusButton: View {
    let store: Store<AddToCartDomain.State, AddToCartDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button {
                    viewStore.send(.didTapMinusButton)
                } label: {
                    Text("-")
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                Text(viewStore.count.description)
                    .padding(5)
                
                Button {
                    viewStore.send(.didTapPlusButton)
                } label: {
                    Text("+")
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct PlusMinusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusMinusButton(
            store: Store(
                initialState: AddToCartDomain.State(),
                reducer: AddToCartDomain.reducer,
                environment: AddToCartDomain.Environment()
            )
        )
    }
}
