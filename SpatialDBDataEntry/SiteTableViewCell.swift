//
//  SiteTableViewCell.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/1/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit

class SiteTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var siteIDLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
