//
//  AmiiboDomain.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 05/06/22.
//

import Foundation
import ComposableArchitecture

struct AmiiboDomain {
    struct State: Equatable {
        var amiiboList: [Amiibo] = []
        var selectedAmibo: [Amiibo.ID: Int] = [:]
        var shouldShowCartView = false
    }
    
    enum Action {
        case onAppear
        case dataLoaded(Result<[Amiibo], APIError>)
        case amiiboSelected(Amiibo)
        case showCart
    }
    
    struct Environment {
        var amiiboRequest: (JSONDecoder) -> Effect<[Amiibo], APIError>
        var decoder: () -> JSONDecoder
        var mainQueue: () -> AnySchedulerOf<DispatchQueue>
    }
    
    static let reducer = Reducer<
        State,
        Action,
        Environment
    > { state, action, environment in
        switch action {
        case .onAppear:
            return environment.amiiboRequest(environment.decoder())
                .receive(on: environment.mainQueue())
                .catchToEffect()
                .map(AmiiboDomain.Action.dataLoaded)
        case .dataLoaded(let result):
            switch result {
            case .success(let amiiboList):
                state.amiiboList = amiiboList
            case .failure(let error):
                print(error)
            }
            return .none
        case .amiiboSelected(let amiibo):
            state.selectedAmibo[amiibo.id, default: 0] += 1
            return .none
        case .showCart:
            state.shouldShowCartView = true
            return .none
        }
    }
}
