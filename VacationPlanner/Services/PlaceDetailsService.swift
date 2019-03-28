//
//  PlaceDetailsService.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-08.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
import GooglePlaces


class PlaceDetailsService{
    
    static let instance = PlaceDetailsService()
    
    private var placesClient = GMSPlacesClient()
    
    func getFoursquarePlace(_ coordinate: GMSPlace, completion: @escaping (_ success: Bool, _ id: String?)->()){
        
        let urlParameters = [
            "ll": "\(coordinate.coordinate.latitude),\(coordinate.coordinate.longitude)",
            "client_id": APIKeys.foursquareClientId,
            "client_secret": APIKeys.foursquareClientSecret,
            "v": Constants.Urls.foursquareVersion,
            "intent": "match",
            "name": coordinate.name!
        ]
        
        Alamofire.request("\(Constants.Urls.foursquareVenues)search", method: .get, parameters: urlParameters).responseJSON { (response) in
            if let status = response.response?.statusCode {
                switch (status){
                case 200..<300:
                    guard let data = response.value else { return }
                    let json = JSON(data)
                    let placeId = json["response"]["venues"][0]["id"].stringValue
                    
                    if placeId == "" {
                        completion(true, nil)
                    }else {
                        completion(true, placeId)
                    }
                default:
                    completion(false, nil)
                    debugPrint(response.result.error as Any)
                }
            }
        }
        
    }
    
    func getFoursquarePlaceDetails(_ coordinate: GMSPlace, completion: @escaping (_ success: Bool, _ responseObject: FoursquarePlace? )->()){
        
        let urlParameters = [
            "client_id": APIKeys.foursquareClientId,
            "client_secret": APIKeys.foursquareClientSecret,
            "v": Constants.Urls.foursquareVersion,
            ]
        
        getFoursquarePlace(coordinate) { (success, id) in
            guard success == true else {return}
            if id == nil {
                completion(false, nil)
            } else {
                Alamofire.request("\(Constants.Urls.foursquareVenues)\(id!)", method: .get, parameters: urlParameters).responseJSON(completionHandler: { (response) in
                    if let status = response.response?.statusCode{
                        switch (status){
                        case 200..<300:
                            guard let data = response.value else { return }
                            let json = JSON(data)
                            let placeId = json["response"]["venue"]["id"].stringValue
                            let placeName = json["response"]["venue"]["name"].stringValue
                            let placeRating = json["response"]["venue"]["rating"].doubleValue
                            let numberOfRatings = json["response"]["venue"]["ratingSignals"].intValue
                            let website = json["response"]["venue"]["canonicalUrl"].stringValue
                            let fourSquareObject = FoursquarePlace.init(id: placeId, name: placeName, foursquarePlaceRating: placeRating, numberOfTotalRatingEntries: numberOfRatings, website: website)
                            completion(true,fourSquareObject)
                        default:
                            debugPrint(response.result.error as Any)
                            completion(false, nil)
                            break
                        }
                    }
                })
            }
        }
    }
    
    func getGooglePlaceDetails(for item: String, completion: @escaping (_ success: Bool, _ place: GMSPlace? ) -> ()){
        placesClient.fetchPlace(fromPlaceID: item, placeFields: GmsConstants.gmsPlaceFields.fields, sessionToken: nil) { (gmsPlace, error) in
            if error != nil {
                print("An error occurred: \(error!.localizedDescription)")
                completion(false, nil)
                return
            } else {
                if let place = gmsPlace {
                    completion(true, place)
                } else {
                    completion(true, nil)
                }
            }
        }
    }
    
    func updatePlaceDetails(){
        for location in LocationService.instance.locations{
            for place in location.places{
                placesClient.fetchPlace(fromPlaceID: place.googlePlaceDetails.id, placeFields: GmsConstants.gmsPlaceFields.fields, sessionToken: nil) { (gmsPlace, error) in
                    if let error = error {
                        print("An error occurred: \(error.localizedDescription)")
                        return
                    }
                    guard let gmsPlace = gmsPlace else { return}
                    let address = gmsPlace.formattedAddress
                    let rating = gmsPlace.rating
                    let noOfRatings = gmsPlace.userRatingsTotal
                    let workingHours = gmsPlace.openingHours?.weekdayText
                    let website = gmsPlace.website
                    place.googlePlaceDetails.updateValues(address: address ?? "", rating: rating, numberOfRatings: noOfRatings, workingDays: workingHours, website: website)
                }
            }
        }
    }
}
