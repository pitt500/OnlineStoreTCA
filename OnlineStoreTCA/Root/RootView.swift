//
//  RootView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
	let store: StoreOf<RootDomain>
	
	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			TabView(
				selection: viewStore.binding(
					get: \.selectedTab,
					send: RootDomain.Action.tabSelected
				)
			) {
				ProductListView(
					store: self.store.scope(
						state: \.productListState,
						action: RootDomain.Action
							.productList
					)
				)
				.tabItem {
					Image(systemName: "list.bullet")
					Text("Products")
				}
				.tag(RootDomain.Tab.products)
				ProfileView(
					store: self.store.scope(
						state: \.profileState,
						action: RootDomain.Action.profile
					)
				)
				.tabItem {
					Image(systemName: "person.fill")
					Text("Profile")
				}
				.tag(RootDomain.Tab.profile)
			}
		}
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView(
			store: Store(
				initialState: RootDomain.State()
			) {
				RootDomain()
			} withDependencies: {
				$0.apiClient.fetchProducts = { Product.sample }
				$0.apiClient.sendOrder = { _ in "OK" }
				$0.apiClient.fetchUserProfile = { UserProfile.sample }
				$0.uuid = .incrementing
			}
		)
	}
}
