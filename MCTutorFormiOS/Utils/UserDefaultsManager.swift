//
//  UserDefaultsManager.swift
//  MCTutorFormiOS
//
//  Created by Brett Allen on 8/8/18.
//  Copyright © 2018 Dexterasoft Research. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    public static let TUTORS_KEY: String = "tutors_list"
    
    public static func initializeUserDefaults(datFile: UserDefaults, datFileKey: String) -> Void{
        datFile.removeObject(forKey: datFileKey)
        datFile.synchronize()
    }
}
