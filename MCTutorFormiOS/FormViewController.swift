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
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var tutorNameTextField: UITextField!
    @IBOutlet weak var btnCheckBox: UIButton!
    
    private var m_studentID: String = ""
    
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
        
        dateTextField.isUserInteractionEnabled = false
        dateTextField.text = convertDateFormatter()
        
        button.addTarget(self, action: #selector(manualAction(sender:)), for: .touchUpInside)
        button.innerCircleCircleColor = UIColor.red
        self.view.addSubview(button)
        label2.text = "Not Selected"
        self.view.addSubview(label2)
        
        btnCheckBox.setImage(UIImage(named:"CheckMarkEmpty"), for: .normal)
        btnCheckBox.setImage(UIImage(named:"CheckMark"), for: .selected)
        
    }
    
    /**
     Set the student ID so the respective field can be populated
     
     @param id the student's id
     */
    public func setStudentID(id: String) {
        m_studentID = id
        print("Successfully passed student id to FormViewController!")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        studentIDTextField2.text = m_studentID
        //        studentIDTextField2.text = studentID
        //performSegue(withIdentifier: "segue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- checkMarkTapped
    @IBAction func checkMarkTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
        }) { (success) in
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
            }, completion: nil)
        }
        
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
    
    //MARK: Date Format (Foundations library)
    func convertDateFormatter() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" // change format as per needs
        let result = formatter.string(from: date)
        return result
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
    

