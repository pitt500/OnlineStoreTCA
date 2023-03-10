# NOTICE ⚠️
ReducerProtocol Migration will come pretty soon as part of the TCA series. Thanks for your patience!

# Online Store made with Composable Architecture (TCA)
The purpose of this demo is to explore the main concepts of TCA. If this is your first time reading about it, I **strongly** recommend you to read first the README from the [main repo](https://github.com/pointfreeco/swift-composable-architecture) and watch the [Tour of TCA](https://www.pointfree.co/collections/composable-architecture/a-tour-of-the-composable-architecture).

## Motivation
**TL;DR:** Build an app with TCA not too simple nor too complex to study the most important use cases, and provide concise documentation to new learners.

I wanted to demostrate the power of this great architecture to build applications for Apple ecosystem, like iOS, macOS, etc. (btw, soon will be expanded beyond Apple world! 🚀).

However, if you want to start learning TCA, you will find a lot of articles describing a simple one-screen application to ilustrate the main concepts. Don't get me wrong, that's a great way to start, but I feel that we have a gap between very simple demos and real world applications like [isoword](https://github.com/pointfreeco/isowords) that could be too complex to understand some other important use cases (like navigation and how reducers are glued).

In this demo I've implemented a minimal online store that is actually connecting to a real network API (https://fakestoreapi.com). We got a list of products available, we can choose to add an item to the cart, add more than one item like any other e-commerce app (like Amazon for example), and once you are ready to purchase, move to the cart and send your order to the server.

Of course, we are using fakestoreapi.com, which means your requests aren't going to be processed for real, but all the networks status are, and you can play with it to map what it would be working with network calls using TCA.

Even if this demo is not considered a real-world app, it has enough reducers to ilustrate how data should be glued in order to interact together and isolate domains that only cared for very specific components within the app (For example: Tabs -> Product List -> Product Cell -> Add to Cart button).

Additionally, I've created tests to demostrate one of the key features of TCA and how it makes a test to fail if you didn't capture the actual mutation of your state.

Note: Feel free to recommend any change that may be great to teach a concept in a better way or something that you consider should be here too! :) 

## Screenshots
### Tabs
<img src="./Images/demo1.png"  width="25%" height="25%">|<img src="./Images/demo2.png"  width="25%" height="25%">|<img src="./Images/demo6.png"  width="25%" height="25%">

### Cart
<img src="./Images/demo3.png"  width="25%" height="25%">|<img src="./Images/demo4.png"  width="25%" height="25%">|<img src="./Images/demo5.png"  width="25%" height="25%">

## The basics
### Archiecture Diagram
<img src="./Images/TCA_Architecture.png">

### Example
Let's say that you have a simple app with two buttons, one will increase a counter in the screen and the other will decrease it. This is what will happen if this app was implemented on TCA:

1. The view is presented in the screen. It shows the current state of the app.
<img src="./Images/viewDemo1.png" width="30%" height="30%">

```swift
struct State: Equatable {
    var counter = 0
}
```

2. The user press a button (let's say increase button), that internally send an action to the store.
<img src="./Images/actionDemo1.png" width="30%" height="30%">

```swift
enum Action: Equatable {
    case increaseCounter
    case decreaseCounter
}
```

3. The store & reducer require an environment object, that in TCA is just the object holding your dependencies. If you don't have any dependencies yet, just add an empty Environment.
```swift
struct Environment {
    // Future Dependencies...
}
```


4. The action is received by the reducer and proceed to mutate the state. Reducer MUST also return an effect, that represent logic from the "outside world" (network calls, notifications, database, etc). If no effect is needed, just return `Effect.none` .

```swift
let reducer = Reducer<
    State, Action, Environment
> { state, action, environment in
    switch action {
    case .increaseCounter:
        state.counter += 1
        return Effect.none
    case .decreaseCounter:
        state.counter -= 1
        return Effect.none
    }
}
```

5. Once the mutation is done and the reducer returned the effect, the view will render the update in the screen. 
<img src="./Images/viewUpdateDemo1.png" width="30%" height="30%">

7. To observe object in TCA, we need an object called viewStore, that in this example is wrapped within WithViewStore view.
8. We can send another action using `viewStore.send()` and an `Action` value.

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

8. View is initialized by a `Store` object.

```swift
ContentView(
    store: Store(
        initialState: State(),
        reducer: reducer,
        environment: Environment()
    )
)
```

If you want to learn more about the basics, check out the following [video](https://youtu.be/SfFDj6qT-xg)

## Composition

Composition refers to the process of building complex software systems by combining smaller, reusable software components. Take a look to this image:

<img src="./Images/composition2.png" width="80%" height="80%">

We started with a simple button counter, then we add an extra state to display text, next we put the whole button in a Product cell, and finally, each product cell will be part of a Product list. That is composition!

### Single states

For single states (all, except collections/lists), TCA provides operators to glue the components and make bigger ones.

* **Scope**: Scope will expose from parent domain (Product) only the required state and action for the child domain (AddToCart). For example, the ProductDomain below contains two properties as part of its state: product and addToCartState.

```swift
struct ProductDomain {
    struct State: Equatable, Identifiable {
        let product: Product
        var addToCartState = AddToCartDomain.State()
    }
    // ...
```
We don't want to pass around the whole ProductDomain state, instead, we want to reduce the scope as much as possible. In order to do that, we use scope on the child component:

```swift
AddToCartButton(
    store: self.store.scope(
        state: \.addToCartState,
        action: ProductDomain.Action.addToCart
    )
)
```
In this way, AddToCart Domain will only know about its own state and nothing about product and more.

* **Pullback**: Pullback works like a mapping function. It transforms the child reducer (AddToCart) into one compatible with parent reducer (Product).
```swift
AddToCartDomain.reducer
    .pullback(
        state: \.addToCartState,
        action: /ProductDomain.Action.addToCart,
        environment: { _ in
            AddToCartDomain.Environment()
        }
    )
```
This transformation will be really useful when we combine multiple reducers to build a more complex component.

* **Combine**: Combine operator will combine many reducers into a single one by running each one on state in order, and merging all of the effects.
```swift
static let reducer = Reducer<
    State, Action, Environment
>.combine(
    AddToCartDomain.reducer
        .pullback(
            state: \.addToCartState,
            action: /ProductDomain.Action.addToCart,
            environment: { _ in
                AddToCartDomain.Environment()
            }
        ),
    .init { state, action, environment in
        switch action {
        case .addToCart(.didTapPlusButton):
            return .none
        case .addToCart(.didTapMinusButton):
            state.addToCartState.count = max(0, state.addToCartState.count)
            return .none
        }
    }
)
```
With the help of pullback operators, the child reducers can work along with the parent domain to execute each action in order. We have to move the parent reducer at the end to run the child reducers first and then capture any side effect (note: this is not required in ReducerProtocol anymore).

If you want to learn more about these operators, check out this [video](https://youtu.be/Zf2pFEa3uew).

### Collection of states

What about having multiple states to manage?, TCA also have great support for that.

As a first step, we need to hold a list of (Product) states using IdentifiedArray instead of a regular array:
```swift
struct ProductListDomain {
    struct State: Equatable {
        var productListState: IdentifiedArrayOf<ProductDomain.State> = []
        // ...    
    }
    // ...
}
```

* **forEach**: `forEach` operator it's basically a pullback operator, but it will work for a collection of states, transforming the child reducers into ones compatible with parent reducer:

```swift
struct ProductListDomain {
    // State and Actions ...
    
    static let reducer = Reducer<
        State, Action, Environment
    >.combine(
        ProductDomain.reducer.forEach(
            state: \.productListState,
            action: /ProductListDomain.Action.product(id:action:),
            environment: { _ in ProductDomain.Environment() }
        ),
        // More Reducers ...
        .init { state, action, environment in
            switch action {
                // ...
            }
        }
    )
}
```

Then in the UI, we use ForEachStore to iterate over all the (Product) states and actions. This will make possible sending actions to the respective cell and mutate its state.
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

If you want to learn more about forEach operator and ForEachStore, check out this [video](https://youtu.be/sid-zfggYhQ)

## Environment

The environment is a structure that contains all the dependencies needed by the application to perform its tasks. It was part of the TCA foundation before the introduction of [ReducerProtocol](https://www.pointfree.co/blog/posts/81-announcing-the-reducer-protocol) and [Dependencies Framework](https://github.com/pointfreeco/swift-dependencies).

```swift
struct Environment {
    var fetchProducts:  () async throws -> [Product]
    var sendOrder: ([CartItem]) async throws -> String
    var uuid: () -> UUID
}
```

If you want to learn more about how Environment object works on TCA, take a look to this [video](https://youtu.be/sid-zfggYhQ?list=PLHWvYoDHvsOVo4tklgLW1g7gy4Kmk4kjw&t=103)

## Side Effects

A side effect is an observable change that occurs as a result of running a function or method. This can include things like modifying state outside of the function, performing I/O operations like reading or writing to a file, or making network requests. 
TCA helps to encapsulate those side effects through Effects objects.

If you want to learn more about side effects, check out this [video](https://youtu.be/t3HHam3GYkU)

### Network calls

Since network calls are one of the most common tasks in mobile development, of course TCA provides tools for that. And since network calls are part of the outside world (side effects), we use Effect object to wrap the calls, more specifically, into Effect.task.

However, this task operator will only call the web API, but to get the actual response, we have to implement an additional action that will hold the result in a TaskResult:

```swift
struct ProductListDomain {
    // State and more ...
    
    enum Action: Equatable {
        case fetchProducts
        case fetchProductsResponse(TaskResult<[Product]>)
   }
   
   struct Environment {
        var fetchProducts: () async throws -> [Product]
        var uuid: () -> UUID
    }
    
    static let reducer = Reducer<
        State, Action, Environment
    >.combine(
        // Other child reducers...
        .init { state, action, environment in
            switch action {
            case .fetchProducts:
                return .task {
                    // Just making the call 
                    await .fetchProductsResponse(
                        TaskResult { try await environment.fetchProducts() }
                    )
                }
            case .fetchProductsResponse(.success(let products)):
                // Getting the success response
                state.productListState = IdentifiedArrayOf(
                    uniqueElements: products.map {
                        ProductDomain.State(
                            id: environment.uuid(),
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
    )
}
```

For information about network requests in TCA, check out this [video](https://youtu.be/sid-zfggYhQ?list=PLHWvYoDHvsOVo4tklgLW1g7gy4Kmk4kjw&t=144) explaining async requests, and this other [video](https://youtu.be/j2qymM6i9n4) configuring a real web API call.

## Testing

TBD

## Other topics

### SwiftUI's Binding

TBD

If you want to lean more about Binding with TCA and SwiftUI, take a look to this [video](https://youtu.be/Ilr8AsoggIY).

### Optional States

TBD

If you want to learn more about optional states, check out this [video](https://youtu.be/AV0laQw2OjM).

### Private Actions

TBD

For more about private actions, check out this [video](https://youtu.be/7BkZX_7z-jw).

### Alert Views

TBD

This [video](https://youtu.be/U3EMduy-DhE) explains more about alert Views in TCA.

### Making a Root Domain

TBD

### More coming ...
