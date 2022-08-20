//
//  AddToCartButton.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 20/08/22.
//

import SwiftUI

struct AddToCartButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text("Add to Cart")
                .padding(10)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddToCartButton_Previews: PreviewProvider {
    static var previews: some View {
        AddToCartButton(action: {})
    }
}
