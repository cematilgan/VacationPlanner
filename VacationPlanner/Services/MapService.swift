//
//  MapService.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-06.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON


class MapService {
    
    static let instance = MapService()
    
    func getLocation(name: String, completion: @escaping (_ success: Bool, _ locationInfo: CLLocationCoordinate2D?) -> ()) {
        
        let urlParameters = [
            "query":name,
            "key": APIKeys.google,
            ]
        
        Alamofire.request("\(Constants.Urls.googlePlaceSearchUrl)json?", method: .get, parameters: urlParameters).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.value else { return }
                let json = JSON(data)
                let lat = json["results"][0]["geometry"]["location"]["lat"].doubleValue
                let lon = json["results"][0]["geometry"]["location"]["lng"].doubleValue
                
                if lat == 0 && lon == 0 {
                    completion(true, nil)
                } else {
                    let latitude = CLLocationDegrees(exactly: lat)
                    let longitude = CLLocationDegrees(exactly: lon)
                    let locationCoordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                    completion(true, locationCoordinate)
                }
            }else {
                completion(false, nil)
                debugPrint(response.result.error as Any)
            }
        }
    }
}

