//
//  AmiiboEffect.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 05/06/22.
//

import Foundation
import ComposableArchitecture

func mockAmiiboListEffect(decoder: JSONDecoder) -> Effect<[Amiibo], APIError> {
    let amiiboList = [
        Amiibo(
            name: "Koopa",
            imageName: "koopa",
            franchise: .marioBros
        ),
        Amiibo(
            name: "Link",
            imageName: "link",
            franchise: .zelda
        ),
        Amiibo(
            name: "Link",
            imageName: "linkOot",
            franchise: .zelda
        ),
        Amiibo(
            name: "Samus",
            imageName: "samus",
            franchise: .metroid
        ),
        Amiibo(
            name: "Snake",
            imageName: "snake",
            franchise: .metalGear
        ),
        Amiibo(
            name: "Squirtle",
            imageName: "squirtle",
            franchise: .pokemon
        ),
        Amiibo(
            name: "Waluigi",
            imageName: "waluigi",
            franchise: .marioBros
        ),
        Amiibo(
            name: "Yoshi",
            imageName: "yoshi",
            franchise: .marioBros
        ),
        Amiibo(
            name: "Link",
            imageName: "young_link",
            franchise: .zelda
        ),
    ]
    
    return Effect(value: amiiboList)
}
