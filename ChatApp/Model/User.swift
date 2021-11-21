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

struct Message: Identifiable {
    
    var id: String {fromId}
    
    let fromId, toId, text: String
//    let timestamp: Timestamp()
    
    init(data: [String: Any]) {
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.text = data["txt"] as? String ?? ""
    }
}


/*
 self.timestamp = data["timestamp"] as? Timestamp() ?? Date.now.formatted(date: .long, time: .shortened)
 */
