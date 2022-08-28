//
//  ProductDomainTest.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 27/08/22.
//

import ComposableArchitecture
import XCTest

@testable import OnlineStoreTCA

@MainActor
class ProductDomainTest: XCTestCase {
    func testIncreaseProductCounterTappingPlusButtonOnce() async {
        let product = Product(
            id: 1,
            title: "ProductDemo",
            price: 10.5,
            description: "Hi mom!",
            category: "Category1",
            imageString: "image"
        )
        let store = TestStore(
            initialState: ProductDomain.State(
                id: UUID(),
                product: product
            ),
            reducer: ProductDomain.reducer,
            environment: ProductDomain.Environment()
        )
        
        await store.send(.addToCart(.didTapPlusButton)) {
            $0.count = 1
            $0.addToCartState = AddToCartDomain.State(count: 1)
        }
    }
    
    func testIncreaseProductCounterTappingPlusButtonThreeTimes() async {
        let product = Product(
            id: 1,
            title: "ProductDemo",
            price: 10.5,
            description: "Hi mom!",
            category: "Category1",
            imageString: "image"
        )
        let store = TestStore(
            initialState: ProductDomain.State(
                id: UUID(),
                product: product
            ),
            reducer: ProductDomain.reducer,
            environment: ProductDomain.Environment()
        )
        
        await store.send(.addToCart(.didTapPlusButton)) {
            $0.count = 1
            $0.addToCartState = AddToCartDomain.State(count: 1)
        }
        
        await store.send(.addToCart(.didTapPlusButton)) {
            $0.count = 2
            $0.addToCartState = AddToCartDomain.State(count: 2)
        }
        
        await store.send(.addToCart(.didTapPlusButton)) {
            $0.count = 3
            $0.addToCartState = AddToCartDomain.State(count: 3)
        }
    }
    
    
    func testIncreaseProductCounterTappingMinusButtonOnce() async {
        let product = Product(
            id: 1,
            title: "ProductDemo",
            price: 10.5,
            description: "Hi mom!",
            category: "Category1",
            imageString: "image"
        )
        let store = TestStore(
            initialState: ProductDomain.State(
                id: UUID(),
                product: product
            ),
            reducer: ProductDomain.reducer,
            environment: ProductDomain.Environment()
        )
        
        await store.send(.addToCart(.didTapMinusButton)) {
            $0.count = 0
            $0.addToCartState = AddToCartDomain.State(count: -1)
        }
    }
    
    func testIncreaseProductCounterTappingMinusButtonThreeTimes() async {
        let product = Product(
            id: 1,
            title: "ProductDemo",
            price: 10.5,
            description: "Hi mom!",
            category: "Category1",
            imageString: "image"
        )
        let store = TestStore(
            initialState: ProductDomain.State(
                id: UUID(),
                product: product
            ),
            reducer: ProductDomain.reducer,
            environment: ProductDomain.Environment()
        )
        
        await store.send(.addToCart(.didTapMinusButton)) {
            $0.count = 0
            $0.addToCartState = AddToCartDomain.State(count: -1)
        }
        await store.send(.addToCart(.didTapMinusButton)) {
            $0.count = 0
            $0.addToCartState = AddToCartDomain.State(count: -2)
        }
        await store.send(.addToCart(.didTapMinusButton)) {
            $0.count = 0
            $0.addToCartState = AddToCartDomain.State(count: -3)
        }
    }
    
    func testIncreaseProductCounterTappingMinusTwoTimesAndPlusOnce() async {
        let product = Product(
            id: 1,
            title: "ProductDemo",
            price: 10.5,
            description: "Hi mom!",
            category: "Category1",
            imageString: "image"
        )
        let store = TestStore(
            initialState: ProductDomain.State(
                id: UUID(),
                product: product
            ),
            reducer: ProductDomain.reducer,
            environment: ProductDomain.Environment()
        )
        
        await store.send(.addToCart(.didTapMinusButton)) {
            $0.count = 0
            $0.addToCartState = AddToCartDomain.State(count: -1)
        }
        await store.send(.addToCart(.didTapMinusButton)) {
            $0.count = 0
            $0.addToCartState = AddToCartDomain.State(count: -2)
        }
        await store.send(.addToCart(.didTapPlusButton)) {
            $0.count = 1
            $0.addToCartState = AddToCartDomain.State(count: -1)
        }
    }
    
}
