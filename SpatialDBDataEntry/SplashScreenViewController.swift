//
//  SplashScreenViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 4/6/18.
//  Copyright © 2018 University of Utah. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    var splashScreenDelay = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(splashScreenDelay)) {
            self.showProjectTableViewController()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showProjectTableViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let projectTableViewController = storyboard.instantiateViewController(withIdentifier: "ProjectTableNavigationController")
        self.present(projectTableViewController, animated: true, completion: nil)
    }

}
