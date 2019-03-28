//
//  GradientView.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-04.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

@IBDesignable
class GradientRoundedButton: UIButton {
    
    @IBInspectable var fromColor: UIColor = #colorLiteral(red: 0.3098039216, green: 0.3803921569, blue: 1, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var toColor: UIColor = #colorLiteral(red: 0.3098039216, green: 0.6901960784, blue: 1, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 3.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        setNeedsDisplay()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = cornerRadius
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
