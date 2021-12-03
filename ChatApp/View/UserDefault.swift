//
//  UserDefault.swift
//  ChatApp
//
//  Created by Quang Bao on 02/12/2021.
//

import SwiftUI

extension UserDefaults {
    
    enum UserDefaultsKeys : String {
        
        case isLoggedIn
    }
    
    func setIsLoggedIn(value : Bool) {
        
        //        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        //        UserDefaults.standard.synchronize()
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
        
    }
    
    func isLoggedIn() -> Bool {
        
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        
    }
    
}
