//
//  LocationPlacesListViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-04-07.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class LocationPlacesListViewController: UITableViewController {
    
    let cellIdentifier = "defaultCell"
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredPlaces = [VacationPlannerPlace]()
    private var placesList = [VacationPlannerPlace]()
    private(set) var selectedPlace: VacationPlannerPlace!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configurePlacesList()
        title = LocationService.instance.currentLocation()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredPlaces.count : placesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let place = searchController.isActive ? filteredPlaces[indexPath.row] : placesList[indexPath.row]
        cell.textLabel?.text = place.googlePlaceDetails.name
        cell.detailTextLabel?.text = place.category
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = searchController.isActive ? filteredPlaces[indexPath.row] : placesList[indexPath.row]
        LocationService.instance.selectPlace(place: selectedPlace)
    }

    func configureSearchController() {
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All"] + Constants.Category.categories
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        searchController.searchResultsUpdater = self
    }
    
    func configurePlacesList() {
        guard let index = LocationService.instance.selectedLocationIndex else { return }
        placesList = LocationService.instance.locations[index].places
    }
    
    func filterSearchController(searchBar: UISearchBar) {
        guard let scope = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else { return }
        
        let searchText = searchBar.text ?? ""
        
        filteredPlaces = placesList.filter({ (place) -> Bool in
            
            let isScopeMatching = (place.category == scope) || (scope == "All")
            let isMatching = place.googlePlaceDetails.name.lowercased().contains(searchText.lowercased()) || searchText.lowercased().count == 0
            return isScopeMatching && isMatching
        })
        tableView.reloadData()
    }
}

extension LocationPlacesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchBar: searchController.searchBar)
    }
}

extension LocationPlacesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterSearchController(searchBar: searchBar)
    }
}
