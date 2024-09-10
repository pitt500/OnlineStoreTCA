//
//  RootDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootDomain {
    struct State: Equatable {
        var selectedTab = Tab.products
        var productListState = ProductListDomain.State()
        var profileState = ProfileDomain.State()
    }
    
    enum Tab {
        case products
        case profile
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
        case productList(ProductListDomain.Action)
        case profile(ProfileDomain.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .productList:
                return .none
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            case .profile:
                return .none
            }
        }
        Scope(state: \.productListState, action: \.productList) {
            ProductListDomain()
        }
        Scope(state:  \.profileState, action: \.profile) {
            ProfileDomain()
        }
    }
}
