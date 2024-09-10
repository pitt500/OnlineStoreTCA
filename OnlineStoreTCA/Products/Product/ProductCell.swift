//
//  ProductCell.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import SwiftUI
import ComposableArchitecture

struct ProductCell: View {
	let store: StoreOf<ProductDomain>
	
	var body: some View {
		WithPerceptionTracking {
			VStack {
				AsyncImage(
					url: URL(string: store.product.imageString)
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
					Text(store.product.title)
					HStack {
						Text("$\(store.product.price.description)")
							.font(.custom("AmericanTypewriter", size: 25))
							.fontWeight(.bold)
						Spacer()
						AddToCartButton(
							store: self.store.scope(
								state: \.addToCartState,
								action: \.addToCart
							)
						)
					}
				}
				.font(.custom("AmericanTypewriter", size: 20))
			}
			.padding(20)
		}
	}
}

struct ProductCell_Previews: PreviewProvider {
	static var previews: some View {
		ProductCell(
			store: Store(
				initialState: ProductDomain.State(
					id: UUID(),
					product: Product.sample[0]
				),
				reducer: { ProductDomain() }
			)
		)
		.previewLayout(.fixed(width: 300, height: 300))
	}
}
