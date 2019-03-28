//
//  Constants.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-05.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

struct Constants {
    // Segues
    enum Segues {
        static let toIntroduction = "toIntroductionVC"
        static let toMainMapVC = "backToMainMapVC"
        static let returnToLocationListVC = "exitToLocationListVC"
        static let returnToMainMapVCWithLocation = "exitToMainMapVCWithSelectedLocation"
        static let toAddPlaceVC = "toAddPlaceVC"
        static let toAddLabelVC = "toAddLabelVC"
        static let toAddNoteVC = "toAddNoteVC"
        static let returnToAddPlaceVCFromAddNoteVC = "returnToAddPlaceVC"
        static let toLocationListVC = "toLocationsListVC"
        static let returnToMainMapVCFromAddPlaceVC = "returnToMainMapVC"
        static let toPlaceDetailsVC = "toPlaceDetailsVC"
        static let toLocationPermissionVC = "toLocationPermissionVC"
        static let toAddNoteVCForEditingNoteText = "toAddNoteVCForEditingNoteText"
        static let returnToPlaceDetailsVcForNoteText = "returnToPlaceDetailsVcForNoteText"
        static let toPoiPopOver = "toPoiPopOver"
        static let showAddPlaceVC = "showAddPlaceVC"
        static let toPoiPopOverVC = "toPoiPopOver"
    }
    // URL Constants
    enum Urls {
        static let googleBaseUrl = "https://maps.googleapis.com/maps/api/place/"
        static let googlePlaceSearchUrl = "\(googleBaseUrl)textsearch/"
        static let foursquareBaseUrl = "https://api.foursquare.com/v2/"
        static let foursquareVersion = "20180323"
        static let foursquareVenues = "\(foursquareBaseUrl)venues/"
        static let googleMaps = "https://www.google.com/maps/@"
    }

    enum Category {
        static let categories = ["Cafe & Bar","Food","Culture","Shopping"]
    }

    enum WeekDays {
        static let daysOfTheWeek = [1: "Sunday", 2: "Monday", 3: "Tuesday", 4: "Wednesday", 5: "Thursday", 6: "Friday", 7: "Saturday"]
    }
    
    enum CategoryColor {
        static let colors = ["Cafe & Bar": #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1),"Food": #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),"Culture": #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),"Shopping": #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), "Select a Category": #colorLiteral(red: 1, green: 0.3098039216, blue: 0.4274509804, alpha: 1)]
    }
    
    enum Locations {
        static let defaultLocation = CLLocation(latitude: 43.1431698, longitude: 24.5283861)
    }
    
    enum FontSizes {
        static let addPlaceScreenRatingSize = 24.0
        static let addPlaceScreenTextSize = 16.0
        static let detailsScreenRatingSize = 18.0
        static let detailsScreenTextSize = 13.0
    }
    
    enum UserDefaultsKeys {
        static let isFirstLaunch = "isFirstLaunch"
        static let didLaunchForTheFirstTime = "didLaunchForTheFirstTime"
    }
}

enum Strings {
    enum Notes {
        static let noteLabelNote = "Add notes"
    }
    
    enum Hint {
        static let hintTitle = "Hint"
        static let hintBodyText = "Tap the search icon for searching and adding new places to your map"
    }
}
