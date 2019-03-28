//
//  GmsConstants.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-22.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

struct GmsConstants{
    
    enum gmsPlaceFields{
        static let fields: GMSPlaceField = GMSPlaceField(
            rawValue: UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.formattedAddress.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue) |
                UInt(GMSPlaceField.coordinate.rawValue) |
                UInt(GMSPlaceField.rating.rawValue) |
                UInt(GMSPlaceField.openingHours.rawValue) |
                UInt(GMSPlaceField.userRatingsTotal.rawValue) |
                UInt(GMSPlaceField.priceLevel.rawValue) |
                UInt(GMSPlaceField.types.rawValue) |
                UInt(GMSPlaceField.website.rawValue)
            )!
    }
    
}
