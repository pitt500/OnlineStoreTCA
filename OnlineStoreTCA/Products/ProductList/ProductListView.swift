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
        WithViewStore(self.store) { viewStore in
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
                                    state: \.productListState,
                                    action: ProductListDomain.Action.product
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
                .navigationViewStyle(.stack)
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

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView(
            store: Store(
                initialState: ProductListDomain.State(),
                reducer: ProductListDomain(
                    fetchProducts: { Product.sample },
                    sendOrder: { _ in "OK" },
                    uuid: { UUID() }
                )
            )
        )
    }
}
