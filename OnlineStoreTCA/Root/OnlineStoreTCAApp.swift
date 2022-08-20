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
                    initialState: ProductDomain.State(),
                    reducer: ProductDomain.reducer,
                    environment: ProductDomain.Environment(
                        fetchProducts: { Product.sample },
                        sendOrder: { _ in "OK" }
                    )
                )
            )
        }
    }
}
