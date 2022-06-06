//
//  Amiibo.swift
//  AmiiboTCA
//
//  Created by Pedro Rojas on 05/06/22.
//

import Foundation

struct Amiibo: Equatable, Identifiable {
    let id: String = UUID().uuidString
    let name: String
    let imageName: String
    let franchise: Franchise
}

enum Franchise: String {
    case marioBros = "Mario Bros."
    case zelda = "The Legend of Zelda"
    case metalGear = "Metal Gear Solid"
    case pokemon = "Pokemon"
}
