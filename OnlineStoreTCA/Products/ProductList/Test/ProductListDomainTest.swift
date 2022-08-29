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
    private var uuidArray: [UUID] = []
    
    private func getUUID() -> UUID {
        return uuidArray.removeLast()
    }
    
    @MainActor override func setUp() {
        super.setUp()
        
        //Elements are inserted in reverse order
        self.uuidArray = [
            UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        ]
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
        
        let store = TestStore(
            initialState: ProductListDomain.State(),
            reducer: ProductListDomain.reducer,
            environment: ProductListDomain.Environment(
                fetchProducts: {
                    products
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { self.getUUID() }
            )
        )
        
        let identifiedArray = IdentifiedArrayOf(
            uniqueElements: [
                ProductDomain.State(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    product: products[0]
                ),
                ProductDomain.State(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    product: products[1]
                ),
            ]
        )
        
        await store.send(.fetchProducts) {
            $0.dataLoadingStatus = .loading
        }
        
        await store.receive(.fetchProductsResponse(.success(products))) {
            $0.productListState = identifiedArray
            $0.dataLoadingStatus = .success
        }
    }
    
    func testFetchProductsFailure() async {
        let error = APIClient.Failure()
        let store = TestStore(
            initialState: ProductListDomain.State(),
            reducer: ProductListDomain.reducer,
            environment: ProductListDomain.Environment(
                fetchProducts: {
                    throw error
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { self.getUUID() }
            )
        )
        
        await store.send(.fetchProducts) {
            $0.dataLoadingStatus = .loading
        }
        
        await store.receive(.fetchProductsResponse(.failure(error))) {
            $0.productListState = []
            $0.dataLoadingStatus = .error
        }
    }
    
    func testResetProductsToZeroAcferPayingOrder() async {
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
                    product: products[0],
                    count: 0
                ),
                ProductDomain.State(
                    id: id2,
                    product: products[1],
                    count: 0
                ),
            ]
        )
        
        let store = TestStore(
            initialState: ProductListDomain.State(
                productListState: identifiedProducts
            ),
            reducer: ProductListDomain.reducer,
            environment: ProductListDomain.Environment(
                fetchProducts: {
                    fatalError("unimplemented")
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { self.getUUID() }
            )
        )
        
        await store.send(
            .product(
                id: id1,
                action: .addToCart(.didTapPlusButton)
            )
        ) {
            $0.productListState[id: id1]?.count = 1
            $0.productListState[id: id1]?.addToCartState.count = 1
        }
        
        await store.send(
            .product(
                id: id1,
                action: .addToCart(.didTapPlusButton)
            )
        ) {
            $0.productListState[id: id1]?.count = 2
            $0.productListState[id: id1]?.addToCartState.count = 2
        }
        
        let expectedCartState = CartListDomain.State(
            cartItems: IdentifiedArrayOf(
                uniqueElements: [
                    CartItemDomain.State(
                        id: id1,
                        cartItem: CartItem(
                            id: id2,
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
            $0.productListState[id: id1]?.count = 0
            $0.productListState[id: id1]?.addToCartState.count = 0
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
                    count: numberOfItems,
                    addToCartState: AddToCartDomain.State(count: numberOfItems)
                ),
                ProductDomain.State(
                    id: id2,
                    product: products[1],
                    count: 0
                ),
            ]
        )
        
        let store = TestStore(
            initialState: ProductListDomain.State(
                productListState: identifiedProducts
            ),
            reducer: ProductListDomain.reducer,
            environment: ProductListDomain.Environment(
                fetchProducts: {
                    fatalError("unimplemented")
                },
                sendOrder: { _ in fatalError("unimplemented") },
                uuid: { self.getUUID() }
            )
        )
        
        let expectedCartState = CartListDomain.State(
            cartItems: IdentifiedArrayOf(
                uniqueElements: [
                    CartItemDomain.State(
                        id: id1,
                        cartItem: CartItem(
                            id: id2,
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
                    id: id2,
                    action: .deleteCartItem(product: products.first!)
                )
            )
        )
        
        await store.receive(.cart(.deleteCartItem(id: id2)))
        await store.receive(.cart(.getTotalPrice)) {
            $0.cartState?.totalPrice = 21.0
        }
        await store.receive(.resetProduct(product: products.first!)) {
            $0.productListState = identifiedProducts
            $0.productListState[id: id1]?.count = 0
            $0.productListState[id: id1]?.addToCartState.count = 0
        }
        
        await store.finish()
    }
}
