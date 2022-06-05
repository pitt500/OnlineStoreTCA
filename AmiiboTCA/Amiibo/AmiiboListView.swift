//
//  AmiiboListView.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 02/06/22.
//

import SwiftUI

struct AmiiboListView: View {
    @State private var shouldShowCartView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<5) { _ in
                    AmiiboCell()
                }
            }
            .navigationTitle("Amiibos")
            .navigationBarItems(trailing: cartButton)
        }
        .sheet(isPresented: $shouldShowCartView) {
            CartView()
        }
    }
    
    var cartButton: some View {
        Button {
            self.shouldShowCartView.toggle()
        } label: {
            Image(systemName: "cart.circle.fill")
                .font(Font.system(.title))
                .foregroundColor(.red)
        }
    }
}

struct AmiiboListView_Previews: PreviewProvider {
    static var previews: some View {
        AmiiboListView()
    }
}
