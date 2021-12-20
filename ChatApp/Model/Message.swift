//
//  Message.swift
//  ChatApp
//
//  Created by Quang Bao on 22/11/2021.
//

import SwiftUI
import Firebase

struct Message: Identifiable {
    
//    var id: String
    
    let id, fromId, toId, text, imgMessage: String
//    let imgMessage : Data
//    let timestamp: NSNumber
    let timestamp: Timestamp
//    let timestamp: Date


//        init(data: [String: Any]) {
//    
//            self.id = UUID().uuidString
//            self.fromId = data["fromId"] as? String ?? ""
//            self.toId = data["toId"] as? String ?? ""
//            self.text = data["text"] as? String ?? ""
//            self.timestamp = data["timestamp"] as! Timestamp
//    
//        }
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
