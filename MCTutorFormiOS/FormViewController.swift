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
    //@IBOutlet var myRadioYesButton:DownStateButton?
    //@IBOutlet var myRadioNoButton:DownStateButton?
    @IBOutlet var label: UILabel!
    
    let button = RadioButton(frame: CGRect(x: 20, y: 170, width: 50, height: 50))
    let label2 = UILabel(frame: CGRect(x: 90, y: 160, width: 200, height: 70))
    
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
        
        button.addTarget(self, action: #selector(manualAction(sender:)), for: .touchUpInside)
        button.innerCircleCircleColor = UIColor.red
        self.view.addSubview(button)
        label2.text = "Not Selected"
        self.view.addSubview(label2)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        studentIDTextField2.text = studentID
        //performSegue(withIdentifier: "segue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func manualAction (sender: RadioButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            label2.text = "Selected"
        } else{
            label2.text = "Not Selected"
        }
    }
    
    @IBAction func didPressButton(_ sender: RadioButton) {
        
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            label.text = "Selected"
        } else{
            label.text = "Not Selected"
        }
    }
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

