//
//  RoundedView.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-12.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView(){
        layer.cornerRadius = 20.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
        layer.shadowRadius = 8.0
    }
}
