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
    @IBOutlet weak var addTutorTextField: UITextField!
    
    private var m_csvPath: String?
    private var m_mcLookup: MCLookup?
    private var m_queryResults: [KeyData] = []
    
    // Used to store list of tutor names
    private var m_tutorsFile: UserDefaults = UserDefaults.standard
    private var m_tutorsSet: NSMutableSet?
    
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
    
    private let TUTORS_PATH = Bundle.main.path(forResource: "TutorNames", ofType: "txt")!
    
    //Should read in from text file 
//    var tutors = ["", "John Smith", "Mary Washington", "Benjamin Early"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        //        readTutorData(path: TUTORS_PATH)
        loadTutors()
        
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
        
        m_csvPath = Bundle.main.path(forResource: TARGET_CSV_NAME, ofType: "txt") ?? ""
        
        addTutorTextField.isHidden = true;
    }
    
    /**
     Save the tutors from the tutors mutable set (hash set) to the UserDefaults tutors file
     */
    private func saveTutors() {
        print("Saving...")
        
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: m_tutorsSet ?? NSMutableSet())
        m_tutorsFile.set(encodedData, forKey: UserDefaultsManager.TUTORS_KEY)
        m_tutorsFile.synchronize()
        
        print("Save Successful.")
    }
    
    /**
     Load all the tutors into the tutors mutable set (hash set)
     */
    private func loadTutors() {
        print("Loading tutors...")
        
        if let key = m_tutorsFile.object(forKey: UserDefaultsManager.TUTORS_KEY){
            
            let decoded: Data = key as! Data
            
            print("Decoded data: \(decoded)")
            
            let decodedItems = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! NSMutableSet
            
            m_tutorsSet = decodedItems
            
            if(m_tutorsSet?.count != 0){
                print("Successfully loaded tutors.")
            }else{
                print("No tutors to load.")
                m_tutorsSet = NSMutableSet()
            }
            
        }else{
            print("No tutors to load.")
            m_tutorsSet = NSMutableSet()
        }
        
        print("Loading complete.")
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
        return (m_tutorsSet?.count)!
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(m_tutorsSet!)[row] as? String
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tutorNameTextField.text = Array(m_tutorsSet!)[row] as? String
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
            
            // Set delegate to enable ability to receive data back if necessary
            formViewController.setDelegate(delegate: self)
            
            // Read data from csv and/or database
            let queryTimer = ParkBenchTimer()
            m_queryResults = readData(studentID: studentIDTextField.text!) // Test Case: "20859287"
            print("\nDone.\nQuery took \(queryTimer.stop()) seconds.")
            
            // Only pass data to FormViewController and navigate if there were query results returned
            if !m_queryResults.isEmpty {
                // Pass query results to FormViewController
                formViewController.setQueryResults(queryResults: self.m_queryResults)
                
                // Navigate to the FormViewController through the NagivationController
                self.navigationController?.pushViewController(formViewController, animated: true)
            } else {
                let msg = "The provided Student ID could not be found in the database. Please try again."
                displayAlertDialog(title: "No Query Results Found", message: msg)
            }
            
           
        } else {
            print("You must enter the student ID!")
        }
    }
    
    /**
     Display an alert dialog box with a provided title and message
     */
    private func displayAlertDialog(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Display loading dialog when a background task is running.
     */
    private func getLoadingDialog(message: String) -> UIAlertController{
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 90)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        self.present(alertController, animated: true, completion: nil)
        
        return alertController
    }
    
    @IBAction func addTutorAction(_ sender: UIButton) {
        if(tutorNameTextField.text?.isEmpty)!{
            addTutorTextField.isHidden = false
        }
        if(!((addTutorTextField.text?.isEmpty)!)){
//            print("Call write function")
//            writeToFile(value: addTutorTextField.text!)
           // tutors.append(addTutorTextField.text!)
            if !(m_tutorsSet?.contains(addTutorTextField.text!))! {
                m_tutorsSet?.add(addTutorTextField.text!)
                saveTutors()
            } else {
                let msg = "The tutor that was entered already exists on file. Please enter a different tutor name."
                displayAlertDialog(title: "Tutor Already Exists", message: msg)
            }
            
        }
    }
    
    /*Write data to existing text file TutorNames.txt
     located within the dopcuments directory.
 */
    func writeToFile(value: String){
        /*let path = "TutorNames.txt"
        
        // Set the contents
        let contents = addTutorTextField.text!
        
        do {
            // Write contents to file
            try contents.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }*/
//        let fileName = "TutorNames"
//        var filePath = ""
//        let filePath = Bundle.main.path(forResource: fileName, ofType: "txt")!
        
        // Fine documents directory on device
//        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
//
//        if dirs.count > 0 {
//            let dir = dirs[0] //documents directory
//            filePath = dir.appending("/" + fileName)
//            print("Local path = \(filePath)")
//        } else {
//            print("Could not find local directory to store file")
//            return
//        }
        
        // Set the Tutor names
//        let tutorNameToWrite = addTutorTextField.text!
//
//        do {
//            // Write contents to file
//            try tutorNameToWrite.write(toFile: TUTORS_PATH, atomically: false, encoding: String.Encoding.utf8)
//            //Will add file contents to tutors array.
//            tutors.append(tutorNameToWrite)
//
//        }
//        catch let error as NSError {
//            print("An error took place: \(error)")
//        }
//
//        // Test if it works
//        readTutorData(path: TUTORS_PATH)
    }
    
    /**
     
     */
    public func readTutorData(path: String) {
//        print("Reading tutor data...")
//
//        // Read file content.
//        do {
//            // Read file content
//            let contentFromFile = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
//            print(contentFromFile)
//        }
//        catch let error as NSError {
//            print("An error took place: \(error)")
//        }
    }
    
    
    /**
     Initialize the database when necessary
     NB: The file path is for the CSV data, not the database path
     */
    public func initializeDB() {
        if !(m_csvPath?.isEmpty)! {
            do {
                let initTimer = ParkBenchTimer()
                let mcLookup = try MCLookup(file: m_csvPath!)
                
                print("Initializing database...")
                try mcLookup.initDatabase()
                print("Done. Database initialization took \(initTimer.stop()) seconds.")
            } catch {
                print("Database Initialization Error: Database request failed")
            }
        } else {
            print("Database Initialization Error: Path was not set for CSV data")
        }
    }
    
    //MARK: Data import/querying
    func readData(studentID: String) -> [KeyData] {
        if !(m_csvPath?.isEmpty)! {
            do {
                let mcLookup = try MCLookup(file: m_csvPath!)
                
                // Return results
                return mcLookup.getKeyDataByStudentID(id: studentID)
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

