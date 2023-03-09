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

* **Combine**: TBD.
* **Pullback**: TBD.

If you want to learn more about these operators, check out this [video](https://youtu.be/Zf2pFEa3uew).

### Collection of states

If you want to learn more about ForEachStore, check out this other [video](https://youtu.be/sid-zfggYhQ)

## Environment

The environment is a structure that contains all the dependencies needed by the application to perform its tasks. It was part of the TCA foundation before the introduction of [ReducerProtocol](https://www.pointfree.co/blog/posts/81-announcing-the-reducer-protocol) and [Dependencies Framework](https://github.com/pointfreeco/swift-dependencies).


## Side Effects

A side effect is an observable change that occurs as a result of running a function or method. This can include things like modifying state outside of the function, performing I/O operations like reading or writing to a file, or making network requests. 
TCA helps to encapsulate those side effects through Effects objects.

If you want to learn more about side effects, check out this [video](https://youtu.be/t3HHam3GYkU)

## Testing

TBD

### More coming ...
