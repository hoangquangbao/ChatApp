//
//  MainMessagesViewModel.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI
import SDWebImageSwiftUI

class MainMessagesViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?

//    init() {
//        fetchCurrentUser()
//    }

    func fetchCurrentUser() {
        
        let db = FirebaseManager.shared
        
        guard let uid = db.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }

        db.firestore.collection("users").document(uid).getDocument { snap, err in
            
            if let error = err {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            guard let data = snap?.data() else {
                
                self.errorMessage = "No data found"
                return
            }
            
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageUrl = data["profileImageUrl"] as? String ?? ""
            let username = data["username"] as? String ?? ""
            self.chatUser = ChatUser(uid: uid, email: email, profileImageUrl: profileImageUrl, username: username)

            print(email)
        }
        
        
    }
}
