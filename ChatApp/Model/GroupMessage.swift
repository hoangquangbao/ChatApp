//
//  GroupMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 17/12/2021.
//
import SwiftUI

struct GroupMessage: Identifiable {
    
    let id: String
    
    let groupName, admin: String
    let member: [String]
    //let profileImageUrl: String
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.groupName = data["groupName"] as? String ?? ""
        self.admin = data["admin"] as? String ?? ""
        self.member = data["member"] as? [String] ?? []
        
        
        //self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
