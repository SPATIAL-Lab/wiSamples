//
//  ViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/20/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var contactEmailTextField: UITextField!
    @IBOutlet weak var projectIDLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        projectNameTextField.delegate = self
        contactNameTextField.delegate = self
        contactEmailTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //MARK: Actions
    
    @IBAction func generateProjectID(_ sender: UIButton) {
        if let projectName = projectNameTextField.text {
            projectIDLabel.text = projectName + "_01";
        }
    }
}

