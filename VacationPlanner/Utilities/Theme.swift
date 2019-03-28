//
//  Theme.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-04-14.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class Theme {
    
    static func configureDefault() {
        let tintColor = #colorLiteral(red: 1, green: 0.3098039216, blue: 0.4274509804, alpha: 1)
        UINavigationBar.appearance().tintColor = tintColor
        UISearchBar.appearance().tintColor = tintColor
    }
}
