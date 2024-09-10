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
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ZStack {
                    Form {
                        Section {
                            Text(viewStore.profile.firstName.capitalized)
                            +
                            Text(" \(viewStore.profile.lastName.capitalized)")
                        } header: {
                            Text("Full name")
                        }
                        
                        Section {
                            Text(viewStore.profile.email)
                        } header: {
                            Text("Email")
                        }
                    }
                    
                    if viewStore.isLoading {
                        ProgressView()
                    }
                }
                .task {
                    viewStore.send(.fetchUserProfile)
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
