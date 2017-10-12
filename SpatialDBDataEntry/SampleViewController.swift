//
//  SampleViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/9/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {

    //MARK: Properties
    
    
    /* This value is either passed by `SampleTableViewController` via `prepare(for:sender)`
     or constructed as part of adding a new sample.
     */
    var sample: Sample?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
