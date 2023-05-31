//
//  RootDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import Foundation
import ComposableArchitecture

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
    
    struct Environment {
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
    }
    
    static let reducer = AnyReducer<
        State, Action, Environment
    >.combine(
        AnyReducer { environment in
            ProductListDomain(
                fetchProducts: environment.fetchProducts,
                sendOrder: environment.sendOrder,
                uuid: environment.uuid
            )
        }
            .pullback(
                state: \.productListState,
                action: /RootDomain.Action.productList,
                environment: { $0 }
            ),
        AnyReducer{ environment in
            ProfileDomain(fetchUserProfile: environment.fetchUserProfile)
        }
            .pullback(
                state: \.profileState,
                action: /RootDomain.Action.profile,
                environment: { $0 }
            ),
        .init { state, action, environment in
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
    )
}
