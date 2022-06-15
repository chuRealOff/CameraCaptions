//
//  Photo.swift
//   Projects 10-12
//
//  Created by CHURILOV DMITRIY on 09.06.2022.
//

import UIKit

class Photo: NSObject, Codable {

    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
