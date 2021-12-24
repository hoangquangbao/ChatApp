//
//  ChatUser.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI
import Firebase

struct User: Identifiable {
        
    let id, email, name, profileImageUrl: String
    
    // To identify whether it is added to Participant List....
    var isAdded: Bool = false
    
    init(data: [String: Any]) {
        
        self.id = data["id"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.isAdded = (data["isAdded"] != nil)
        
    }
}
