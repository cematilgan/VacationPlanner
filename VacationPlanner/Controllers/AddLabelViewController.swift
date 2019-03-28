//
//  AddLabelViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-05.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class AddLabelViewController: UIViewController {
    
    @IBOutlet weak var labelText: UITextField! {
        didSet {
            labelText.delegate = self
        }
    }
    
    var editableText: String? // If AddLabelVC if presented by AddPlaceVC the labelText field's previous data should be shown to the user in order to make editing possible
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeywordWhenTappedElsewhere()
        if editableText != nil { // Nil means the presentingVC is LocationListVC "some" means the presendtingVC is AddPlaceVC
            labelText.text = editableText
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        // If the presentingVC is AddPlaceVC the text can be left empty otherwise the text cannot be empty string
        guard let entry = labelText.text, entry.count > 0 else {
            let alert = UIAlertController(title: "The field value cannot be empty!",
                                          message: "Please enter a location name to start planning!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        LocationService.instance.addLocation(with: entry)
        performSegue(withIdentifier: Constants.Segues.returnToLocationListVC, sender: self)
    }
}

extension AddLabelViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
