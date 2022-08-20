//
//  ProductCell.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import SwiftUI

struct ProductCell: View {
    let product: Product
    
    var body: some View {
        VStack {
            Image(product.imageString)
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Text(product.title)
                Text("$\(product.price.description)")
                    .fontWeight(.bold)
            }
            .font(.custom("AmericanTypewriter", size: 20))
            
        }
        .padding(20)
    }
}

struct ProductCell_Previews: PreviewProvider {
    static var previews: some View {
        ProductCell(product: Product.sample.first!)
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
