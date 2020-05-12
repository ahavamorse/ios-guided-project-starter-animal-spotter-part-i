//
//  Animal.swift
//  AnimalSpotter
//
//  Created by Ahava on 5/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct Animal: Codable  {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let timeSeen: Date
    let description: String
    let imageURL: String
}
