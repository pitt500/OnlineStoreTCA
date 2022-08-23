//
//  CartCell.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 22/08/22.
//

import SwiftUI
import ComposableArchitecture

struct CartCell: View {
    let cartItem: CartItem
    
    var body: some View {
        VStack {
            HStack {
                Image(cartItem.product.imageString)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                VStack(alignment: .leading) {
                    Text(cartItem.product.title)
                        .lineLimit(3)
                        .minimumScaleFactor(0.5)
                    HStack {
                        Text("$\(cartItem.product.price.description)")
                            .font(.custom("AmericanTypewriter", size: 25))
                            .fontWeight(.bold)
                    }
                }
                
            }
            ZStack {
                Group {
                    Text("Quantity: ")
                    +
                    Text("\(cartItem.quantity)")
                        .fontWeight(.bold)
                }
                .font(.custom("AmericanTypewriter", size: 25))
                HStack {
                    Spacer()
                    Button {
                        
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

struct CartCell_Previews: PreviewProvider {
    static var previews: some View {
        CartCell(cartItem: CartItem.sample.first!)
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
