//
//  AddLabelView.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-06.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class AddLabelView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = 10.0
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.shadowRadius = 8.0
    }
}
