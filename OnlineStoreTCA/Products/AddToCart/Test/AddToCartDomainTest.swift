//
//  AddToCartDomainTest.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 26/08/22.
//

import ComposableArchitecture
import XCTest

@testable import OnlineStoreTCA

@MainActor
class AddToCartDomainTest: XCTestCase {
    
    func testIncreaseCounterTappingPlusButtonOnce() async {
        let store = TestStore(
            initialState: AddToCartDomain.State(),
            reducer: AddToCartDomain()
        )
        
        
        await store.send(.didTapPlusButton) {
            $0.count = 1
        }
    }
    
    func testIncreaseCounterTappingPlusButtonThreeTimes() async {
        let store = TestStore(
            initialState: AddToCartDomain.State(),
            reducer: AddToCartDomain()
        )
        
        
        await store.send(.didTapPlusButton) { $0.count = 1 }
        await store.send(.didTapPlusButton) { $0.count = 2 }
        await store.send(.didTapPlusButton) { $0.count = 3 }
    }
    
    func testDecreaseCounterTappingPlusButtonOnce() async {
        let store = TestStore(
            initialState: AddToCartDomain.State(),
            reducer: AddToCartDomain()
        )
        
        await store.send(.didTapMinusButton) {
            $0.count = -1
        }
    }
    
    func testDecreaseCounterTappingPlusButtonThreeTimes() async {
        let store = TestStore(
            initialState: AddToCartDomain.State(),
            reducer: AddToCartDomain()
        )
        
        await store.send(.didTapMinusButton) { $0.count = -1 }
        await store.send(.didTapMinusButton) { $0.count = -2 }
        await store.send(.didTapMinusButton) { $0.count = -3 }
    }
    
    func testUpdatingCounterTappingPlusAndMinusButtons() async {
        let store = TestStore(
            initialState: AddToCartDomain.State(),
            reducer: AddToCartDomain()
        )
        
        await store.send(.didTapMinusButton) { $0.count = -1 }
        await store.send(.didTapPlusButton) { $0.count = 0 }
        await store.send(.didTapMinusButton) { $0.count = -1 }
    }
}
