//
//  ProductDetailsView.swift
//  OnlineStoreTCA
//
//  Created by Mohamed Alouane on 9/10/2022.
//

import SwiftUI
import ComposableArchitecture

struct ProductDetailsView: View {
    let store: Store<ProductDetailsDomain.State, ProductDetailsDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                AsyncImage(
                    url: URL(string: viewStore.product.imageString)
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                } placeholder: {
                    ProgressView()
                        .frame(height: 300)
                }
                
                VStack(alignment: .leading) {
                    Text(viewStore.product.title)
                    HStack {
                        Text("$\(viewStore.product.price.description)")
                            .font(.custom("AmericanTypewriter", size: 25))
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .font(.custom("AmericanTypewriter", size: 20))
            }
            .padding(20)
            .task {
                viewStore.send(.fetchProduct)
            }
        }
    }
}


struct ProductDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsView(
            store: Store(
                initialState: ProductDetailsDomain.State(product: .default),
                reducer: ProductDetailsDomain.reducer,
                environment: ProductDetailsDomain.Environment(
                    fetchProduct: { .default }
                )
            )
        )
    }
}
