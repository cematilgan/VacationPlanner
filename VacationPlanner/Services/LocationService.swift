//
//  LocationService.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-05.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import Foundation

enum LocationServiceError: Error {
    case indexOutOfBounds
}

extension NSNotification.Name {
        static let SelectedLocationChanged = NSNotification.Name("SelectedLocationChanged")
        static let SelectedPlaceChanged = NSNotification.Name("SelectedPlaceChanged")
        static let SelectedPlaceDeleted = NSNotification.Name("SelectedPlaceDeleted")
}

class LocationService {
    
    static let instance = LocationService()
    
    private(set) var selectedLocationIndex: Int?
    
    private(set) var selectedPlace: VacationPlannerPlace? {
        didSet {
            notifyNewPlaceSelected()
        }
    }
    
    private(set) var selectedLocation: String? {
        didSet {
            notifyNewLocationSelected()
        }
    }
    
    private(set) var locations = [VacationPlannerLocation]()
    
    func addLocation(with name: String) {
        locations.append(VacationPlannerLocation(name: name))
        save()
    }
    
    func selectLocation(index: Int = 0) {
        selectedLocationIndex = index
        selectedLocation = locations[selectedLocationIndex!].name
    }
    
    func selectPlace(place: VacationPlannerPlace) {
        selectedPlace = place
    }
    
    func currentLocationIndex() throws -> Int {
        guard let index = selectedLocationIndex else { throw LocationServiceError.indexOutOfBounds }
        return index
    }
    
    func currentLocation() -> String {
        guard let location = selectedLocation else { return ""}
        return location
    }
    
    func notifyNewLocationSelected() {
        NotificationCenter.default.post(name: .SelectedLocationChanged, object: self, userInfo: nil)
    }
    
    func notifyNewPlaceSelected() {
        NotificationCenter.default.post(name: .SelectedPlaceChanged, object: self, userInfo: nil)
    }
    
    func notifySelectedPlaceDeleted() {
        NotificationCenter.default.post(name: .SelectedPlaceDeleted, object: self, userInfo: nil)
    }
    
    func updateLocation(with place: VacationPlannerPlace) -> Bool {
        guard let index = selectedLocationIndex else { return false }
        
        for savedPlace in locations[index].places{
            if savedPlace.googlePlaceDetails.name == place.googlePlaceDetails.name,
                savedPlace.googlePlaceDetails.latitude == place.googlePlaceDetails.latitude,
                savedPlace.googlePlaceDetails.longitude == place.googlePlaceDetails.longitude{
                return false
            }
        }
        locations[index].addPlaces([place])
        save()
        return true
    }
    
    func retrievePlaces() -> [VacationPlannerPlace] {
        guard let index = selectedLocationIndex else { return [] }
        return locations[index].places
    }
    
    func updatePlace(place: VacationPlannerPlace, with note: String, category: String, visitedInfo: Bool, at: Int) {
        place.notes = note
        place.category = category
        place.updateIsVisited(visitedInfo)
        save()
    }
    
    func deletePlace(place: VacationPlannerPlace, at: Int) {
        locations[at].removePlace(place: place) { (success) in
            if success{
                self.save()
                self.notifySelectedPlaceDeleted()
            }
        }
    }
    
    func deleteLocation(at index: Int) {
        let deletedLocation = locations.remove(at: index)
        for savedPlace in deletedLocation.places {
            savedPlace.googlePlaceDetails.id = ""
            savedPlace.googlePlaceDetails.name = ""
        }
        deletedLocation.places.removeAll()
        save()
    }
    
    func save() {
        guard let dirUrl = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true) else { return }
        
        let fileUrl = dirUrl.appendingPathComponent("MyLocations.json")
        let jsonEncoder = JSONEncoder()
        do {
            let data = try jsonEncoder.encode(locations)
            try? data.write(to: fileUrl, options: [])
        } catch {
            print(error)
        }
    }
    
    func load() {
        guard let dirUrl = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true) else { return }
        
        let fileUrl = dirUrl.appendingPathComponent("MyLocations.json")
        let jsonDecoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: fileUrl, options: [])
            let locationsArray = try jsonDecoder.decode([VacationPlannerLocation].self, from: data)
            locations = locationsArray
        }catch {
            print(error)
        }
        PlaceDetailsService.instance.updatePlaceDetails()
    }
}
