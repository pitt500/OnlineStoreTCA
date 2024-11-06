//
//  CartListDomainTest.swift
//  OnlineStoreTCATests
//
//  Created by Pedro Rojas on 30/08/22.
//

import ComposableArchitecture
import XCTest

@testable import OnlineStoreTCA

@MainActor
class CartListDomainTest: XCTestCase {
    func testRemoveItemFromCart() async {
        let cartItemId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let cartItemId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let itemQuantity = 2
        
        let cartItems: IdentifiedArrayOf<CartItemDomain.State> = [
            .init(
                id: cartItemId1,
                cartItem: CartItem.init(
                    product: Product.sample[0],
                    quantity: itemQuantity
                )
            ),
            .init(
                id: cartItemId2,
                cartItem: CartItem.init(
                    product: Product.sample[1],
                    quantity: itemQuantity
                )
            ),
        ]
        
        let store = TestStore(
            initialState: CartListDomain.State(cartItems: cartItems),
            reducer: { CartListDomain() }
        )
        
		await store.send(\.cartItem[id: cartItemId1].deleteCartItem, Product.sample[0]) {
            $0.cartItems = [
                .init(
                    id: cartItemId2,
                    cartItem: CartItem.init(
                        product: Product.sample[1],
                        quantity: itemQuantity
                    )
                )
            ]
        }
        
        let expectedPrice = Product.sample[1].price * Double(itemQuantity)
        await store.receive(\.getTotalPrice) {
            $0.totalPrice = expectedPrice
        }
    }
    
    func testRemoveAllItemsFromCart() async {
        let cartItemId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let cartItemId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let itemQuantity = 2
        
        let cartItems: IdentifiedArrayOf<CartItemDomain.State> = [
            .init(
                id: cartItemId1,
                cartItem: CartItem.init(
                    product: Product.sample[0],
                    quantity: itemQuantity
                )
            ),
            .init(
                id: cartItemId2,
                cartItem: CartItem.init(
                    product: Product.sample[1],
                    quantity: itemQuantity
                )
            ),
        ]
        
        let store = TestStore(
            initialState: CartListDomain.State(cartItems: cartItems),
            reducer: { CartListDomain() }
        )
        
		await store.send(\.cartItem[id: cartItemId1].deleteCartItem, Product.sample[0]) {
            $0.cartItems = [
                .init(
                    id: cartItemId2,
                    cartItem: CartItem.init(
                        product: Product.sample[1],
                        quantity: itemQuantity
                    )
                )
            ]
        }
        
        let expectedPrice = Product.sample[1].price * Double(itemQuantity)
        await store.receive(\.getTotalPrice) {
            $0.totalPrice = expectedPrice
        }
        
		await store.send(\.cartItem[id: cartItemId2].deleteCartItem, Product.sample[1]) {
            $0.cartItems = []
        }
        
        await store.receive(\.getTotalPrice) {
            $0.totalPrice = 0
            $0.isPayButtonDisable = true
        }
        
    }
    
    func testSendOrderSuccessfully() async {
        let cartItemId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let cartItemId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let itemQuantity = 2
        
        let cartItems: IdentifiedArrayOf<CartItemDomain.State> = [
            .init(
                id: cartItemId1,
                cartItem: CartItem.init(
                    product: Product.sample[0],
                    quantity: itemQuantity
                )
            ),
            .init(
                id: cartItemId2,
                cartItem: CartItem.init(
                    product: Product.sample[1],
                    quantity: itemQuantity
                )
            ),
        ]
        
        let store = TestStore(
            initialState: CartListDomain.State(cartItems: cartItems),
            reducer: { CartListDomain() }
        ) {
            $0.apiClient.sendOrder = { _ in "Success" }
        }
        
		await store.send(\.didPressPayButton) {
			$0.alert = .confirmationAlert(totalPriceString: "$0.0")
		}
		
		await store.send(\.alert.didConfirmPurchase) {
			$0.alert = nil
            $0.dataLoadingStatus = .loading
        }
        
        
        await store.receive(\.didReceivePurchaseResponse, .success("Success")) {
            $0.dataLoadingStatus = .success
            $0.alert = .successAlert
        }
    }
    
    func testSendOrderWithError() async {
        let cartItemId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let cartItemId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let itemQuantity = 2
        
        let cartItems: IdentifiedArrayOf<CartItemDomain.State> = [
            .init(
                id: cartItemId1,
                cartItem: CartItem.init(
                    product: Product.sample[0],
                    quantity: itemQuantity
                )
            ),
            .init(
                id: cartItemId2,
                cartItem: CartItem.init(
                    product: Product.sample[1],
                    quantity: itemQuantity
                )
            ),
        ]
        
        let store = TestStore(
            initialState: CartListDomain.State(cartItems: cartItems),
            reducer: { CartListDomain() }
        ) {
            $0.apiClient.sendOrder = { _ in throw APIClient.Failure() }
        }
		
		await store.send(\.didPressPayButton) {
			$0.alert = .confirmationAlert(totalPriceString: "$0.0")
		}
        
        await store.send(\.alert.didConfirmPurchase) {
            $0.dataLoadingStatus = .loading
			$0.alert = nil
        }
        
        
        await store.receive(\.didReceivePurchaseResponse, .failure(APIClient.Failure())) {
            $0.dataLoadingStatus = .error
            $0.alert = .errorAlert
        }
    }
}
