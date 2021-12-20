//
//  GroupUser.swift
//  ChatApp
//
//  Created by Quang Bao on 20/12/2021.
//

import SwiftUI

struct GroupUser: Identifiable {
    
    let id, name, profileImageUrl, admin: String
    let member: [String]
    //let profileImageUrl: String
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.admin = data["admin"] as? String ?? ""
        self.member = data["member"] as? [String] ?? []
        
        //self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}


