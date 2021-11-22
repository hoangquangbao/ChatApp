//
//  Message.swift
//  ChatApp
//
//  Created by Quang Bao on 22/11/2021.
//

import SwiftUI
import Firebase

struct Message: Identifiable {
    
    var id: String {fromId}
    
    let fromId, toId, text: String
    let timestamp: Timestamp
    
    init(data: [String: Any]) {
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.timestamp = data["timestamp"] as! Timestamp
        
    }
}