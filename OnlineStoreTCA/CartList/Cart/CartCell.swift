//
//  CartCell.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 22/08/22.
//

import SwiftUI
import ComposableArchitecture

struct CartCell: View {
    let store: StoreOf<CartItemDomain>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                HStack {
                    AsyncImage(
                        url: URL(
                            string: store.cartItem.product.imageString
                        )
                    ) {
                        $0
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 100, height: 100)
                    }
                    VStack(alignment: .leading) {
                        Text(store.cartItem.product.title)
                            .lineLimit(3)
                            .minimumScaleFactor(0.5)
                        HStack {
                            Text("$\(store.cartItem.product.price.description)")
                                .font(.custom("AmericanTypewriter", size: 25))
                                .fontWeight(.bold)
                        }
                    }
                    
                }
                ZStack {
                    Group {
                        Text("Quantity: ")
                        +
                        Text("\(store.cartItem.quantity)")
                            .fontWeight(.bold)
                    }
                    .font(.custom("AmericanTypewriter", size: 25))
                    HStack {
                        Spacer()
                        Button {
                            store.send(
                                .deleteCartItem(
                                    product: store.cartItem.product
                                )
                            )
                        } label: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
            }
            .font(.custom("AmericanTypewriter", size: 20))
            .padding([.bottom, .top], 10)
        }
    }
}

@available(iOS 17, *)
#Preview(traits: .fixedLayout(width: 300, height: 300)) {
    CartCell(
        store: Store(
            initialState: CartItemDomain.State(
                id: UUID(),
                cartItem: CartItem.sample.first!
            ),
            reducer: { CartItemDomain() }
        )
    )
}
