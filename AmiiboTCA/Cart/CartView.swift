//
//  CartView.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 05/06/22.
//

import SwiftUI

struct CartView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<10) { _ in
                    AmiiboCell()
                }
            }
            .navigationTitle("Cart")
            .safeAreaInset(edge: .bottom) {
                Button {
                    print("Pay purchase")
                } label: {
                    Text("$ Pay")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 15).fill(Color.blue)
                )
                .padding(.horizontal)
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
