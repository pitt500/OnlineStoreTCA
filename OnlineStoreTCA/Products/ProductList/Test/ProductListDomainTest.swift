//
//  ProductListDomainTest.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 27/08/22.
//

import ComposableArchitecture
import XCTest

@testable import OnlineStoreTCA

@MainActor
class ProductListDomainTest: XCTestCase {
    
    override func setUp() async throws {
        UUID.uuIdTestCounter = 0
    }
    
    func testFetchProductsSuccess() async {
        let products: [Product] = [
            .init(
                id: 1,
                title: "ProductDemo",
                price: 10.5,
                description: "Hi mom!",
                category: "Category1",
                imageString: "image"
            ),
            .init(
                id: 2,
                title: "AnotherProduct",
                price: 99.99,
                description: "Hi Dad!",
                category: "Category2",
                imageString: "image2"
            ),
        ]
        let store = TestStore(initialState: ProductListDomain.State(), reducer: {
            ProductListDomain(
                fetchProducts: {
                    products
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { UUID.newUUIDForTest }
            )
        })
        
        let productId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let productId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        
        let identifiedArray = IdentifiedArrayOf(
            uniqueElements: [
                ProductDomain.State(
                    id: productId1,
                    product: products[0]
                ),
                ProductDomain.State(
                    id: productId2,
                    product: products[1]
                ),
            ]
        )
        
        await store.send(.fetchProducts) { send in
            send.dataLoadingStatus = .loading
        }
        
        await store.receive(.fetchProductsResponse(.success(products))) {
            $0.productList = identifiedArray
            $0.dataLoadingStatus = .success
        }
    }
    
    func testFetchProductsFailure() async {
        let error = APIClient.Failure()
        let store = TestStore(initialState: ProductListDomain.State()) {
            ProductListDomain(
                fetchProducts: {
                    throw error
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { UUID.newUUIDForTest }
            )
        }
        
        await store.send(.fetchProducts) {
            $0.dataLoadingStatus = .loading
        }
        
        await store.receive(.fetchProductsResponse(.failure(error))) {
            $0.productList = []
            $0.dataLoadingStatus = .error
        }
    }
    
    func testResetProductsToZeroAfterPayingOrder() async {
        let products: [Product] = [
            .init(
                id: 1,
                title: "ProductDemo",
                price: 10.5,
                description: "Hi mom!",
                category: "Category1",
                imageString: "image"
            ),
            .init(
                id: 2,
                title: "AnotherProduct",
                price: 99.99,
                description: "Hi Dad!",
                category: "Category2",
                imageString: "image2"
            ),
        ]
        
        let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        
        let identifiedProducts = IdentifiedArrayOf(
            uniqueElements: [
                ProductDomain.State(
                    id: id1,
                    product: products[0]
                ),
                ProductDomain.State(
                    id: id2,
                    product: products[1]
                ),
            ]
        )
        
        let store = TestStore(initialState: ProductListDomain.State(productList: identifiedProducts)) {
            ProductListDomain(
                fetchProducts: {
                    fatalError("unimplemented")
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { UUID.newUUIDForTest }
            )
        }
        
        await store.send(
            .product(
                id: id1,
                action: .addToCart(.didTapPlusButton)
            )
        ) {
            $0.productList[id: id1]?.addToCartState.count = 1
        }
        
        await store.send(
            .product(
                id: id1,
                action: .addToCart(.didTapPlusButton)
            )
        ) {
            $0.productList[id: id1]?.addToCartState.count = 2
        }
        
        let expectedCartState = CartListDomain.State(
            cartItems: IdentifiedArrayOf(
                uniqueElements: [
                    CartItemDomain.State(
                        id: id1,
                        cartItem: CartItem(
                            product: products.first!,
                            quantity: 2
                        )
                    )
                ]
            )
        )
        
        await store.send(.setCartView(isPresented: true)) {
            $0.shouldOpenCart = true
            $0.cartState = expectedCartState
        }
        
        await store.send(.cart(.dismissSuccessAlert)) {
            $0.productList[id: id1]?.addToCartState.count = 0
        }
        
        await store.receive(.closeCart) {
            $0.shouldOpenCart = false
            $0.cartState = nil
        }
    }
    
    func testItemRemovedFromCart() async {
        let products: [Product] = [
            .init(
                id: 1,
                title: "ProductDemo",
                price: 10.5,
                description: "Hi mom!",
                category: "Category1",
                imageString: "image"
            ),
            .init(
                id: 2,
                title: "AnotherProduct",
                price: 99.99,
                description: "Hi Dad!",
                category: "Category2",
                imageString: "image2"
            ),
        ]
        
        let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let numberOfItems = 2
        
        let identifiedProducts = IdentifiedArrayOf(
            uniqueElements: [
                ProductDomain.State(
                    id: id1,
                    product: products[0],
                    addToCartState: AddToCartDomain.State(count: numberOfItems)
                ),
                // This item should not be added:
                ProductDomain.State(
                    id: id2,
                    product: products[1],
                    addToCartState: AddToCartDomain.State(count: 0)
                ),
            ]
        )
        
        let store = TestStore(initialState: ProductListDomain.State(productList: identifiedProducts)) {
            ProductListDomain(
                fetchProducts: {
                    fatalError("unimplemented")
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { UUID.newUUIDForTest }
            )
        }
        
        let expectedCartState = CartListDomain.State(
            cartItems: IdentifiedArrayOf(
                uniqueElements: [
                    CartItemDomain.State(
                        id: id1,
                        cartItem: CartItem(
                            product: products.first!,
                            quantity: numberOfItems
                        )
                    )
                ]
            )
        )
        
        await store.send(.setCartView(isPresented: true)) {
            $0.shouldOpenCart = true
            $0.cartState = expectedCartState
        }
        await store.send(
            .cart(
                .cartItem(
                    id: id1,
                    action: .deleteCartItem(product: products[0])
                )
            )
        ) {
            $0.cartState?.cartItems = []
        }
        
        await store.receive(.cart(.getTotalPrice)) {
            $0.cartState?.totalPrice = 0
            $0.cartState?.isPayButtonDisable = true
        }
        await store.receive(.resetProduct(product: products[0])) {
            $0.productList = identifiedProducts
            $0.productList[id: id1]?.count = 0
        }
    }
}


extension UUID {
    // uuIdTestCounter needs to be set to 0 on setUp() method
    static var uuIdTestCounter: UInt = 0
    
    static var newUUIDForTest: UUID {
        defer {
            uuIdTestCounter += 1
        }
        return UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuIdTestCounter))")!
    }
}
