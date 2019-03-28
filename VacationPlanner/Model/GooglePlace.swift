//
//  GooglePlace.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-05.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import Foundation
import CoreLocation

struct GooglePlace: Codable {
    
    var id: String
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var rating: Float?
    var totalNumberOfRatingEntries: UInt?
    var workingDays: [String]?
    var website: URL?
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    mutating func updateValues(address: String, rating: Float?, numberOfRatings: UInt?, workingDays: [String]?, website: URL?){
        self.address = address
        self.rating = rating
        self.totalNumberOfRatingEntries = numberOfRatings
        self.workingDays = workingDays
        self.website = website
    }
}


