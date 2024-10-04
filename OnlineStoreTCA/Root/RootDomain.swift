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
    @ObservableState
    struct State: Equatable {
        var selectedTab = Tab.products
        var productList = ProductListDomain.State()
        var profile = ProfileDomain.State()
    }
    
    enum Tab {
        case products
        case profile
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case productList(ProductListDomain.Action)
        case profile(ProfileDomain.Action)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .binding:
                    return .none
                case .productList:
                    return .none
                case .profile:
                    return .none
            }
        }
        Scope(state: \.productList, action: \.productList) {
            ProductListDomain()
        }
        Scope(state:  \.profile, action: \.profile) {
            ProfileDomain()
        }
    }
}
