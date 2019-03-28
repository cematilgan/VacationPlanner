//
//  AddNoteViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-11.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController {

    @IBOutlet weak var addNoteField: UITextView!
        {
        didSet{
            addNoteField.delegate = self
        }
    }
    
    var editableText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeywordWhenTappedElsewhere()
        if editableText != nil {
            addNoteField.text = editableText
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        if (presentingViewController as? AddPlaceViewController) != nil {
            performSegue(withIdentifier: Constants.Segues.returnToAddPlaceVCFromAddNoteVC, sender: self)
        } else if (presentingViewController as? PlaceDetailsViewController) != nil {
            performSegue(withIdentifier: Constants.Segues.returnToPlaceDetailsVcForNoteText, sender: self)
        }
    }
}

extension AddNoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if addNoteField.text == "Add notes" {
            addNoteField.text = ""
        }
    }
}
