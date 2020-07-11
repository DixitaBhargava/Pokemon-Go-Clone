//
//  PokeAnnotation.swift
//  Pokemon Go Clone
//
//  Created by Dixita Bhargava on 11/07/20.
//  Copyright © 2020 Dixita Bhargava. All rights reserved.
//

import UIKit
import MapKit

class PokeAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pokemon : Pokemon
    
   init(coord: CLLocationCoordinate2D, pokemon: Pokemon) {
        self.coordinate = coord
        self.pokemon = pokemon
    }

}
