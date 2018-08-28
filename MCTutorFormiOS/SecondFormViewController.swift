//
//  SecondFormViewController.swift
//  MCTutorFormiOS
//
//  Created by Jay Early on 8/27/18.
//  Copyright © 2018 Dexterasoft Research. All rights reserved.
//

import UIKit

class SecondFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
    
    
    //MARK: properties
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var nextStepsTextView: UITextView!
    @IBOutlet weak var marginFontTextField: UITextField!
    @IBOutlet weak var contentOrgPickerView: UIPickerView!
    @IBOutlet weak var outliningPickerView: UIPickerView!
    
    
    @IBOutlet weak var numPickerView: UIPickerView!
    @IBOutlet weak var introductionPickerView: UIPickerView!
    @IBOutlet weak var thesisPickerView: UIPickerView!
    @IBOutlet weak var supportPickerView: UIPickerView!
    @IBOutlet weak var conclusionPickerView: UIPickerView!
    @IBOutlet weak var transitionsPickerView: UIPickerView!
    @IBOutlet weak var documentationPickerView: UIPickerView!
    @IBOutlet weak var logicPickerView: UIPickerView!
    
    let numbers = ["1", "2", "3", "4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        marginFontTextField.clearButtonMode = .whileEditing
        
        numPickerView.delegate = self
        numPickerView.dataSource = self
        
        contentOrgPickerView.delegate =  self
        contentOrgPickerView.dataSource = self
        
        outliningPickerView.delegate = self
        outliningPickerView.dataSource = self
        
        introductionPickerView.delegate = self
        introductionPickerView.dataSource = self
        
        thesisPickerView.delegate = self
        thesisPickerView.dataSource = self
        
        supportPickerView.delegate = self
        supportPickerView.dataSource = self
        
        conclusionPickerView.delegate = self
        conclusionPickerView.dataSource = self
        
        transitionsPickerView.delegate = self
        transitionsPickerView.dataSource = self
        
        documentationPickerView.delegate = self
        documentationPickerView.dataSource = self
        
        outliningPickerView.delegate = self
        outliningPickerView.dataSource = self
        
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numbers[row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // Go to FinalFormViewController
    @IBAction func next(_ sender: UIButton) {
        let finalFormViewController = self.storyboard?.instantiateViewController(withIdentifier: "FinalFormViewController") as! FinalFormViewController
        
        self.present(finalFormViewController, animated: true, completion: nil)
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
