//
//  UIViewControllerExtensions.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-14.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

extension UIViewController{
    func hideKeywordWhenTappedElsewhere(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard(_ recognizer: UITapGestureRecognizer){
        if recognizer.state == .ended {
            view.endEditing(true)
        }
    }
}
