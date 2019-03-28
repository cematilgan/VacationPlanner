//
//  SearchButton.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-19.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class SearchButton: UIButton {

    override func awakeFromNib() {
        setupView()
    }
   
    func setupView(){
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowRadius = 2.0
    }
}
