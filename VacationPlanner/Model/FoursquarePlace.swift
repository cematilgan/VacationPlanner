//
//  FoursquarePlace.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-05.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import Foundation

struct FoursquarePlace: Codable {
    
    var id: String
    var name: String
    var foursquarePlaceRating: Double?
    var numberOfTotalRatingEntries: Int?
    var website: String?
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
}
