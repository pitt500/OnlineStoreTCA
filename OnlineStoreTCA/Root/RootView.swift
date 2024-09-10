//
//  RootView.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 24/08/22.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
	@Perception.Bindable var store: StoreOf<RootDomain>
	
	var body: some View {
		WithPerceptionTracking {
			TabView(
				selection: $store.selectedTab.sending(\.tabSelected)
			) {
				ProductListView(
					store: self.store.scope(
						state: \.productListState,
						action: \.productList
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
						action: \.profile
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
