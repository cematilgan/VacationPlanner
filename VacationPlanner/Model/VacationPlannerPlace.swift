//
//  VacationPlannerPlace.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-05.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import Foundation

class VacationPlannerPlace: Codable, Equatable {
    
    var notes: String?
    var category: String?
    var isVisited = false
    var googlePlaceDetails: GooglePlace
    var foursquarePlaceDetails: FoursquarePlace?
    private(set) var id: Int
    private static var idNumber = 0
    
    static func generateId() -> Int {
        idNumber += 1
        return idNumber
    }
    
    static func == (lhs: VacationPlannerPlace, rhs: VacationPlannerPlace) -> Bool {
        return lhs.id == rhs.id
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    func updateIsVisited(_ visited: Bool){
        self.isVisited = visited
    }
    
    init(notes: String?, category: String?, isVisited: Bool, googlePlaceDetails: GooglePlace, foursquarePlaceDetails: FoursquarePlace?){
        self.notes = notes
        self.category = category
        self.isVisited = isVisited
        self.googlePlaceDetails = googlePlaceDetails
        self.foursquarePlaceDetails = foursquarePlaceDetails
        self.id = VacationPlannerPlace.generateId()
    }
    
}
