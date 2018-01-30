//
//  ExportProjectsTableViewCell.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 1/30/18.
//  Copyright © 2018 University of Utah. All rights reserved.
//

import UIKit

class ExportProjectsTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var selectedSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
