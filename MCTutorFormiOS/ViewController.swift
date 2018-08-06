//
//  ViewController.swift
//  MCTutorFormiOS
//
//  Created by Jay Early on 6/28/18.
//  Copyright © 2018 Dexterasoft Research. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, FormViewProtocol {
    // Key values for dictionary
    let STUDENT_ID = "student_id"
    let COURSE = "course"
    let TUTOR_ID = "tutor_id"
    let TUTOR_NAME = "tutor_name"
    let STUDENT_NAME = "student_name"
    
    let TARGET_CSV_NAME = "vBanner1" //vBanner1
    
    //MARK: Properties
    @IBOutlet weak var tutorNameTextField: UITextField!
    @IBOutlet weak var tutorNameLabel: UILabel!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var studentIDTextField: UITextField!
    
    private var m_path: String?
    private var m_mcLookup: MCLookup?
    private var m_queryResults: [KeyData] = []
    
    /*@IBAction func submitButtonAction(_ sender: UIButton) {
        if (studentIDTextField.text != nil){
            studentID = studentIDTextField.text!
            performSegue(withIdentifier: "segue", sender: self)
        }
    }*/
    
    /*@IBAction func confirmStudentID(_ sender: Any) {
        if (studentIDTextField.text != nil){
            studentID = studentIDTextField.text!
            performSegue(withIdentifier: "segue", sender: self)
        }
    }*/
    
    //Should read in from text file 
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
        
        //DATE FIELD
        //To set the current date
        dateField.text = convertDateFormatter()
        
        //to restrict user input
        dateField.isUserInteractionEnabled = false
        
        //Continue working: numberpad input
        self.studentIDTextField.delegate = self
        studentIDTextField.keyboardType = UIKeyboardType.asciiCapableNumberPad
        studentIDTextField.keyboardType = UIKeyboardType.numbersAndPunctuation
        
        m_path = Bundle.main.path(forResource: TARGET_CSV_NAME, ofType: "txt") ?? ""
        
        // Read data from csv and/or database
        m_queryResults = readData(studentID: "20859287")
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //To hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Date Format (Foundations library)
    func convertDateFormatter() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" // change format as per needs
        let result = formatter.string(from: date)
        return result
    }
    
    //MARK: Actions
    @IBAction func submitAction(_ sender: Any) {
        if (!(studentIDTextField.text?.isEmpty)!){
            // Instantiate FormViewController
            let formViewController = self.storyboard?.instantiateViewController(withIdentifier: "FormViewController") as! FormViewController
            
            // Set student ID variable in the FormViewController to student ID value in the studentIDTextField of this view controller
            formViewController.setStudentID(id: studentIDTextField.text!)
            formViewController.setDelegate(delegate: self)
            
            self.navigationController?.pushViewController(formViewController, animated: true)
        } else {
            print("You must enter the student ID!")
        }
    }
    
    /**
     Initialize the database when necessary
     NB: The file path is for the CSV data, not the database path
     */
    public func initializeDB() {
        if !(m_path?.isEmpty)! {
            do {
                m_mcLookup = try MCLookup(file: m_path!)
                try m_mcLookup?.initDatabase()
            } catch {
                print("Database request failed")
            }
        }
    }
    
    //MARK: Data import/querying
    func readData(studentID: String) -> [KeyData] {
        // TEST CODE vvvvv
        if !(m_path?.isEmpty)! {
            do {
                let timer = ParkBenchTimer()
                let mcLookup = try MCLookup(file: m_path!)
                
                // Return results
                // return mcLookup.getKeyDataByStudentID(id: studentID)
                
                let results = mcLookup.getKeyDataByStudentID(id: studentID)
                
                // Display all results
                for result in results {
                    print("Student's First Name: \(result.stuFName) \tLast Name: \(result.stuLName)")
                    print("MC# M\(result.stuID)")
                    print("Course (E.g., ENGL101A): \(result.course) \tSection: \(result.section)")
                    print("Professor (LAST NAME, First name): \(result.profName)")
                    print("Campus: \(result.mcCampus)")
                    print()
                }
                
                print("\nDone.")
                print("Took \(timer.stop()) seconds.")
            } catch {
                print("Database request failed")
            }
        } else {
            print("Path was not set for CSV data")
        }
        
        return []
    }
    
    /**
     Protocol Function:
     Conform to FormViewProtocol to get data back from FormViewController if necessary
     */
    func getData(data: String) {}
}

