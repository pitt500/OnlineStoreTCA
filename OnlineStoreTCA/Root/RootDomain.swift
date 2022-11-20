//
//  RootDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import Foundation
import ComposableArchitecture

struct RootDomain: ReducerProtocol {
    var fetchProducts: @Sendable () async throws -> [Product]
    var sendOrder:  @Sendable ([CartItem]) async throws -> String
    var fetchUserProfile:  @Sendable () async throws -> UserProfile
    var uuid: @Sendable () -> UUID

    static let live = Self(
        fetchProducts: APIClient.live.fetchProducts,
        sendOrder: APIClient.live.sendOrder,
        fetchUserProfile: APIClient.live.fetchUserProfile,
        uuid: { UUID() }
    )

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

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.productListState, action: /Action.productList) {
            ProductListDomain(
                fetchProducts: fetchProducts,
                sendOrder: sendOrder, uuid: uuid
            )
        }
        Scope(state: \.profileState, action: /Action.profile) {
            ProfileDomain(fetchUserProfile: fetchUserProfile)
        }
        Reduce<State, Action> { state, action in
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
    }
}
