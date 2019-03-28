//
//  LocationListViewController.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-03-05.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class LocationListViewController: UITableViewController {

    var selectedRowIndex: Int? // MainMapVC accesses this var within the exitFromLocationListVC(by segue:) function to get the selected VacationPlannerLocation object from the locations array
    let cellIdentifier = "defaultCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationService.instance.load()
        configureBackButton()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationService.instance.locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LocationListTableCell{
            cell.title.text = LocationService.instance.locations[indexPath.row].name
            if LocationService.instance.locations[indexPath.row].places.count > 0 {
                cell.placesButton.setTitle("\(LocationService.instance.locations[indexPath.row].places.count) Places", for: .normal)
            } else {
                cell.placesButton.isHidden = true
                cell.chevronImage.isHidden = true
            }
            
            cell.listIndex = indexPath.row
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LocationService.instance.selectLocation(index: indexPath.row)
        //selectedRowIndex = indexPath.row
        performSegue(withIdentifier: Constants.Segues.returnToMainMapVCWithLocation, sender: self)
    }

    @IBAction func addNewLocationButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segues.toAddLabelVC, sender: self)
    }
    
    @IBAction func exit(by seque: UIStoryboardSegue) {
       tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            LocationService.instance.deleteLocation(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }  
    }
    
    func configureBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
}

extension LocationListViewController: LocationListTableCellDelegate {
    func tappedOnLocationListTableCell(with sender: Any?) {
        if let index = sender as? Int {
            LocationService.instance.selectLocation(index: index)
            performSegue(withIdentifier: "toLocationPlacesListVC", sender: self)
        }
    }
}
