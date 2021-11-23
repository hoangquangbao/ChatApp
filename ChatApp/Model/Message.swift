//
//  Message.swift
//  ChatApp
//
//  Created by Quang Bao on 22/11/2021.
//

import SwiftUI
import Firebase

struct Message: Identifiable {
    
    var id: String
    
    let fromId, toId, text: String
    let timestamp: Timestamp
    
}
