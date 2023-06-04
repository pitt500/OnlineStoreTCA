# NOTE
This demo was implemented using version [0.54.0](https://pointfreeco.github.io/swift-composable-architecture/0.54.0/documentation/composablearchitecture/) of TCA.

# Online Store made with Composable Architecture (TCA)
The purpose of this demo is to explore the main concepts of TCA. If this is your first time reading about it, I **strongly** recommend you to read first the README from the [main repo](https://github.com/pointfreeco/swift-composable-architecture) and watch the [Tour of TCA](https://www.pointfree.co/collections/composable-architecture/a-tour-of-the-composable-architecture).

## Content
* [Motivation](#motivation)
* [Screenshots of the app](#screenshots)
* [The basics](#the-basics)
    * [Archiecture Diagram](#archiecture-diagram)
    * [Hello World Example](#hello-world-example)
* [Composition](#composition)
    * [Body to compose multiple Reducers](#body-to-compose-multiple-reducers)
    * [Single state operators](#single-state-operators)
      * [store.scope(state:action:)](#storescopestateaction)
      * [Scope in Reducers](#scope-in-reducers)
    * [Collection of states](#collection-of-states)
      * [forEach in Reducer](#foreach-in-reducer)
* [Dependencies](#dependencies)
* [Side Effects](#side-effects)
    * [Network Calls](#network-calls)
* [Testing](#testing)
* [Other Topics](#other-topics)
    * [Opening Modal Views](#opening-modal-views)
    * [Optional States](#optional-states)
    * [Private Actions](#private-actions)
    * [Alert Views in SwiftUI](#alert-views-in-swiftui)
    * [Making a Root Domain with Tab View](#making-a-root-domain-with-tab-view)
* [Contact](#contact)


## Motivation
**TL;DR:** Build an app with TCA not too simple nor too complex to study the most important use cases, and provide concise documentation to new learners.

I wanted to demostrate the power of this great architecture to build applications for Apple ecosystem, like iOS, macOS, etc. (btw, soon will be expanded beyond Apple world! 🚀).

However, if you want to start learning TCA, you will find a lot of articles describing a simple one-screen application to ilustrate the main concepts. Don't get me wrong, that's a great way to start, but I feel that we have a gap between very simple demos and real world applications like [isoword](https://github.com/pointfreeco/isowords) that could be too complex to understand some other important use cases (like navigation and how reducers are glued).

In this demo I've implemented a minimal online store that is actually connecting to a real network API (https://fakestoreapi.com). We got a list of products available, we can choose to add an item to the cart, add more than one item like any other e-commerce app (like Amazon for example), and once you are ready to purchase, move to the cart and send your order to the server.

Of course, we are using fakestoreapi.com, which means your requests aren't going to be processed for real, but all the networks status are, and you can play with it to map what it would be working with network calls using TCA.

Even if this demo is not considered a real-world app, it has enough reducers to ilustrate how data should be glued in order to interact together and isolate domains that only cared for very specific components within the app (For example: Tabs -> Product List -> Product Cell -> Add to Cart button).

Additionally, I've created tests to demostrate one of the key features of TCA and how it makes a test to fail if you didn't capture the actual mutation of your state.

**Note:** Feel free to add any feedback!

## Screenshots
### Tabs
<img src="./Images/demo1.png"  width="25%" height="25%">|<img src="./Images/demo2.png"  width="25%" height="25%">|<img src="./Images/demo6.png"  width="25%" height="25%">

### Cart
<img src="./Images/demo3.png"  width="25%" height="25%">|<img src="./Images/demo4.png"  width="25%" height="25%">|<img src="./Images/demo5.png"  width="25%" height="25%">

## The basics
### Archiecture Diagram
<img src="./Images/TCA_Architecture2.png">

### Hello World Example
Consider the following implementation of a simple app using TCA, where you will have two buttons: one to increment a counter displayed on the screen and the other to decrement it.

Here's an example of how this app would be coded with TCA:

1. A struct that will represent the domain of the feature. This struct must conform `ReducerProtocol` protocol and providing `State` struct, `Action` enum and `reduce` method.

```swift
struct CounterDomain: ReducerProtocol {
    struct State {
        // State of the feature
    }

    enum Action {
        // actions that use can do in the app
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        // Method that will mutate the state given an action.
    }
}
```

2. The view that is presented in the screen will display the current state of the app.
<img src="./Images/viewDemo1.png" width="30%" height="30%">

```swift
struct State: Equatable {
    var counter = 0
}
```

3. When the user presses a button (let's say increase button), it will internally send an action to the store.
<img src="./Images/actionDemo1.png" width="30%" height="30%">

```swift
enum Action: Equatable {
    case increaseCounter
    case decreaseCounter
}
```

4. The action will be received by the reducer and proceed to mutate the state. Reducer MUST also return an effect, that represent logic from the "outside world" (network calls, notifications, database, etc). If no effect is needed, just return `EffectTask.none` .

```swift
func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .increaseCounter:
        state.counter += 1
        return .none
    case .decreaseCounter:
        state.counter -= 1
        return .none
    }
}
```

5. Once the mutation is done and the reducer returned the effect, the view will render the update in the screen. 
<img src="./Images/viewUpdateDemo1.png" width="30%" height="30%">

7. To observe state changes in TCA, we need an object called `viewStore`, that in this example is wrapped within WithViewStore view. We can send an action from the view to the store using `viewStore.send()` and an `Action` value.

```swift
struct ContentView: View {
    let store: Store<State, Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button {
                    viewStore.send(.decreaseCounter)
                } label: {
                    Text("-")
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Text(viewStore.counter.description)
                    .padding(5)

                Button {
                    viewStore.send(.increaseCounter)
                } label: {
                    Text("+")
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
```

7. View is initialized by a `Store` object.

```swift
ContentView(
    store: Store(
        initialState: CounterDomain.State(),
        reducer: CounterDomain()
    )
)
```

If you want to learn more about the basics, check out the following [video](https://youtu.be/SfFDj6qT-xg)

> Note: The videos shared here were made using the legacy version of TCA with Environment and without `ReducerProtocol`. If you want to see the legacy version of TCA, check out this [branch](https://github.com/pitt500/OnlineStoreTCA/tree/legacy-tca-with-environment).

## Composition

Composition refers to the process of building complex software systems by combining smaller, reusable software components. Take a look to this image:

<img src="./Images/composition2.png" width="80%" height="80%">

We started with a simple button counter, then we add an extra state to display text, next we put the whole button in a Product cell, and finally, each product cell will be part of a Product list. That is composition!

### Body to compose multiple Reducers
In the previous example, we demonstrated the usage of `reduce(into:action:)` to create our reducer function and define how state will be modified for each action. However, it's important to note that this method is suitable only for leaf components, which refer to the smallest components in your application.

For larger components, we can leverage the `body` property provided by the `ReducerProtocol`. This property enables you to combine multiple reducers, facilitating the creation of more comprehensive components. By utilizing the `body` property, you can effectively compose and manage the state mutations of these larger components.
```swift
var body: some ReducerProtocol<State, Action> {
    ChildReducer1()
    Reduce { state, action in
        switch action {
        case .increaseCounter:
            state.counter += 1
            return .none
        case .decreaseCounter:
            state.counter -= 1
            return .none
        }
    }
    ChildReducer2()
}
```

The `Reduce` closure will always encapsulate the logic from the parent domain. To understand how to combine additional components, please continue reading below.

> Compared to the previous version of TCA without `ReducerProtocol`, the order of child reducers will not affect the result. Parent Reducer (`Reduce`) will be always executed at the end.

### Single state operators

For single states (all except collections/lists), TCA provides operators to glue the components and make bigger ones.

#### store.scope(state:action:) 
`store.scope` is an operator used in views to get the child domain's (`AddToCartDomain`) state and action from parent domain (`ProductDomain`) to initialize subviews. 
For example, the `ProductDomain` below contains two properties as part of its state: `product` and `addToCartState`.

```swift
struct ProductDomain: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let product: Product
        var addToCartState = AddToCartDomain.State()
    }
    // ...
```

Furthermore, we utilize an action with an associated value that encapsulates all actions from the child domain, providing a comprehensive and cohesive approach.
```swift
struct ProductDomain: ReducerProtocol {
    // State ...

    enum Action {
        case addToCart(AddToCartDomain.Action)
    }
    // ...
```

Let's consider the scenario where we need to configure the `ProductCell` view below. The `ProductCell` is designed to handle the `ProductDomain`, while we need to provide some information to initialize the `AddToCartButton`. However, the `AddToCartButton` is only aware of its own domain, `AddToCartDomain`, and not the `ProductDomain`. To address this, we can use the `scope` method from `store` to get the child's state and action from parent domain. This enables us to narrow down the scope of the button to focus solely on its own functionality.

```swift
struct ProductCell: View {
    let store: Store<ProductDomain.State, ProductDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            // More views here ...
            AddToCartButton(
                store: self.store.scope(
                    state: \.addToCartState,
                    action: ProductDomain.Action.addToCart
                )
            )
        }
    }
```
By employing this approach, the `AddToCartDomain` will solely possess knowledge of its own state and remain unaware of any product-related information.

#### Scope in Reducers
`Scope` is utilized within the `body` to seamlessly transform the child reducer (`AddToCart`) into a compatible form that aligns with the parent reducer (`Product`). This allows for smooth integration and interaction between the two.
```swift
var body: some ReducerProtocol<State, Action> {
    Scope(state: \.addToCartState, action: /ProductDomain.Action.addToCart) {
        AddToCartDomain()
    }
    Reduce { state, action in
        // Parent Reducer logic ...
    }
}
```
This transformation becomes highly valuable when combining multiple reducers to construct a more complex component.

> In earlier versions, the `pullback` and `combine` operators were employed to carry out the same operation. You can watch this [video](https://youtu.be/Zf2pFEa3uew).

### Collection of states

Are you looking to manage a collection of states? TCA offers excellent support for that as well!

In this particular example, instead of using a regular array, TCA requires a list of (`Product`) states, which can be achieved by utilizing `IdentifiedArray`:
```swift
struct ProductListDomain: ReducerProtocol {
    struct State: Equatable {
        var productList: IdentifiedArrayOf<ProductDomain.State> = []
        // ...    
    }
    // ...
}
```

#### forEach in Reducer

The `forEach` operator functions similarly to the [`Scope`](#scope-in-reducers) operator, with the distinction that it operates on a collection of states. It effectively transforms the child reducers into compatible forms that align with the parent reducer.

```swift
struct ProductListDomain: ReducerProtocol {
    // State and Actions ...
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            // Parent Reducer...
        }
        .forEach(
            \.productList, 
            action: /ProductListDomain.Action.product(id:action:)
        ) {
            ProductDomain()
        }
    }
}
```

Subsequently, in the user interface, we employ `ForEachStore` and `store.scope` to iterate through all the (`Product`) states and actions. This enables us to send actions to the corresponding cell and modify its state accordingly.
```swift
List {
    ForEachStore(
        self.store.scope(
            state: \.productListState,
            action: ProductListDomain.Action
                .product(id: action:)
        )
    ) {
        ProductCell(store: $0)
    }
}
```

> There's a legacy `forEach` operator, If you want to learn more, check out this [video](https://youtu.be/sid-zfggYhQ)

## Dependencies
In previous iterations of TCA, `Environment` played a crucial role in consolidating all the dependencies utilized by a domain.

With the introduction of the [`ReducerProtocol`](https://www.pointfree.co/blog/posts/81-announcing-the-reducer-protocol), we have eliminated the concept of `Environment`. As a result, dependencies now reside directly within the domain.

```swift
struct ProductListDomain: ReducerProtocol {
    // State ...

    // Actions...

    var fetchProducts:  () async throws -> [Product]
    var sendOrder: ([CartItem]) async throws -> String
    var uuid: () -> UUID

    // Reducer ...
}
```

Nevertheless, we have the option to leverage the [Dependencies Framework](https://github.com/pointfreeco/swift-dependencies) to achieve a more enhanced approach in managing our dependencies:

```swift
struct ProductListDomain: ReducerProtocol {
    // State ...

    // Actions...

    @Dependency(\.apiClient.fetchProducts) var fetchProducts
    @Dependency(\.apiClient.sendOrder) var sendOrder
    @Dependency(\.uuid) var uuid

    // Reducer ...
}
```

> If you want to learn more about how Environment object works on TCA, take a look to this [video](https://youtu.be/sid-zfggYhQ?list=PLHWvYoDHvsOVo4tklgLW1g7gy4Kmk4kjw&t=103)

## Side Effects
A side effect refers to an observable change that arises when executing a function or method. This encompasses actions such as modifying state outside the function, performing I/O operations to a file or making network requests. TCA facilitates the encapsulation of such side effects through the use of `EffectTask` objects.

<img src="./Images/sideEffects1.png" width="80%" height="80%">

> If you want to learn more about side effects, check out this [video](https://youtu.be/t3HHam3GYkU)

### Network calls
Network calls are a fundamental aspect of mobile development, and TCA offers robust tools to handle them efficiently. As network calls are considered external interactions or [side effects](#side-effects), TCA utilizes the `EffectTask` object to encapsulate these calls. Specifically, network calls are encapsulated within the `EffectTask.task` construct, allowing for streamlined management of asynchronous operations within the TCA framework.

However, it's important to note that the task operator alone is responsible for making the web API call. To obtain the actual response, an additional action needs to be implemented, which will capture and store the result within a `TaskResult` object.

```swift
struct ProductListDomain: ReducerProtocol {
    // State and more ...
    
    enum Action: Equatable {
        case fetchProducts
        case fetchProductsResponse(TaskResult<[Product]>)
    }
   
    var fetchProducts: () async throws -> [Product]
    var uuid: () -> UUID
    
    var body: some ReducerProtocol<State, Action> {
        // Other child reducers...
        Reduce { state, action in
            switch action {
            case .fetchProducts:
                return .task {
                    // Just making the call 
                    await .fetchProductsResponse(
                        TaskResult { try await fetchProducts() }
                    )
                }
            case .fetchProductsResponse(.success(let products)):
                // Getting the success response
                state.productListState = IdentifiedArrayOf(
                    uniqueElements: products.map {
                        ProductDomain.State(
                            id: uuid(),
                            product: $0
                        )
                    }
                )
                return .none
            case .fetchProductsResponse(.failure(let error)):
                // Getting an error from the web API
                print("Error getting products, try again later.", error)
                return .none
            }
        }
    }
}
```

> To learn more about network requests in TCA, I recommend watching this insightful [video](https://youtu.be/sid-zfggYhQ?list=PLHWvYoDHvsOVo4tklgLW1g7gy4Kmk4kjw&t=144) that explains asynchronous requests. Additionally, you can refer to this informative [video](https://youtu.be/j2qymM6i9n4) that demonstrates the configuration of a real web API call, providing practical insights into the process.

## Testing

TBD

## Other topics

### Opening Modal Views

If you require to open a view modally in SwiftUI, you will need to use sheet modifier and provide a binding parameter:
```swift
func sheet<Content>(
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content
) -> some View where Content : View
```

To utilize this modifier (or any modifier with binding parameters) in TCA, it is necessary to employ the `binding` operator from `viewStore` and supply two parameters:

1. The state property that will undergo mutation.
2. The action that will trigger the mutation.

```swift
// Domain:
struct Domain: ReducerProtocol {
    struct State {
        var shouldOpenModal = false
    }
    enum Action {
        case setCartView(isPresented: Bool)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                case .setCartView(let isPresented):
                    state.shouldOpenModal = isPresented
            }
        }
    }
}

// UI:
Text("Parent View")
.sheet(
    isPresented: viewStore.binding(
        get: \.shouldOpenModal,
        send: Action.setModalView(isPresented:)
    )
) {
    Text("I'm a Modal View!")
}
```

> If you want to lean more about Binding with TCA and SwiftUI, take a look to this [video](https://youtu.be/Ilr8AsoggIY).

### Optional States

By default, TCA keeps a state in memory throughout the entire lifecycle of an app. However, in certain scenarios, maintaining a state can be resource-intensive and unnecessary. One such case is when dealing with modal views that are displayed for a short duration. In these situations, it is more efficient to use optional states.

Creating an optional state in TCA follows the same approach as declaring any optional value in Swift. Simply define the property within the parent state, but instead of assigning a default value, declare it as optional. For instance, in the provided example, the `cartState` property holds an optional state for a Cart List.

```swift
struct ProductListDomain: ReducerProtocol {
    struct State: Equatable {
        var productListState: IdentifiedArrayOf<ProductDomain.State> = []
        var shouldOpenCart = false
        var cartState: CartListDomain.State?
        
        // More properties...
    }
}
```

Now, in the `Reduce` function, we can utilize the `ifLet` operator to transform the child reducer (`CartListDomain`) into one that is compatible with the parent reducer (`ProductList`). 

In the provided example, the `CartListDomain` will be evaluated only if the `cartState` is non-nil. To assign a new non-optional state, the parent reducer will need to initialize the property (`cartState`) when a specific action (`setCartView`) is triggered. 

This approach ensures that the optional state is properly handled within the TCA framework and allows for seamless state management between the parent and the optional child reducers.

```swift
struct ProductListDomain: ReducerProtocol {
    // State and Actions ...
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            //  More cases ...
            case .setCartView(let isPresented):
                state.shouldOpenCart = isPresented
                state.cartState = isPresented
                ? CartListDomain.State(...)
                : nil
                return .none
            }
        }
        .ifLet(\.cartState, action: /ProductListDomain.Action.cart) {
            CartListDomain()
        }
    }
}
```

Lastly, in the view, you can employ `IfLetStore` to unwrap a store with optional state. This allows you to conditionally display the corresponding view that operates with that particular state.


```swift
List {
    ForEachStore(
        self.store.scope(
            state: \.productListState,
            action: ProductListDomain.Action
                .product(id: action:)
        )
    ) {
        ProductCell(store: $0)
    }
}
.sheet(
    isPresented: viewStore.binding(
        get: \.shouldOpenCart,
        send: ProductListDomain.Action.setCartView(isPresented:)
    )
) {
    IfLetStore(
        self.store.scope(
            state: \.cartState,
            action: ProductListDomain.Action.cart
        )
    ) {
        CartListView(store: $0)
    }
}
```

> If you want to learn more about optional states, check out this [video](https://youtu.be/AV0laQw2OjM).

### Private Actions

By default, when you declare an action in a TCA domain, it is accessible to other reducers as well. However, there are situations where an action is intended to be specific to a particular reducer and does not need to be exposed outside of it. 

In such cases, you can simply declare private functions to encapsulate those actions within the domain's scope. This approach ensures that the actions remain private and only accessible within the intended context, enhancing the encapsulation and modularity of your TCA implementation:

```swift
var body: some ReducerProtocol<State, Action>
    // More reducers ...
    Reduce { state, action in
        switch action {
        // More actions ...
        case .cart(let action):
            switch action {
            case .didPressCloseButton:
                return closeCart(state: &state)
            case .dismissSuccessAlert:
                resetProductsToZero(state: &state)

                return .task {
                    .closeCart
                }
            }
        case .closeCart:
            return closeCart(state: &state)
        }
    }
}

private func closeCart(
        state: inout State
) -> Effect<Action, Never> {
    state.shouldOpenCart = false
    state.cartState = nil

    return .none
}

private func resetProductsToZero(
    state: inout State
) {
    for id in state.productListState.map(\.id)
    where state.productListState[id: id]?.count != 0  {
        state.productListState[id: id]?.addToCartState.count = 0
    }
}
```

> For more about private actions, check out this [video](https://youtu.be/7BkZX_7z-jw).

### Alert Views in SwiftUI

The TCA library also offers support for `AlertView`, enabling the addition of custom state and a consistent UI building approach without deviating from the TCA architecture. To create your own alert using TCA, follow these steps:

1. Create an `AlertState with actions of your own domain.
2. Create the actions that will trigger events for the alert:
    - Initialize AlertState (`didPressPayButton`)
    - Dismiss the alert (`didCancelConfirmation`)
    - Execute the alert's handler (`didConfirmPurchase`)

```swift
struct CartListDomain: ReducerProtocol {
    struct State: Equatable {
        var confirmationAlert: AlertState<CartListDomain.Action>?
        
        // More properties ...
    }
    
    enum Action: Equatable {
        case didPressPayButton
        case didCancelConfirmation
        case didConfirmPurchase
        
        // More actions ...
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didCancelConfirmation:
                state.confirmationAlert = nil
                return .none
            case .didConfirmPurchase:
                // Sent order and Pay ...
            case .didPressPayButton:
                state.confirmationAlert = AlertState(
                    title: TextState("Confirm your purchase"),
                    message: TextState("Do you want to proceed with your purchase of \(state.totalPriceString)?"),
                    buttons: [
                        .default(
                            TextState("Pay \(state.totalPriceString)"),
                            action: .send(.didConfirmPurchase)),
                        .cancel(TextState("Cancel"), action: .send(.didCancelConfirmation))
                    ]
                )
                return .none
            // More actions ...
            }
        }
        .forEach(\.cartItems, action: /Action.cartItem(id:action:)) {
            CartItemDomain()
        }
    }
}
                
```

3. Invoke the UI

<img src="./Images/alertView1.png" width="50%" height="50%">

```swift
let store: Store<CartListDomain.State, CartListDomain.Action>

Text("Parent View")
.alert(
    self.store.scope(state: \.confirmationAlert, action: { $0 }),
    dismiss: .didCancelConfirmation
)
```

> Explicit action is always needed for `store.scope`. Check out this commit to learn more: https://github.com/pointfreeco/swift-composable-architecture/commit/da205c71ae72081647dfa1442c811a57181fb990

This [video](https://youtu.be/U3EMduy-DhE) explains more about AlertView in SwiftUI and TCA.

### Making a Root Domain with Tab View

Creating a Root Domain in TCA is similar to creating any other domain. In this case, each property within the state will correspond to a complex substate. To handle tab logic, we can include an enum that represents each tab item, providing a structured approach to managing the different tabs:

```swift
struct RootDomain: ReducerProtocol {
    struct State: Equatable {
        var selectedTab = Tab.products
        var productListState = ProductListDomain.State()
        var profileState = ProfileDomain.State()
    }
    
    enum Tab {
        case products
        case profile
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
        case productList(ProductListDomain.Action)
        case profile(ProfileDomain.Action)
    }
    
    // Dependencies
    var fetchProducts: @Sendable () async throws -> [Product]
    var sendOrder:  @Sendable ([CartItem]) async throws -> String
    var fetchUserProfile:  @Sendable () async throws -> UserProfile
    var uuid: @Sendable () -> UUID
    
    static let live = Self(
        fetchProducts: APIClient.live.fetchProducts,
        sendOrder: APIClient.live.sendOrder,
        fetchUserProfile: APIClient.live.fetchUserProfile,
        uuid: { UUID() }
    )
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .productList:
                return .none
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            case .profile:
                return .none
            }
        }
        Scope(state: \.productListState, action: /RootDomain.Action.productList) {
            ProductListDomain(
                fetchProducts: fetchProducts,
                sendOrder: sendOrder,
                uuid: uuid
            )
        }
        Scope(state:  \.profileState, action: /RootDomain.Action.profile) {
            ProfileDomain(fetchUserProfile: fetchUserProfile)
        }
    }
}
```

When it comes to the UI implementation, it closely resembles the standard SwiftUI approach, with a small difference. Instead of using a regular property, we hold the `store` property to manage the currently selected tab:

```swift
struct RootView: View {
    let store: Store<RootDomain.State, RootDomain.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
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
```

To call RootView, we provide the initial domain state and the reducer:
To instantiate the `RootView`, you need to provide two parameters: the initial domain state and the reducer:

```swift
@main
struct OnlineStoreTCAApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(
                    initialState: RootDomain.State(),
                    reducer: RootDomain.live
                )
            )
        }
    }
}
```

These elements enable the proper initialization and functioning of the `RootView` within the TCA architecture.

> For a comprehensive understanding of this implementation, I recommend checking out this [video](https://youtu.be/a_FwMVIhCHY).

## Contact
If you have any feedback, I would love to hear from you. Please feel free to reach out to me through any of my social media channels:

* [Youtube](https://youtube.com/@swiftandtips)
* [Twitter](https://twitter.com/swiftandtips)
* [LinkedIn](https://www.linkedin.com/in/pedrorojaslo/)
* [Mastodon](https://iosdev.space/@swiftandtips)

Thanks for reading, and have a great day! 😄
