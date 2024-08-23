//
//  ProductListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct ProductListView: View {
    @Bindable var store: StoreOf<ProductListDomain>
    
    var body: some View {
        NavigationView {
            Group {
                if store.isLoading {
                    ProgressView()
                        .frame(width: 100, height: 100)
                } else if store.shouldShowError {
                    ErrorView(
                        message: "Oops, we couldn't fetch product list",
                        retryAction: { store.send(.fetchProducts) }
                    )
                    
                } else {
                    List {
                        ForEach(
                            self.store.scope(
                                state: \.productList,
                                action: \.products
                            ),
                            id: \.state.id
                        ) {
                            ProductCell(store: $0)
                        }
                    }
                }
            }
            .task {
                store.send(.fetchProducts)
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.goToCartButtonTapped)
                    } label: {
                        Text("Go to Cart")
                    }
                }
            }
            .sheet(
                item: $store.scope(
                    state: \.cartState,
                    action: \.showCart
                )
            ) {
                CartListView(store: $0)
            }
            
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView(
            store: Store(
                initialState: ProductListDomain.State()
            ) {
                ProductListDomain(
                    fetchProducts: { Product.sample },
                    sendOrder: { _ in "OK" },
                    uuid: { UUID() }
                )
            }
        )
    }
}
