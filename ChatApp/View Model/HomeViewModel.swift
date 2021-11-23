//
//  MainMessagesViewModel.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI
import Firebase

class HomeViewModel: ObservableObject {
    
    @Published var alertMessage : String = ""
    @Published var anUser : User?
    @Published var allUser = [User]()
    @Published var isUserCurrenlyLoggedOut : Bool = false
    
    @Published var allMessage = [Message]()
    
    
    
    init(){
        
        fetchCurrentUser()
        fetchAllUsers()
        
        //        DispatchQueue.main.async {
        //            self.isUserCurrenlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        //        }
    }
    
    
    
    //    func fetchCurrentUser(completion: @escaping ()->()) {
    func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.alertMessage = "Could not find firebase uid"
            return
            
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                
                self.alertMessage = error.localizedDescription
                print(self.alertMessage)
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
    
    
    func fetchAllUsers() {
        
        FirebaseManager.shared.firestore
            .collection("users")
            .getDocuments { documentSnapshot, error in
                if let error = error {
                    
                    self.alertMessage = error.localizedDescription
                    print(error.localizedDescription)
                    return
                    
                }
                
                documentSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = User(data: data)
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid{
                        self.allUser.append(.init(data: data))
                    }
                    
                    print(data)
                    
                })
            }
    }
    
    //MARK: - handleSignOut
    func handleSignOut() {
        
        isUserCurrenlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        
    }
    
    
    //MARK: - handleSend
    func sendMessage(selectedUser: User?, text: String) {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = selectedUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = ["fromId" : fromId, "toId" : toId, "text" : text, "timestamp" : Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                
                self.alertMessage = error.localizedDescription
                print(self.alertMessage)
                return
                
            }
            
            print("Successfully saved current user sending message")
            
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                
                self.alertMessage = error.localizedDescription
                print(self.alertMessage)
                return
                
            }
            
            print("Recipient saved message as well")
        }
    }
    
    
    //MARK: - getMessage
    
    //    func getMessage(selectedUser: User?) {
    //
    //        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
    //
    //        guard let toId = selectedUser?.uid else { return }
    //
    //        FirebaseManager.shared.firestore
    //            .collection("messages")
    //            .document(fromId)
    //            .collection(toId)
    //            .order(by: "timestamp", descending: false)
    //            .getDocuments { documentSnapshot, error in
    //                if let error = error {
    //
    //                    self.alertMessage = error.localizedDescription
    //                    print(self.alertMessage)
    //                    return
    //
    //                }
    //
    //                documentSnapshot?.documents.forEach({ snapshot in
    //                    let data = snapshot.data()
    //                    self.allMessage.append(.init(data: data))
    //                })
    //            }
    //    }
    
    //MARK: - getMessage
    func getMessage(selectedUser: User?) {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = selectedUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp", descending: false)
            .getDocuments { documentSnapshot, error in
                
                guard let data = documentSnapshot else {return}
                
                self.allMessage = data.documents.compactMap({ snap in
                    
                    let id = snap.documentID
                    let fromId = snap.get("fromId") as! String
                    let toId = snap.get("toId") as! String
                    let text = snap.get("text") as! String
                    let timestamp = snap.get("timestamp") as! Timestamp
                    
                    return Message(id: id, fromId: fromId, toId: toId, text: text, timestamp: timestamp)
                    
                })
            }
    }
}
