//
//  MainMessagesViewModel.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI
import SDWebImageSwiftUI

class HomeViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var anUser: User?
    @Published var isUserCurrenlyLoggedOut = false

    init() {
        fetchCurrentUser()
        
        DispatchQueue.main.async {
            self.isUserCurrenlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
    }

//    func fetchCurrentUser(completion: @escaping ()->()) {
    func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snap, err in
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
            
                self.anUser = User(uid: uid, email: email, profileImageUrl: profileImageUrl, username: username)

            print(email)
//            completion()
        }
    }
    
    func handleSignOut() {
        isUserCurrenlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}
