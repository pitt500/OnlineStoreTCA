//
//  Product.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation

struct Product: Equatable, Identifiable {
    let id: Int
    let title: String
    let price: Double // Update to Currency
    let description: String
    let category: String // Update to enum
    let imageString: String
    
    // Add rating later...
}

extension Product {
    static var sample: [Product] {
        [
            .init(
                id: 1,
                title: "Item 1",
                price: 1300,
                description: "Description 1",
                category: "Demo",
                imageString: "https://twitter.com/swiftandtips/photo"
            ),
            .init(
                id: 2,
                title: "Item 3",
                price: 200,
                description: "Description 2",
                category: "Demo",
                imageString: "https://twitter.com/swiftandtips/photo"
            ),
            .init(
                id: 3,
                title: "Item 3",
                price: 100,
                description: "Description 3",
                category: "Demo",
                imageString: "https://twitter.com/swiftandtips/photo"
            )
        ]
    }
}
