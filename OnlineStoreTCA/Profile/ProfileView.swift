//
//  ProfileView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 25/08/22.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    let store: StoreOf<ProfileDomain>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationView {
                ZStack {
                    Form {
                        Section {
                            Text(store.profile.firstName.capitalized)
                            +
                            Text(" \(store.profile.lastName.capitalized)")
                        } header: {
                            Text("Full name")
                        }
                        
                        Section {
                            Text(store.profile.email)
                        } header: {
                            Text("Email")
                        }
                    }
                    
                    if store.isLoading {
                        ProgressView()
                    }
                }
                .task {
                    store.send(.fetchUserProfile)
                }
                .navigationTitle("Profile")
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            store: Store(initialState: ProfileDomain.State()) {
                ProfileDomain()
            } withDependencies: {
                $0.apiClient.fetchUserProfile = { .sample }
            }
        )
    }
}
