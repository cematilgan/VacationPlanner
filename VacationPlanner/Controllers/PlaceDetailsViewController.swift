//
//  PlaceDetailsViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-12.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class PlaceDetailsViewController: UIViewController {
 
    @IBOutlet weak var containerView: RoundedView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeCategory: UITextField!
    @IBOutlet weak var placeGoogleRating: UILabel!
    @IBOutlet weak var placeFoursquareRating: UILabel!
    @IBOutlet weak var poweredByFoursquareButton: UIButton!
    @IBOutlet weak var openingHoursLabel: UILabel!
    @IBOutlet weak var notesLabel: UITextView! 
    @IBOutlet weak var openingHoursTitleLabel: UILabel!
    @IBOutlet weak var isVisitedSwitch: UISwitch!
    @IBOutlet weak var foursquareRatingsSubtitle: UILabel!
    @IBOutlet weak var notesTitle: UILabel!
    
    var close: (() -> Void)? = nil
    let pickerView = UIPickerView()
    var pinnedPlace: (place: VacationPlannerPlace, locationIndex: Int)? // Place details about the selected pin fetched in getSelectedPlace() from API
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeywordWhenTappedElsewhere()
        addGestureRecognizers()
        getSelectedPlace()
        updateView()
        setupPickerView()
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        saveChangesToPlace()
        close?()
    }

    @IBAction func moreButtonTapped(_ sender: UIButton) {
        guard
            let place = pinnedPlace?.place,
            let index = pinnedPlace?.locationIndex else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Open in Google Maps", style: .default, handler: { (UIAlertAction) in
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                UIApplication.shared.open(URL(string:"comgooglemaps://?q=\(place.googlePlaceDetails.name)&center=\(place.googlePlaceDetails.latitude),\(place.googlePlaceDetails.longitude)")!, options: [:], completionHandler: nil)
            } else {
                let coordinate = place.googlePlaceDetails.coordinate
                UIApplication.shared.open(URL(string: "\(Constants.Urls.googleMaps)\(coordinate.latitude),\(coordinate.longitude),18z")!,
                                          options: [:],
                                          completionHandler: nil)
            }
        }))
        
        if let foursquareWebsite = place.foursquarePlaceDetails?.website {
            alert.addAction(UIAlertAction(title: "Open in Foursquare", style: .default, handler: { (UIAlertAction) in
                UIApplication.shared.open(URL(string: foursquareWebsite)!,
                                          options: [:],
                                          completionHandler: nil)
            }))
        }
        
        if let website = place.googlePlaceDetails.website {
            alert.addAction(UIAlertAction(title: "Open Website", style: .default, handler: { (UIAlertAction) in
                UIApplication.shared.open(website,
                                          options: [:],
                                          completionHandler: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Edit Notes", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: Constants.Segues.toAddNoteVCForEditingNoteText, sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Edit Category", style: .default, handler: { (UIAlertAction) in
            self.placeCategory.becomeFirstResponder()
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (UIAlertAction) in
            LocationService.instance.deletePlace(place: place, at: index)
            self.close?()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
  
    func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(recognizer:)))
        swipe.direction = .down
        backgroundView.addGestureRecognizer(tap)
        containerView.addGestureRecognizer(swipe)
    }
    
    private func getSelectedPlace() {
        guard
            let place = LocationService.instance.selectedPlace,
            let locationIndex = try? LocationService.instance.currentLocationIndex() else { return }
        pinnedPlace = (place, locationIndex)
    }
    
    func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pickerView.bounds.size = CGSize(width: pickerView.bounds.size.width, height: pickerView.bounds.height * 0.7)
        placeCategory.inputView = pickerView
        placeCategory.tintColor = UIColor.clear // For hiding caret
    }
    
    func updateView() {
        guard let pinPlaceObject = pinnedPlace?.place else { return }
        
        placeName.text = pinPlaceObject.googlePlaceDetails.name
        
        if let category = pinPlaceObject.category {
            placeCategory.text = category
            placeCategory.isHidden = category.contains("Select")
        } else {
            placeCategory.isHidden = true
        }
        
        if let workingHours = pinPlaceObject.googlePlaceDetails.workingDays {
            openingHoursLabel.text = Utilities.getOpeningHours(workingDays: workingHours)
        } else {
            openingHoursLabel.isHidden = true
            openingHoursTitleLabel.isHidden = true
        }
        
        setGoogleRatings()
        setFoursquareRatings()
        setNotesLabelText()
        isVisitedSwitch.setOn(pinPlaceObject.isVisited, animated: false)
    }
    
    func setNotesLabelText() {
        guard let place = pinnedPlace?.place else {  return }
        if place.notes == "" {
            notesLabel.text = Strings.Notes.noteLabelNote
            notesLabel.textColor = #colorLiteral(red: 0.3826446533, green: 0.4860807061, blue: 1, alpha: 1)
        } else {
            notesLabel.text = place.notes
        }
    }
    
    func setGoogleRatings() {
        guard
            let googleRating = pinnedPlace?.place.googlePlaceDetails.rating,
            let googleTotalRatings = pinnedPlace?.place.googlePlaceDetails.totalNumberOfRatingEntries else { return }
        let googleRatingsText = "\(googleRating) (\(googleTotalRatings))"
        placeGoogleRating.attributedText = Utilities.getAttributedString(for: googleRatingsText, with: Constants.FontSizes.detailsScreenRatingSize, textSize: Constants.FontSizes.detailsScreenTextSize)
    }
    
    func setFoursquareRatings() {
        guard
            let foursquarePlaceRating = pinnedPlace?.0.foursquarePlaceDetails?.foursquarePlaceRating,
            let foursquareTotalRatings = pinnedPlace?.0.foursquarePlaceDetails?.numberOfTotalRatingEntries else {
                placeFoursquareRating.isHidden = true
                foursquareRatingsSubtitle.isHidden = true
                return
        }
        let foursquareRatingsText = "\(foursquarePlaceRating) (\(foursquareTotalRatings))"
        placeFoursquareRating.attributedText = Utilities.getAttributedString(for: foursquareRatingsText, with: Constants.FontSizes.detailsScreenRatingSize, textSize: Constants.FontSizes.detailsScreenTextSize)
    }
    
    func saveChangesToPlace() {
        guard
            let place = pinnedPlace?.place,
            let index = pinnedPlace?.locationIndex,
            let categoryText = placeCategory.text else { return }
        LocationService.instance.updatePlace(place: place, with: notesLabel.text, category: categoryText, visitedInfo: isVisitedSwitch.isOn, at: index)
    }
    
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            saveChangesToPlace()
            close?()
        default:
            break
        }
    }
    
    @objc func handleSwipeGesture(recognizer: UISwipeGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            saveChangesToPlace()
            close?()
        default:
            break
        }
    }
    
    // MARK: Segues
    @IBAction func returnFromAddNoteVc(by segue: UIStoryboardSegue) {
        let unboundFromVC = segue.source as? AddNoteViewController
        notesLabel.text = unboundFromVC?.addNoteField.text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let targetVC = segue.destination as? AddNoteViewController {
            targetVC.editableText = notesLabel.text
        }
    }
}

extension PlaceDetailsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.Category.categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        placeCategory.text = Constants.Category.categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.Category.categories[row]
    }
}

