//
//  LastMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 01/12/2021.
//

import SwiftUI
import Firebase

struct LastMessage: Identifiable {
    
//    var id: String
    
    let id, fromId, toId, name, profileImageUrl, text: String
    let timestamp: Timestamp
//    let timestamp: Date

    
//    init(data: [String: Any]) {
//
//        //self.id = UUID().uuidString
//        self.fromId = data["fromId"] as? String ?? ""
//        self.toId = data["toId"] as? String ?? ""
//        self.username = data["username"] as? String ?? ""
//        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
//        self.text = data["text"] as? String ?? ""
//        self.timestamp = data["timestamp"] as! Timestamp
//
//    }
}
