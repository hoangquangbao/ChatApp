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
    @Published var allUser = [User]()
    @Published var isUserCurrenlyLoggedOut : Bool = false

    init() {
        fetchCurrentUser()
//        fetchAllUser()
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
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.alertMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            guard let data = snapshot?.data() else {
                self.alertMessage = "No data found"
                return
            }
            
            self.anUser = .init(data: data)
//            completion()
        }
    }
    
    func fetchAllUser() {
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentsSnapshot, error in
            if let error = error {
                self.alertMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                let user = User(data: data)
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid{
                    self.allUser.append(.init(data: data))
                }
            })
        }
    }
    
    func handleSignOut() {
        isUserCurrenlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}
