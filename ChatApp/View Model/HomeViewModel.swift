//
//  MainMessagesViewModel.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI
import Firebase

class HomeViewModel: ObservableObject {
    
    //Show error or caution
    @Published var alertMessage : String = ""
    
    //Show owner account
    @Published var anUser : User?
    
    //Show User list
    @Published var allSuggestUsers = [User]()
    @Published var allRecentUsers = [String]()
    
    //Show Chat content
    @Published var allMessages = [Message]()
    
    //Search function
    @Published var searchUser = ""
    @Published var filterUser = [User]()
    @Published var searchMessage = ""
    @Published var filterMessage = [Message]()
    
    
    init(){
        
        fetchCurrentUser()
        fetchAllUsersToSuggest()

    }
    
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
        }
    }
    
    
    func fetchAllUsersToSuggest() {
        
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
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.allSuggestUsers.append(.init(data: data))
                    }
                })
                self.filterUser = self.allSuggestUsers
            }
    }
    
    
    //MARK: - handleSend
    func sendMessage(selectedUser: User?, text: String) {

        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toId = selectedUser?.uid else { return }

        guard let username = selectedUser?.username else { return }

        guard let profileImageUrl = selectedUser?.profileImageUrl else { return }

        let document = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()

        let messageData = ["fromId" : fromId, "toId" : toId, "username" : username, "profileImageUrl" : profileImageUrl, "text" : text, "timestamp" : Timestamp()] as [String : Any]

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
        }
    }
    
    
    //MARK: - getMessage
    
//        func getMessage(selectedUser: User?) {
//
//            guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
//
//            guard let toId = selectedUser?.uid else { return }
//
//            FirebaseManager.shared.firestore
//                .collection("messages")
//                .document(fromId)
//                .collection(toId)
//                .order(by: "timestamp", descending: false)
//                .getDocuments { documentSnapshot, error in
//                    if let error = error {
//
//                        self.alertMessage = error.localizedDescription
//                        print(self.alertMessage)
//                        return
//
//                    }
//                    guard let data = documentSnapshot else {return}
//
//                        data.documents.forEach({ snapshot in
//                        let data = snapshot.data()
//                        self.allMessage.append(.init(data: data))
//                    })
//                }
//        }
    
    //MARK: - fetchMessage
    func fetchMessage(selectedUser: User?) {

        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toId = selectedUser?.uid else { return }

        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp", descending: false)
//            .getDocuments { documentSnapshot, error in
            .addSnapshotListener { documentSnapshot, error in
                
                if let error = error {
                    
                    self.alertMessage = error.localizedDescription
                    return
                    
                }

                guard let data = documentSnapshot else {return}

                self.allMessages = data.documents.compactMap({ snap in

                    let id = snap.documentID
                    let fromId = snap.get("fromId") as? String ?? ""
                    let toId = snap.get("toId") as? String ?? ""
                    let profileImageUrl = snap.get("profileImageUrl") as? String ?? ""
                    let username = snap.get("username") as? String ?? ""
                    let text = snap.get("text") as? String ?? ""
                    let timestamp = snap.get("timestamp") as? Timestamp

//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "MMM d yyyy"
//                    let date = formatter.string(from: timestamp.dateValue())
//                    formatter.dateFormat = "HH:mm"
//                    let time = formatter.string(from: timestamp.dateValue())

//                    return Message(id: id, fromId: fromId, toId: toId, text: text, timestamp: timestamp)
                    return Message(id: id, fromId: fromId, toId: toId, username: username, profileImageUrl: profileImageUrl, text: text, timestamp: timestamp!)

                })
                self.filterMessage = self.allMessages
            }
    }
    
    
    //MARK: - fetchAllUsersToRecent
//    func fetchAllUsersToRecent() {
//
//        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
//
//        FirebaseManager.shared.firestore
//            .collection("messages")
//            .document(fromId)
//            .addSnapshotListener { documentSnapshot, error in
//
//                if let error = error {
//
//                    self.alertMessage = error.localizedDescription
//                    return
//
//                }
//
//                documentSnapshot?.documents.forEach { snapshot in
//                    let data = String(snapshot)
//
//                    self.allRecentUsers = self.
//                }
//
////                self.allRecentUsers = data.data()
//            }
//    }
    
    
    //MARK: - filterApplyOnUsers
    func filterApplyOnUsers() {
        
        withAnimation(.linear){
            
            self.filterUser = self.allSuggestUsers.filter({
                return $0.username.lowercased().contains(self.searchUser.lowercased())
            })
//            self.filterUser = self.allSuggestUsers.filter({ User in
//                if User.uid == allSuggestUsers1
//            })
        }
    }
    
    
    //MARK: - filterApplyOnMessages
    func filterApplyOnMessages() {
        
        withAnimation(.linear){
            
            self.filterMessage = self.allMessages.filter({
                
                return $0.text.lowercased().contains(self.searchMessage.lowercased())
                
            })
        }
    }
}
