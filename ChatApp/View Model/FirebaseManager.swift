//
//  FirebaseManager.swift
//  ChatApp
//
//  Created by Quang Bao on 17/11/2021.
//

import SwiftUI
import Firebase

class FirebaseManager : NSObject {
    
    let auth : Auth
    let storage : Storage
    let firestore : Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        
        FirebaseApp.configure()

        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
        
        super.init()
    }
}
