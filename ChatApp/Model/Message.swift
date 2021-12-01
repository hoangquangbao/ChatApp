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
    
    let fromId, toId, username, profileImageUrl, text: String
//    let timestamp: NSNumber
    let timestamp: Timestamp

    //    init(data: [String: Any]) {
    //
    //        self.id = UUID().uuidString
    //        self.fromId = data["fromId"] as? String ?? ""
    //        self.toId = data["toId"] as? String ?? ""
    //        self.username = data["username"] as? String ?? ""
    //        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    //        self.text = data["123"] as? String ?? ""
    //        self.timestamp = data["timestamp"] as! Timestamp
    //
    //    }
}






//extension Date{
//    
//    static func dateFromCustomString(customString: String) -> Date {
//        
//        let dateFomatter = DateFormatter()
//        dateFomatter.dateFormat = "MM/dd/yyyy"
//        return dateFomatter.date(from: customString) ?? Date()
//        
//    }
//    
//}
