//
//  ProductListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductListDomain {
    struct State: Equatable {
        fileprivate var dataState = DataState.notStarted
        fileprivate var initialState: IdentifiedArrayOf<ProductDomain.State> = []
        var shouldOpenCart = false
        var cartState: CartListDomain.State?
        var productListState: IdentifiedArrayOf<ProductDomain.State> = []
        
        var shouldShowError: Bool {
            dataState == .error
        }
        
        var isLoading: Bool {
            dataState == .loading
        }
    }
    
    fileprivate enum DataState {
        case notStarted
        case loading
        case success
        case error
    }
    
    enum Action: Equatable {
        case fetchProducts
        case fetchProductsResponse(TaskResult<[Product]>)
        case setCartView(isPresented: Bool)
        case cart(CartListDomain.Action)
        case product(id: ProductDomain.State.ID, action: ProductDomain.Action)
        case resetProduct(product: Product)
        case closeCart
    }
    
    struct Environment {
        var fetchProducts: () async throws -> [Product]
        var sendOrder: ([CartItem]) async throws -> String
    }
    
    static let reducer = Reducer<
        State, Action, Environment
    >.combine(
        ProductDomain.reducer.forEach(
            state: \.productListState,
            action: /ProductListDomain.Action.product(id:action:),
            environment: { _ in ProductDomain.Environment() }
        ),
        CartListDomain.reducer
            .optional()
            .pullback(
                state: \.cartState,
                action: /ProductListDomain.Action.cart,
                environment: {
                    CartListDomain.Environment(
                        sendOrder: $0.sendOrder
                    )
                }
            ),
        .init { state, action, environment in
            switch action {
            case .fetchProducts:
                if state.dataState == .success || state.dataState == .loading {
                    return .none
                }
                
                state.dataState = .loading
                return .task {
                    await .fetchProductsResponse(
                        TaskResult { try await environment.fetchProducts() }
                    )
                }
            case .fetchProductsResponse(.success(let products)):
                state.dataState = .success
                state.productListState = IdentifiedArrayOf(
                    uniqueElements: products.map {
                        ProductDomain.State(
                            id: UUID(),
                            product: $0
                        )
                    }
                )
                state.initialState = state.productListState
                return .none
            case .fetchProductsResponse(.failure(let error)):
                state.dataState = .error
                print(error)
                print("Error getting products, try again later.")
                return .none
            case .cart(let action):
                switch action {
                case .didPressCloseButton:
                    return closeCart(state: &state)
                case .dismissSuccessAlert:
                    state.productListState = state.initialState
                    return .task {
                        .closeCart
                    }
                case .cartItem(_, let action):
                    switch action {
                    case .deleteCartItem(let product):
                        return .task {
                            .resetProduct(product: product)
                        }
                    }
                default:
                    return .none
                }
            case .closeCart:
                return closeCart(state: &state)
            case .resetProduct(let product):
                
                guard let index = state.productListState.firstIndex(
                    where: { $0.product.id == product.id }
                )
                else { return .none }
                let productStateId = state.productListState[index].id
                
                state.productListState[id: productStateId]?.count = 0
                state.productListState[id: productStateId]?.addToCartState.count = 0
                return .none
            case .setCartView(let isPresented):
                state.shouldOpenCart = isPresented
                state.cartState = isPresented
                ? CartListDomain.State(
                    cartItems: IdentifiedArrayOf(
                        uniqueElements: state
                            .productListState
                            .compactMap { state in
                                state.count > 0
                                ? CartItemDomain.State(
                                    id: UUID(),
                                    cartItem: CartItem(
                                        id: UUID(),
                                        product: state.product,
                                        quantity: state.count
                                    )
                                )
                                : nil
                            }
                    )
                )
                : nil
                return .none
            case .product(let id, let action):
                return .none
            }
        }
    )
    
    private static func closeCart(
        state: inout State
    ) -> Effect<Action, Never> {
        state.shouldOpenCart = false
        state.cartState = nil
        
        return .none
    }
}
