//
//  ViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-04.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

struct POIObject{
    var id: String
    var name: String
    var location: CLLocationCoordinate2D
}

class MainMapViewController: UIViewController {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var mainMap: GMSMapView! {
        didSet {
            mainMap.delegate = self
            mainMap.isMyLocationEnabled = true
            mainMap.settings.myLocationButton = true
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                    mainMap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
    }
    @IBOutlet weak var hintView: MessageView!
    @IBOutlet weak var hintTitle: UILabel!
    @IBOutlet weak var hintBody: UILabel!
    @IBOutlet weak var hintArrow: UIImageView!
    
    var pinnedPlacesOnTheMap = [GMSMarker:VacationPlannerPlace]() // Data structure to keep record of the pinned places on the map and to match them wth the corresponding gmsplaces
    var selectedPin: GMSMarker? // Var to keep track of the last tapped pin in order to edit the color if its marked as visited on PlaceDetailsVC
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.didLaunchForTheFirstTime) {
            hintView.isHidden = false
            hintTitle.text = Strings.Hint.hintTitle
            hintBody.text = Strings.Hint.hintBodyText
            let hintArrowOrigin = hintArrow.frame.origin
            let animationOrigin = CGPoint(x: hintArrowOrigin.x, y: hintArrowOrigin.y+5.0)
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat,.autoreverse], animations: {
                self.hintArrow.frame.origin = animationOrigin
            }, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launchCheck()
        registerToNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.didLaunchForTheFirstTime) {
            UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.didLaunchForTheFirstTime)
            UserDefaults.standard.synchronize()
        }
        hintView.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        hintView.isHidden = true
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func listButtonTapped(_ sender: UIBarButtonItem) {
        removePins()
        performSegue(withIdentifier: Constants.Segues.toLocationListVC, sender: self)
    }
    
    @IBAction func hintCloseButtonTapped(_ sender: UIButton) {
        hintView.isHidden = true
    }
    
    func registerToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapForLocation), name: .SelectedLocationChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedPlaceDidChange), name: .SelectedPlaceChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedPlaceDeleted), name: .SelectedPlaceDeleted, object: nil)
    }
    
    @objc func updateMapForLocation() {
        guard let location = LocationService.instance.selectedLocation else { return }
        navigationItem.title = location
        displayLocation(name: location)
    }
    
    @objc func selectedPlaceDidChange() {
        presentedViewController?.dismiss(animated: true, completion: {
            self.updateMapWithAddedPins()
            if let place = LocationService.instance.selectedPlace {
                let marker = self.getMarkerFor(place: place)
                self.adjustCameraForTheSelectedMarker(marker: marker)
                self.selectedPin = marker
                self.performSegue(withIdentifier: Constants.Segues.toPlaceDetailsVC, sender: self)
            }
        })
    }
    
    @objc func selectedPlaceDeleted() {
        guard let lastSelectedPin = selectedPin else { return }
        lastSelectedPin.map = nil
        updateMapWithAddedPins()
    }
    
    func launchCheck() {
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.didLaunchForTheFirstTime) {
            updateMapForLocation()
        } else if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.didLaunchForTheFirstTime) {
            performSegue(withIdentifier: Constants.Segues.toLocationListVC, sender: self)
        }
    }
    
    // Clean up function before moving to another screen
    func removePins() {
        for (key: marker, value: _) in pinnedPlacesOnTheMap {
            marker.map = nil
            pinnedPlacesOnTheMap[marker] = nil
        }
        pinnedPlacesOnTheMap = [:]
    }

    func displayLocation(name: String) {
        MapService.instance.getLocation(name: name) { success, coordinate  in
            guard success == true else { return }
            if let coordinate = coordinate {
                self.updateCamera(location: coordinate, with: 12.0, animated: false)
            } else {
                self.showCurrentLocation()
            }
        }
    }
    
    func showCurrentLocation() {
        guard let currentCoordinate = LocationManager.instance.currentLocation?.coordinate else {
            updateCamera(location: Constants.Locations.defaultLocation.coordinate, with: 1.6, animated: false)
            return
        }
        updateCamera(location: currentCoordinate, with: 12.0, animated: false)
    }
    
    private func marker(for place: VacationPlannerPlace) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = place.googlePlaceDetails.coordinate
        marker.map = self.mainMap
        let markerImage = UIImage(named: "mapPin")?.withRenderingMode(.alwaysTemplate)
        let markerImageView = UIImageView(image: markerImage)
        if place.isVisited {
            markerImageView.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            marker.iconView = markerImageView
        } else {
            let markerColor = Constants.CategoryColor.colors[place.category!]
            markerImageView.tintColor = markerColor
            marker.iconView = markerImageView
        }
        return marker
    }
    
    func updateMapWithAddedPins() {
        let pinnedPlaces = LocationService.instance.retrievePlaces()
        guard pinnedPlaces.count > 0 else { return }
        removePins()
        // Fetch the added places by their gms id to display on the map by adding them as pins
        for savedPlace in pinnedPlaces {
            let marker = self.marker(for: savedPlace)
            pinnedPlacesOnTheMap[marker] = savedPlace
        }
    }
    
    func updateCamera(location: CLLocationCoordinate2D, with zoom: Float?, animated: Bool){
        if animated {
            mainMap.animate(toLocation: location)
        } else {
            if let zoomLevel = zoom {
                let camera = GMSCameraPosition.camera(withTarget: location, zoom: zoomLevel)
                mainMap.camera = camera
            }
        }
    }
    
    func selectPlace(for marker: GMSMarker) {
        guard let selectedPlace = pinnedPlacesOnTheMap[marker] else { return }
        LocationService.instance.selectPlace(place: selectedPlace)
    }
    
    func getMarkerFor(place: VacationPlannerPlace) -> GMSMarker {
        var marker = GMSMarker()
        for pinnedPlace in pinnedPlacesOnTheMap {
            if pinnedPlace.value.googlePlaceDetails.id == place.googlePlaceDetails.id {
                marker = pinnedPlace.key
            }
        }
        return marker
    }
    
    func adjustCameraForTheSelectedMarker(marker: GMSMarker) {
        // Scroll the map view up to show the marker in the top half of the screen's center
        // Center the marker on the map
        let updateCameraPositionForMarker = GMSCameraUpdate.setTarget(marker.position, zoom: 18.0)
        mainMap.moveCamera(updateCameraPositionForMarker)
        
        // Calculate how much the marker's centered position should be scrolled upwards to remain in the center of small the map
        let newDistanceFromBottom = view.frame.height / 6.0
        
        // Animate the camera to the calculated position
        let updatedCameraPositionForDetailView = GMSCameraUpdate.scrollBy(x: 0, y: newDistanceFromBottom)
        mainMap.animate(with: updatedCameraPositionForDetailView)
    }

    // MARK: Segues
    @IBAction func exitFromLocationListVC(by segue: UIStoryboardSegue) {
        updateMapWithAddedPins()
    }
    
    @IBAction func returnFromAddPlaceVC(by segue: UIStoryboardSegue) {
        updateMapWithAddedPins()
        // Getting the lastly added pins location to move the camera, since pinnedPlaces arrays count is greater than zero it is safe to force unwrap
        let place = LocationService.instance.retrievePlaces().last
        if let coordinate = place?.googlePlaceDetails.coordinate {
           updateCamera(location: coordinate, with: 16.0, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.toAddPlaceVC,
            let vc = segue.destination as? AddPlaceViewController,
            let editablePlace = sender as? GMSPlace {
            vc.place = editablePlace
        } else if segue.identifier == Constants.Segues.toPlaceDetailsVC,
            let vc = segue.destination as? PlaceDetailsViewController {
            vc.close = {
                self.dismiss(animated: true, completion: nil)
                self.updateMapWithAddedPins()
                if let selectedPin = self.selectedPin {
                    self.updateCamera(location: selectedPin.position, with: 16.0, animated: true)
                } else {
                    self.displayLocation(name: LocationService.instance.currentLocation())
                }
            }
        } else if segue.identifier == Constants.Segues.toPoiPopOverVC,
            let destination = segue.destination as? PoiPopOverViewController,
            let ppc = destination.popoverPresentationController, let poi = sender as? POIObject {
            ppc.delegate = self
            destination.poiDetails = poi
        }
    }
}

// MARK: Extensions
extension MainMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        adjustCameraForTheSelectedMarker(marker: marker)
        // Log the last selected marker to center the camera position when PlaceDetailsVC exits
        selectedPin = marker
        
        // Get the tapped on place to send to the PlaceDetailsVC
        selectPlace(for: marker)
        performSegue(withIdentifier: Constants.Segues.toPlaceDetailsVC, sender: self)
        return true
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard LocationManager.instance.authorizationStatus == .denied || LocationManager.instance.authorizationStatus == .restricted else {
            return false
        }
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services in order to use this function!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        // If a point of interest tapped on (without a marker) camera centers the poi in map and segue is performed to popoverv
        var control = false // didTapPOIWithPlaceID delegate method also works when tapped on POI name therefore a control is needed to not allow pop up screen to appear if the place is already pinned
        
        if hintView.isHidden == false {
            hintView.isHidden = true
        }
        // Check if the place is already/pinned
        for (key: _, value: place) in pinnedPlacesOnTheMap {
            if place.googlePlaceDetails.id == placeID {
                control = true
            }
        }
        
        // If the place is not pinned allow pop up window to appear
        if !control {
        updateCamera(location: location, with: 18.0, animated: true)
            let poiDetails = POIObject.init(id: placeID, name: name, location: location)
            _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                self.performSegue(withIdentifier: Constants.Segues.toPoiPopOver, sender: poiDetails)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hintView.isHidden = true
    }
}

extension MainMapViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: Constants.Segues.toAddPlaceVC, sender: place)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension MainMapViewController: UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
