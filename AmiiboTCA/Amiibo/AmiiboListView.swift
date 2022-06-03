//
//  AmiiboListView.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 02/06/22.
//

import SwiftUI

struct AmiiboListView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<5) { _ in
                    AmiiboCell()
                }
            }
            .navigationTitle("Amiibos")
        }
    }
}

struct AmiiboListView_Previews: PreviewProvider {
    static var previews: some View {
        AmiiboListView()
    }
}
