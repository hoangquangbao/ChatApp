//
//  ChatUser.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI

struct User: Identifiable {
    
    var id: String {uid}
    
    let uid, email, profileImageUrl, username: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
    }
}
