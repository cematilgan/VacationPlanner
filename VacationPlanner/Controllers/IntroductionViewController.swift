//
//  IntroductionViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-04.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollViewInitialContentOffSet = scrollView.contentOffset
        }
    }
    @IBOutlet weak var locationNameField: UITextField! {
        didSet {
            locationNameField.delegate = self
        }
    }

    // Variables
//    var keyboardHeight: CGFloat?
    var scrollViewInitialContentOffSet = CGPoint.zero
    
    override func viewWillAppear(_ animated: Bool) {
        registerToNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationNameField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeywordWhenTappedElsewhere()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterToNotifications()
    }
    
    func registerToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: view.window)
    }
    
    func deregisterToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func continueButtonPressed(_ sender: GradientRoundedButton) {
        guard
            let text = locationNameField.text,
            text.count > 0 else {
                let alert = UIAlertController(
                    title: "Location name cannot be empty!",
                    message: "Please enter a location name to start planning!",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true)
                return
        }
        LocationService.instance.addLocation(with: text)
        LocationService.instance.selectLocation()
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isFirstLaunch)
        UserDefaults.standard.synchronize()
        performSegue(withIdentifier: Constants.Segues.toMainMapVC, sender: self)
    }
    
    @objc func keyboardWillDisappear(_ notification: NSNotification){
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        // Check if the view has been adjusted because of the keyboard appearence and if so do the necessary clean up
        if scrollViewInitialContentOffSet != scrollView.contentOffset {
            UIView.animate(withDuration: 0.3) {
                self.contentViewHeightConstraint.constant -= keyboardSize.height
                self.scrollView.contentOffset = self.scrollViewInitialContentOffSet
            }
        }
    }
    
    @objc func keyboardWillAppear(_ notification: NSNotification){
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        // Get the keyboard height and calculate the text fields distance from the bottom
        
        let convertedFrameForWindow = self.locationNameField.convert(locationNameField.frame, to: self.view)
        let distanceOfTheLabelFromTheBottom = self.scrollView.frame.size.height - (convertedFrameForWindow.origin.y) - (locationNameField.frame.size.height)
        let intersectSpace = keyboardSize.height - distanceOfTheLabelFromTheBottom
        
        // Check if keyboard is covering the text field
        if intersectSpace > 0 {
            
            // Move the content view up so that it becomes scrollable
            UIView.animate(withDuration: 0.3, animations: {
                self.contentViewHeightConstraint.constant += keyboardSize.height
            })
            
            // Scroll up to show the text field
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: (self.scrollView.contentOffset.y + intersectSpace))
            }
        } else {
            scrollView.isScrollEnabled = false
        }
    }
}

extension IntroductionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

