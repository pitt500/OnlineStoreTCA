//
//  RootView.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 02/06/22.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            AmiiboListView()
                .tabItem {
                    Image(systemName: "star")
                    Text("Amiibos")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
