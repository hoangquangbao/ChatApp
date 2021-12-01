//
//  LastMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 01/12/2021.
//

import SwiftUI
import Firebase

struct LastMessage: Identifiable {
    
    var id: String
    
    let toId, username, profileImageUrl, lastMessage: String
    let timestamp: Timestamp
    
}

