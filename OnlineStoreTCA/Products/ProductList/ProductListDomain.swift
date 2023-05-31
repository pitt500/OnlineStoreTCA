//
//  ProductListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

struct ProductListDomain: ReducerProtocol {
    struct State: Equatable {
        var dataLoadingStatus = DataLoadingStatus.notStarted
        var shouldOpenCart = false
        var cartState: CartListDomain.State?
        var productList: IdentifiedArrayOf<ProductDomain.State> = []
        
        var shouldShowError: Bool {
            dataLoadingStatus == .error
        }
        
        var isLoading: Bool {
            dataLoadingStatus == .loading
        }
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
    
    var fetchProducts:  @Sendable () async throws -> [Product]
    var sendOrder:  @Sendable ([CartItem]) async throws -> String
    var uuid: @Sendable () -> UUID
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchProducts:
                if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                    return .none
                }
                
                state.dataLoadingStatus = .loading
                return .task {
                    await .fetchProductsResponse(
                        TaskResult { try await fetchProducts() }
                    )
                }
            case .fetchProductsResponse(.success(let products)):
                state.dataLoadingStatus = .success
                state.productList = IdentifiedArrayOf(
                    uniqueElements: products.map {
                        ProductDomain.State(
                            id: uuid(),
                            product: $0
                        )
                    }
                )
                return .none
            case .fetchProductsResponse(.failure(let error)):
                state.dataLoadingStatus = .error
                print(error)
                print("Error getting products, try again later.")
                return .none
            case .cart(let action):
                switch action {
                case .didPressCloseButton:
                    return closeCart(state: &state)
                case .dismissSuccessAlert:
                    resetProductsToZero(state: &state)
                    
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
                
                guard let index = state.productList.firstIndex(
                    where: { $0.product.id == product.id }
                )
                else { return .none }
                let productStateId = state.productList[index].id
                
                state.productList[id: productStateId]?.addToCartState.count = 0
                return .none
            case .setCartView(let isPresented):
                state.shouldOpenCart = isPresented
                state.cartState = isPresented
                ? CartListDomain.State(
                    cartItems: IdentifiedArrayOf(
                        uniqueElements: state
                            .productList
                            .compactMap { state in
                                state.count > 0
                                ? CartItemDomain.State(
                                    id: uuid(),
                                    cartItem: CartItem(
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
            case .product:
                return .none
            }
        }
        .forEach(\.productList, action: /ProductListDomain.Action.product(id:action:)) {
            ProductDomain()
        }
        .ifLet(\.cartState, action: /ProductListDomain.Action.cart) {
            CartListDomain(sendOrder: sendOrder)
        }
    }
    
    private func closeCart(
        state: inout State
    ) -> EffectTask<Action> {
        state.shouldOpenCart = false
        state.cartState = nil
        
        return .none
    }
    
    private func resetProductsToZero(
        state: inout State
    ) {
        for id in state.productList.map(\.id) {
            state.productList[id: id]?.count = 0
        }
    }
}
