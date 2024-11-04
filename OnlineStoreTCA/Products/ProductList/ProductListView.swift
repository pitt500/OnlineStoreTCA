//
//  ProductListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct ProductListView: View {
    @Perception.Bindable var store: StoreOf<ProductListDomain>
    
    var body: some View {
        WithPerceptionTracking {
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
                                store.scope(
                                    state: \.productList,
                                    action: \.product
                                ),
                                id: \.id
                            ) { store in
                                WithPerceptionTracking {
                                    ProductCell(store: store)
                                }
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
                            store.send(.setCartView(isPresented: true))
                        } label: {
                            Text("Go to Cart")
                        }
                    }
                }
				.sheet(
					item: $store.scope(
						state: \.cartState,
						action: \.cart
					)
				) { store in
					CartListView(store: store)
				}
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
                ProductListDomain()
            } withDependencies: {
                $0.apiClient.fetchProducts = { Product.sample }
                $0.apiClient.sendOrder = { _ in "OK" }
            }
        )
    }
}
