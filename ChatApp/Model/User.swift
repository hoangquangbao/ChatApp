//
//  ChatUser.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI
import Firebase

struct User: Identifiable {
    
    var id: String {uid}
    
    let uid, email, profileImageUrl, username: String
    
    // To identify whether it is added to Participant List....
    var isAdded: Bool = false
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.isAdded = (data["isAdded"] != nil)
    }
    
//    // To identify whether it is added to Participant List....
//    var isAdded: Bool = false

}

