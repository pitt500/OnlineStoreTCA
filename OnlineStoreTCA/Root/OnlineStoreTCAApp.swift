//
//  OnlineStoreTCAApp.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 04/08/22.
//

import SwiftUI
import ComposableArchitecture

@main
struct OnlineStoreTCAApp: App {
    var body: some Scene {
        WindowGroup {
            ProductListView(
                store: Store(
                    initialState: ProductListDomain.State(),
                    reducer: ProductListDomain.reducer,
                    environment: ProductListDomain.Environment(
                        fetchProducts: { Product.sample },
                        sendOrder: { _ in "OK" }
                    )
                )
            )
        }
    }
}
