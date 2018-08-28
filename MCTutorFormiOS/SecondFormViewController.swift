//
//  SecondFormViewController.swift
//  MCTutorFormiOS
//
//  Created by Jay Early on 8/27/18.
//  Copyright © 2018 Dexterasoft Research. All rights reserved.
//

import UIKit

class SecondFormViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
