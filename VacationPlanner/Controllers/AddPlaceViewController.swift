//
//  AddPlaceViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-08.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class AddPlaceViewController: UIViewController {
   
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var googleRating: UILabel!
    @IBOutlet weak var foursquareRating: UILabel!
    @IBOutlet weak var openingHours: UILabel!
    @IBOutlet weak var categorySelector: UITextField!
    @IBOutlet weak var googleRatingSubtitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var openingHoursTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addNoteField: UITextView!
    @IBOutlet weak var miniMap: GMSMapView! {
        didSet{
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "MiniMapStyle", withExtension: "json") {
                    miniMap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
    }
    @IBOutlet weak var foursquareInfoStackView: UIStackView! {
        didSet {
            foursquareInfoStackView.isHidden = true
        }
    }
    @IBOutlet weak var poweredByFoursquareImage: UIImageView! {
        didSet{
            poweredByFoursquareImage.isHidden = true
        }
    }
    var place: GMSPlace?
    var marker = GMSMarker()
    var pickerView = UIPickerView()
    var foursquareObject: FoursquarePlace? // Is fetched while retrieving the foursquare details and added to vacationPlannerPlace when exiting the screen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        setup()
        hideKeywordWhenTappedElsewhere()
        setupPickerView()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNoteButtonTapped(_ sender: UIButton) {
        pickerView.resignFirstResponder()
        performSegue(withIdentifier: Constants.Segues.toAddNoteVC, sender: self)
    }
    
    @IBAction func addToMapButtonTapped(_ sender: UIButton) {
        guard let place = place else { return }
        
        let placeObject = GooglePlace(with: place)
        
        // Clear the UITextField manual placeholder text if it is added with it
        if addNoteField.text == Strings.Notes.noteLabelNote {
            addNoteField.text = ""
        }
        let categoryText = categorySelector.text == "Select a Category" ? "" : categorySelector.text
        let vacationPlannerPlace = VacationPlannerPlace(
            notes: addNoteField.text,
            category: categoryText,
            isVisited: false,
            googlePlaceDetails: placeObject,
            foursquarePlaceDetails: foursquareObject
        )
        
        if LocationService.instance.updateLocation(with: vacationPlannerPlace) {
            performSegue(withIdentifier: Constants.Segues.returnToMainMapVCFromAddPlaceVC, sender: self)
        } else {
            let alert = UIAlertController(title: "The place already added to Map",
                                          message: "Please select another place to pin",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pickerView.bounds.size = CGSize(width: pickerView.bounds.size.width, height: pickerView.bounds.height * 0.7)
        categorySelector.inputView = pickerView
    }
    
    func setup(){
        guard let place = place else { return }
        
        setMiniMap()
        placeName.text = place.name
        setRatingsTexts()
        
        if let workingHours = place.openingHours?.weekdayText{
            openingHours.text = Utilities.getOpeningHours(workingDays: workingHours)
        } else {
            openingHours.isHidden = true
            openingHoursTitleLabel.isHidden = true
        }
        
        addressLabel.text = place.formattedAddress
        addNoteField.textColor = #colorLiteral(red: 0.3826446533, green: 0.4860807061, blue: 1, alpha: 1)
    }
    
    func setMiniMap(){
        guard let place = place else { return }
        let camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 16.0)
        marker.position = place.coordinate
        marker.icon = UIImage(named: "mapPin")
        marker.map = miniMap
        miniMap.camera = camera
    }
    
    func setRatingsTexts() {
        guard let place = place else { return }
        // Edit the google ratings display with attributes strings
        let googleRatingsText = "\(place.rating) (\(place.userRatingsTotal))"
        googleRating.attributedText = Utilities.getAttributedString(for: googleRatingsText, with: Constants.FontSizes.addPlaceScreenRatingSize, textSize: Constants.FontSizes.addPlaceScreenTextSize)
        
        // Get the foursquare ratings and display on screen
        PlaceDetailsService.instance.getFoursquarePlaceDetails(place) { (success, fourSquareObject) in
            self.stopActivityIndicator()
            guard success == true,
                let fourSquareObject = fourSquareObject,
                let rating = fourSquareObject.foursquarePlaceRating,
                let totalRatings = fourSquareObject.numberOfTotalRatingEntries else { return }
            
            // If foursquare ratings successfully fetched start creating the attributes string to display the ratings
            let foursquareRatingsText = "\(rating) (\(totalRatings))"
            self.foursquareRating.attributedText = Utilities.getAttributedString(for: foursquareRatingsText, with: Constants.FontSizes.addPlaceScreenRatingSize, textSize: Constants.FontSizes.addPlaceScreenTextSize)
            self.foursquareObject = fourSquareObject
            self.foursquareInfoStackView.isHidden = false
            self.poweredByFoursquareImage.isHidden = false
        }
    }
    
    func stopActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: Segues
    @IBAction func exitFromAddNoteVC(by segue: UIStoryboardSegue) {
        let unboundFromVC = segue.source as? AddNoteViewController
        addNoteField.text = unboundFromVC?.addNoteField.text
    }
    
    // To send the existing text in the label field incase user wants to edit
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if let targetVC = segue.destination as? AddNoteViewController {
            targetVC.editableText = addNoteField.text
        }
    }
}

extension AddPlaceViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.Category.categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categorySelector.text = Constants.Category.categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.Category.categories[row]
    }
}

private extension GooglePlace {
    init(with place: GMSPlace) {
        id = place.placeID ?? ""
        name = place.name ?? ""
        address = place.formattedAddress ?? ""
        latitude = place.coordinate.latitude
        longitude = place.coordinate.longitude
        rating = place.rating
        totalNumberOfRatingEntries = place.userRatingsTotal
        workingDays = place.openingHours?.weekdayText
        website = place.website
    }
}
