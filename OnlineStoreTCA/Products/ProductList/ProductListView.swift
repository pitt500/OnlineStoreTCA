//
//  ProductListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct ProductListView: View {
    let store: Store<ProductListDomain.State,ProductListDomain.Action>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                Group {
                    if viewStore.isLoading {
                        ProgressView()
                            .frame(width: 100, height: 100)
                    } else if viewStore.shouldShowError {
                        ErrorView(
                            message: "Oops, we couldn't fetch product list",
                            retryAction: { viewStore.send(.fetchProducts) }
                        )
                        
                    } else {
                        List {
                            ForEachStore(
                                self.store.scope(
                                    state: \.productList,
                                    action: ProductListDomain.Action
                                        .product(id: action:)
                                )
                            ) {
                                ProductCell(store: $0)
                            }
                        }
                    }
                }
                .task {
                    viewStore.send(.fetchProducts)
                }
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewStore.send(.setCartView(isPresented: true))
                        } label: {
                            Text("Go to Cart")
                        }
                    }
                }
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.shouldOpenCart,
                        send: ProductListDomain.Action.setCartView(isPresented:)
                    )
                ) {
                    IfLetStore(
                        self.store.scope(
                            state: \.cartState,
                            action: ProductListDomain.Action.cart
                        )
                    ) {
                        CartListView(store: $0)
                    }
                }
                
            }
        }
    }
}
