//
//  ProductListView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import SwiftUI
import ComposableArchitecture

struct ProductListView: View {
    let store: Store<ProductDomain.State,ProductDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                List(viewStore.products) { product in
                    Text(product.title)
                }.onAppear {
                    viewStore.send(.fetchProducts)
                }
                .navigationTitle("Products")
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView(
            store: Store(
                initialState: ProductDomain.State(),
                reducer: ProductDomain.reducer,
                environment: ProductDomain.Environment(
                    fetchProducts: { Product.sample }
                )
            )
        )
    }
}
