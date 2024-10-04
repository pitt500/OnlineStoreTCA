//
//  ProductListDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 17/08/22.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProductListDomain {
    @ObservableState
    struct State: Equatable {
        var dataLoadingStatus = DataLoadingStatus.notStarted
        @Presents var cartState: CartListDomain.State?
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
        case cancelButtonTapped
        case cartButtonTapped
        case cart(PresentationAction<CartListDomain.Action>)
        case product(IdentifiedActionOf<ProductDomain>)
        case resetProduct(product: Product)
    }
    
    @Dependency(\.apiClient.fetchProducts) var fetchProducts
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .fetchProducts:
                    if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                        return .none
                    }
                    
                    state.dataLoadingStatus = .loading
                    return .run { send in
                        await send(
                            .fetchProductsResponse(
                                TaskResult { try await self.fetchProducts() }
                            )
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
                case .cancelButtonTapped:
                    state.cartState = nil
                    return .none
                case .cart(.presented(let action)):
                    switch action {
                        case .delegate(.orderFinished):
                            resetProductsToZero(state: &state)
                            state.cartState = nil
                            return .none
                        case .cartItem(.element(id: _, action: let action)):
                            switch action {
                                case .deleteCartItem(let product):
                                    return .send(.resetProduct(product: product))
                            }
                        default:
                            return .none
                    }
                case .cart:
                    return .none
                case .resetProduct(let product):
                    
                    guard let index = state.productList.firstIndex(
                        where: { $0.product.id == product.id }
                    )
                    else { return .none }
                    let productStateId = state.productList[index].id
                    
                    state.productList[id: productStateId]?.addToCartState.count = 0
                    return .none
                case .cartButtonTapped:
                    state.cartState = CartListDomain.State(
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
                    return .none
                case .product:
                    return .none
            }
        }
        .forEach(\.productList, action: \.product) {
            ProductDomain()
        }
        .ifLet(\.$cartState, action: \.cart) {
            CartListDomain()
        }
    }
    
    private func resetProductsToZero(
        state: inout State
    ) {
        for id in state.productList.map(\.id) {
            state.productList[id: id]?.count = 0
        }
    }
}
