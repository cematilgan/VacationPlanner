//
//  PoiPopOverViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-23.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit
import GooglePlaces

class PoiPopOverViewController: UIViewController {
  
    @IBOutlet weak var topLevelStackView: UIStackView!
    @IBOutlet weak var popOverNameLabel: UILabel!
    @IBOutlet weak var popOverTypeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var poiDetails: POIObject?
    private var gmsPlace: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        activityIndicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let fittedSize = topLevelStackView?.sizeThatFits(UIView.layoutFittingCompressedSize) {
            preferredContentSize = CGSize(width: fittedSize.width + 30, height: fittedSize.height + 30)
        }
    }
    
    @IBAction func addPlaceButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segues.showAddPlaceVC, sender: self)
    }
    
    func setupView(){
        guard let poiDetails = poiDetails else { return }
        popOverNameLabel.text = poiDetails.name
        PlaceDetailsService.instance.getGooglePlaceDetails(for: poiDetails.id) { (success, place) in
            guard success == true, let place = place, let placeType = place.types?.first else { return }
            self.popOverTypeLabel.text = Utilities.editStringForPlaceTypes(text: placeType)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.gmsPlace = place
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddPlaceViewController{
            destinationVC.place = gmsPlace
        }
    }

}
