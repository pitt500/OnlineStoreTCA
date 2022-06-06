//
//  SystemEnvironment.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 05/06/22.
//

import ComposableArchitecture

//@dynamicMemberLookup
//struct SystemEnvironment<Environment> {
//    var environment: Environment
//    
//    subscript<Dependency>(
//        dynamicMember keypath: WritableKeyPath<Environment, Dependency>
//    ) -> Dependency {
//        get { self.environment[keyPath: keypath] }
//        set { self.environment[keyPath: keypath] = newValue }
//    }
//    
//    var mainQueue: () -> AnySchedulerOf<DispatchQueue>
//    var decoder: () -> JSONDecoder
//    
//    private static func decoder() -> JSONDecoder {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    }
//    
//    static func live(environment: Environment) -> Self {
//        Self(environment: environment, mainQueue: { .main }, decoder: decoder)
//    }
//    
//    static func dev(environment: Environment) -> Self {
//        Self(environment: environment, mainQueue: { .main }, decoder: decoder)
//    }
//}
