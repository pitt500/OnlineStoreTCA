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
        Text(product.title)
    }
}

struct ProductCell_Previews: PreviewProvider {
    static var previews: some View {
        ProductCell(product: Product.sample.first!)
            .previewLayout(.fixed(width: 300, height: 200))
    }
}
