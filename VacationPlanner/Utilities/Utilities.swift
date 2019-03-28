//
//  Utilities.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-14.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class Utilities{
    
    private init() {
    }
    
    static func getOpeningHours(workingDays: [String]) -> String {
        var openingHours = ""
        
        let currentDay: Int = {
            let date = Date()
            let calendar = Calendar(identifier: .gregorian)
            let today = calendar.component(.weekday, from: date)
            return today
        }()
        
        let dayOfTheWeek = Constants.WeekDays.daysOfTheWeek[currentDay]!
        
        for day in workingDays {
            if day.contains(dayOfTheWeek){
                openingHours = day
            }
        }
        return openingHours
    }
    
    static func getAttributedString(for ratingText: String, with ratingSize: Double, textSize: Double) -> NSMutableAttributedString {
        let ratingAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor : UIColor(red: 1, green: 0.6705882353, blue: 0, alpha: 1),
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: CGFloat(ratingSize))
        ]
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor : UIColor.lightGray,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(textSize))
        ]
        // The range of the number of user ratings part of the text
        let textLength: Int = ratingText.count - 4
        let range = NSRange(location: 4, length: textLength)
        let attributedString = NSMutableAttributedString(string: ratingText, attributes: ratingAttributes)
        attributedString.addAttributes(textAttributes, range: range)
        
        return attributedString
    }
    
    static func editStringForPlaceTypes(text: String) -> String{
        let newString = text.replacingOccurrences(of: "_", with: " ")
        return newString.firstUppercased
    }
}

extension StringProtocol {
    var firstUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }
}
