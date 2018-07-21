//
//  FormViewController.swift
//  MCTutorFormiOS
//
//  Created by Jay Early on 7/20/18.
//  Copyright © 2018 Dexterasoft Research. All rights reserved.
//

import UIKit
import Foundation

class FormViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var studentIDTextField2: UITextField!
    @IBOutlet weak var studentFNameTextField: UITextField!
    @IBOutlet weak var studentLNameTextField: UITextField!
    @IBOutlet weak var courseNameTextField: UITextField!
    @IBOutlet weak var courseSectionTextField: UITextField!
    @IBOutlet weak var professorNameTextField: UITextField!
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Actions
    @IBAction func backButton(_ sender: UIButton) {
        performSegue(withIdentifier: "segue_back", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Will restrict user interaction
        studentIDTextField2.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        studentIDTextField2.text = studentID
        //performSegue(withIdentifier: "segue", sender: self)
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
