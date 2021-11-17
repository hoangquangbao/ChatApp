//
//  MainMessagesViewModel.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

class HomeViewModel: ObservableObject {

    @Published var alertMessage : String = ""
    @Published var anUser : User?
    @Published var allUser : [User] = []
    @Published var isUserCurrenlyLoggedOut : Bool = false

    init() {
        fetchCurrentUser()
        fetchAllUser()
        DispatchQueue.main.async {
            self.isUserCurrenlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
    }

//    func fetchCurrentUser(completion: @escaping ()->()) {
    func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.alertMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snap, err in
            if let error = err {
                self.alertMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            guard let data = snap?.data() else {
                self.alertMessage = "No data found"
                return
            }
            
            let id = ""
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageUrl = data["profileImageUrl"] as? String ?? ""
            let username = data["username"] as? String ?? ""
            
            self.anUser = User(id: id, uid: uid, email: email, profileImageUrl: profileImageUrl, username: username)
//            completion()
        }
    }
    
    func fetchAllUser() {
        
        FirebaseManager.shared.firestore.collection("users").getDocuments { snap, err in
            if let error = err {
                self.alertMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            guard let arrayData = snap else {
                self.alertMessage = "No data found"
                return
            }
            
            self.allUser = arrayData.documents.compactMap({ data in
                
                let id = data.documentID
                let uid = data.get("uid") as? String ?? ""
                let email = data.get("email") as? String ?? ""
                let profileImageUrl = data.get("profileImageUrl") as? String ?? ""
                let username = data.get("username") as? String ?? ""
                
                return User(id: id, uid: uid, email: email, profileImageUrl: profileImageUrl, username: username)
            })
        }
    }
    
    func handleSignOut() {
        isUserCurrenlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}
