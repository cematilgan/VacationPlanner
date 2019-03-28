//
//  VacationPlannerLocation.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-05.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import Foundation

class VacationPlannerLocation: Hashable, Equatable, Codable {
    
    var name: String
    var places: [VacationPlannerPlace]
    private var id: Int
    private static var idNumber = 0
    var hashValue: Int {
        return id
    }
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func generateId()->Int{
        idNumber += 1
        return idNumber
    }
    
    static func == (lhs: VacationPlannerLocation, rhs: VacationPlannerLocation) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(name: String, places: [VacationPlannerPlace]){
        self.name = name
        self.places = places
        self.id = VacationPlannerLocation.generateId()
    }
    
    init(name: String) {
        self.name = name
        self.places = []
        self.id = VacationPlannerLocation.generateId()
    }
    
    func addPlaces(_ places: [VacationPlannerPlace])
    {
        self.places += places
    }
    
    func removePlace(place: VacationPlannerPlace, completion: @escaping (_ success: Bool)->()){
        for index in places.indices{
            if places[index].googlePlaceDetails.id == place.googlePlaceDetails.id{
                places.remove(at: index)
                completion(true)
                break
            }
        }
    }
    
}
