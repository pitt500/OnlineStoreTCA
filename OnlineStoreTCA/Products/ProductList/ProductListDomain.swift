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
        var shouldOpenCart = false
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
        case showCart(PresentationAction<CartListDomain.Action>)
        case cart(CartListDomain.Action)
        case products(IdentifiedActionOf<ProductDomain>)
        case resetProduct(product: Product)
        case closeCart
        case goToCartButtonTapped
    }
    
    var fetchProducts:  @Sendable () async throws -> [Product]
    var sendOrder:  @Sendable ([CartItem]) async throws -> String
    var uuid: @Sendable () -> UUID
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchProducts:
                return fetchProducts(state: &state)
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
                case .alert(.presented(.dismissSuccessAlert)):
                    resetProductsToZero(state: &state)
                    
                    return .run { send in
                        await send(.closeCart)
                    }
                case .cartItems(.element(_, let action)):
                    switch action {
                    case .deleteCartItem(let product):
                        return .run { send in
                            await send(.resetProduct(product: product))
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
                
            case .goToCartButtonTapped:
                configureCartState(state: &state)
                return .none
            case .showCart(.presented(.didPressCloseButton)):
                state.cartState = nil
                return .none
            case .showCart:
                return .none
            case .products:
                return .none
            }
        }
        .forEach(\.productList, action: \.products) {
            ProductDomain()
        }
        .ifLet(\.cartState, action: \.cart) {
            CartListDomain(sendOrder: sendOrder)
        }
    }
    
    private func closeCart(
        state: inout State
    ) -> Effect<Action> {
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
    
    private func configureCartState(
        state: inout State
    ) {
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
    }
    
    private func fetchProducts(
        state: inout State
    ) -> Effect<Action> {
        if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
            return .none
        }
        
        state.dataLoadingStatus = .loading
        return .run { send in
            do {
                let products = try await fetchProducts()
                await send(.fetchProductsResponse(.success(products)))
            } catch {
                await send(.fetchProductsResponse(.failure(error)))
            }
        }
    }
}
