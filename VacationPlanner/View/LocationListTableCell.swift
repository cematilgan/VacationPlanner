//
//  LocationListTableCell.swift
//  VacationPlanner
//
//  Created by Cem Atilgan on 2019-04-07.
//  Copyright © 2019 Cem Atilgan. All rights reserved.
//

import UIKit

class LocationListTableCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var placesButton: UIButton!
    @IBOutlet weak var chevronImage: UIImageView!
    
    var delegate: LocationListTableCellDelegate!
    var listIndex: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func listButtonTapped(_ sender: UIButton) {
        delegate.tappedOnLocationListTableCell(with: listIndex)
    }
}

protocol LocationListTableCellDelegate {
    func tappedOnLocationListTableCell(with sender: Any?)
}
