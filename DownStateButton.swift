//
//  DownStateButton.swift
//  MCTutorFormiOS
//
//  Created by Jay Early on 7/28/18.
//  Copyright © 2018 Dexterasoft Research. All rights reserved.
//

import UIKit

class DownStateButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var myAlternateButton:Array<DownStateButton>?
    
    var downStateImage:String? = "868142-200.png"{
        
        didSet{
            
            if downStateImage != nil {
                
                self.setImage(UIImage(named: downStateImage!), for: UIControlState.selected)
            }
        }
    }
    
    func unselectAlternateButtons(){
        
        if myAlternateButton != nil {
            
            self.isSelected = true
            
            for aButton:DownStateButton in myAlternateButton! {
                
                aButton.isSelected = false
            }
            
        }else{
            
            toggleButton()
        }
    }
    
    func touchesBegan(touches: NSSet, with event: UIEvent) {
        
        unselectAlternateButtons()
        super.touchesBegan(touches as! Set<UITouch>, with: event)
    }
    
    func toggleButton(){
        
        if self.isSelected==false{
            
            self.isSelected = true
        }else {
            
            self.isSelected = false
        }
    }
}

