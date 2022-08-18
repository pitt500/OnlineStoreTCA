//
//  CartItem.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 18/08/22.
//

import Foundation

struct CartItem: Equatable, Identifiable {
    let id: UUID
    let product: Product
    let quantity: UInt
}

extension CartItem {
    static var sample: [CartItem] {
        [
            .init(
                id: UUID(),
                product: Product.sample[0],
                quantity: 3
            ),
            .init(
                id: UUID(),
                product: Product.sample[1],
                quantity: 1
            ),
        ]
    }
}
