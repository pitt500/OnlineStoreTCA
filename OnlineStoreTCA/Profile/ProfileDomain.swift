//
//  ProfileDomain.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import Foundation
import ComposableArchitecture

struct ProfileDomain: Reducer {
    struct State: Equatable {
        var profile: UserProfile = .default
        fileprivate var dataState = DataState.notStarted
        var isLoading: Bool {
            dataState == .loading
        }
    }
    
    fileprivate enum DataState {
        case notStarted
        case loading
        case complete
    }
    
    enum Action: Equatable {
        case fetchUserProfile
        case fetchUserProfileResponse(TaskResult<UserProfile>)
    }
    
    var fetchUserProfile: () async throws -> UserProfile
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchUserProfile:
            if state.dataState == .complete || state.dataState == .loading {
                return .none
            }
            
            state.dataState = .loading
            return .run { send in
                await send(.fetchUserProfileResponse(
                    TaskResult { try await fetchUserProfile() }
                ))
            }
        case .fetchUserProfileResponse(.success(let profile)):
            state.dataState = .complete
            state.profile = profile
            return .none
        case .fetchUserProfileResponse(.failure(let error)):
            state.dataState = .complete
            print("Error: \(error)")
            return .none
        }
    }
}
