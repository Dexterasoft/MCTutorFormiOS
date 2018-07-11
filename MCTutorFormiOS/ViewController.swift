//
//  ViewController.swift
//  MCTutorFormiOS
//
//  Created by Jay Early on 6/28/18.
//  Copyright © 2018 Dexterasoft Research. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    //MARK: Properties
    @IBOutlet weak var tutorNameTextField: UITextField!
    @IBOutlet weak var tutorNameLabel: UILabel!
    
    let tutors = ["", "John Smith", "Mary Washington", "Benjamin Early"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tutorPickerView = UIPickerView()
        tutorPickerView.delegate = self
        
        tutorNameTextField.inputView = tutorPickerView
        
        //This will allow user to click and interact with dropdown
        tutorNameTextField.isUserInteractionEnabled = true
        
        //note: will need to revisit this later
        tutorNameTextField.allowsEditingTextAttributes = false
    }
    
    func numberOfComponents(in tutorPickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tutors.count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tutors[row]
        
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tutorNameTextField.text = tutors[row]
    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    
    
    //MARK: Data import
    func readData(file:String) ->String! {
        let a:String? = nil
        if a != nil {
            let b = a!
            print(b)
        } else {
            print ("That was nil")
        }
        return nil
    }
    
    //
    


}

