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
    
    override func setUp() {
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
                sendOrder: { _ in "OK" },
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
                sendOrder: { _ in "OK" },
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
}
