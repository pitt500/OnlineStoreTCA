//
//  ProductDetailsViewDomain.swift
//  OnlineStoreTCA
//
//  Created by Mohamed Alouane on 9/10/2022.
//

import Foundation
import ComposableArchitecture

struct ProductDetailsDomain{
    struct State: Equatable {
        var product: Product
        var dataLoadingStatus = DataLoadingStatus.notStarted
       
        var isLoading: Bool {
            dataLoadingStatus == .loading
        }
    }
    
    enum Action: Equatable{
        case fetchProduct
        case fetchProductResponse(TaskResult<Product>)
        case didPressCloseButton
    }
    
    struct Environment {
        var fetchProduct: @Sendable () async throws -> Product
    }
    
    static let reducer = Reducer <
        State, Action, Environment
    > { state, action, environment in
        switch action {
        
        case .fetchProduct:
            if state.dataLoadingStatus == .success || state.dataLoadingStatus == .loading {
                return .none
            }
            
            state.dataLoadingStatus = .loading
            
            return .task {
                await .fetchProductResponse(
                    TaskResult { try await environment.fetchProduct() }
                )
            }
        case .fetchProductResponse(TaskResult.success(let product)):
            state.dataLoadingStatus = .success
            state.product = product
            return .none
        case .fetchProductResponse(.failure( let error)):
            state.dataLoadingStatus = .error
            print(error)
            print("Error getting products, try again later.")
            return .none
        case .didPressCloseButton:
            return .none
        }
    }
    
}
