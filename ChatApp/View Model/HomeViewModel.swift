//
//  MainMessagesViewModel.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    
    //SignIn/Out Page
    @Published var email : String = ""
    @Published var username : String = ""
    @Published var password :  String = ""
    
    @Published var isSignInMode : Bool = true
        
    //Show image library to change Avatar
    @Published var isShowImagePicker = false
    @Published var image: UIImage?
    
    //Show MainMessage Page
    @Published var isShowMainMessageView : Bool = false
    
    //Show error or caution
    @Published var isShowAlert : Bool = false
    @Published var alertMessage : String = ""
    
    //Show owner account
    @Published var anUser : User?
    
    //Show User list
    @Published var allSuggestUsers = [User]()
    @Published var allRecentChatUsers = [RecentChatUser]()
    
    //Show Chat content
    @Published var allMessages = [Message]()
    
    //Search function
    @Published var searchMainMessage = ""
    @Published var filterMainMessage = [RecentChatUser]()
    @Published var searchNewMessage = ""
    @Published var filterNewMessage = [User]()
    @Published var searchChat = ""
    @Published var filterChat = [Message]()
    
    
    init(){
        
        fetchCurrentUser()
        fetchRecentChatUser()
        
        //This initialization main purpose is using for "func getSelectedUser(uid: String) -> User" in MainMessage
        fetchUserToSuggest()

    }
    
    
    //MARK: - Validate Email Format
    func isValidEmail(_ string: String) -> Bool {
        
        if string.count > 100 {
            
            return false
            
        }
        
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        //        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
    
    
    //MARK: - SignIn
    func signIn() {
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            
            if let err = err {
                
                self.isShowAlert = true
                self.alertMessage = err.localizedDescription
                return
                
            } else {

                //self.fetchRecentChatUser()
                
                self.isShowMainMessageView = true

                UserDefaults.standard.setIsLoggedIn(value: true)
                
            }
        }
    }
    
    
    //MARK: - SignUp
    func signUp() {
        
        //Check username is set?
        if self.username == ""{
            
            isShowAlert = true
            alertMessage = "What is your user name?"
            return
            
        } else {
            
            //Check avatar image is set?
            if  self.image == nil{
                
                isShowAlert = true
                alertMessage = "You must set avatar image for your account."
                return
                
            } else {
                
                FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
                    
                    if let err = err {
                        
                        self.isShowAlert = true
                        self.alertMessage = err.localizedDescription
                        return
                        
                    }
                    
                    //Upload image to Firebase
                    self.uploadImageToStorage()
                                        
                }
            }
        }
    }
    
    
    //MARK: - This will upload images into Storage and prints out the locations as well
    func uploadImageToStorage() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData, metadata: nil) { metadata, err in
            
            if let err = err {
                
                self.isShowAlert = true
                self.alertMessage = err.localizedDescription
                return
                
            }
            
            ref.downloadURL { url, err in
                
                if let err = err {
                    
                    self.isShowAlert = true
                    self.alertMessage = err.localizedDescription
                    return
                    
                }
                
                guard let url = url else { return }
                self.storeUserInformation(profileImageUrl: url)
                
            }
        }
    }
    
    
    //MARK: - This will save newly created users to Firestore database collections
    func storeUserInformation(profileImageUrl: URL) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let userData = ["username": username,"email": email, "uid": uid, "profileImageUrl": profileImageUrl.absoluteString]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .setData(userData) { err in
                
                if let err = err {
                    
                    self.isShowAlert = true
                    self.alertMessage = err.localizedDescription
                    return
                    
                }
                
                self.username = ""
                self.email = ""
                self.password = ""
                self.image = nil
                
                //...and show alert successfully created
                self.isShowAlert = true
                self.alertMessage = "Your account has been successfully cereated!"
                
                //Auto move SIGN IN tab...
                self.isSignInMode = true
            }
    }
    
    
    //MARK: - fetchCurrentUser
    func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.alertMessage = "Could not find firebase uid"
            return
            
        }
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
            if let error = error {
                
                self.alertMessage = error.localizedDescription
                print(self.alertMessage)
                return
                
            }
            
            guard let data = snapshot?.data() else {
                
                print("No data found")
                return
                
            }
            
            self.anUser = .init(data: data)
        }
    }
    
    
   //MARK: - fetchAllUsersToSuggest
    func fetchUserToSuggest() {
        
        FirebaseManager.shared.firestore
            .collection("users")
            .addSnapshotListener { documentSnapshot, error in
                
                if let error = error {
                    
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
                
                documentSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = User(data: data)
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.allSuggestUsers.append(.init(data: data))
                    }
                })
                self.filterNewMessage = self.allSuggestUsers
            }
    }
    
    
    //MARK: - sendMessage
    func sendMessage(selectedUser: User?, text: String) {

        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toId = selectedUser?.uid else { return }

        let messageData = ["fromId" : fromId, "toId" : toId, "text" : text, "timestamp" : Timestamp()] as [String : Any]
        
        let senderMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
//        let messageData = ["fromId" : fromId, "toId" : toId, "text" : text, "timestamp" : Date.now] as [String : Any]

        senderMessageDocument.setData(messageData) { error in
            if let error = error {

                self.alertMessage = error.localizedDescription
                print(self.alertMessage)
                return

            }
        }

        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
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
        
        self.recentChatUser(selectedUser: selectedUser, text: text)
        self.fetchRecentChatUser()
    }
    
    
    //MARK: - recentUserChat
    func recentChatUser(selectedUser: User?, text: String){
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toId = selectedUser?.uid else { return }
        
        let uidS = fromId + toId
        
        let uidR = toId + fromId

        //Sender
        guard let usernameS = selectedUser?.username else { return }

        guard let profileImageUrlS = selectedUser?.profileImageUrl else { return }
        
        let senderData = ["fromId" : fromId, "toId" : toId, "username" : usernameS, "profileImageUrl" : profileImageUrlS, "text" : text, "timestamp" : Timestamp()] as [String : Any]
                
        FirebaseManager.shared.firestore
            .collection("recentChatUser") //.collection("recentUserChat")
            .document(uidS)
            .setData(senderData) { error in

                if let error = error {

                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                }
            }
        
        //Receiver
        guard let usernameR = anUser?.username else { return }

        guard let profileImageUrlR = anUser?.profileImageUrl else { return }
        
        
        let receiverData = ["fromId" : toId, "toId" : fromId, "username" : usernameR, "profileImageUrl" : profileImageUrlR, "text" : text, "timestamp" : Date.now] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection("recentChatUser")
            .document(uidR)
            .setData(receiverData) { error in

                if let error = error {

                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                }
            }
    }
    
    
    //MARK: - fetchRecentChatUser
     func fetchRecentChatUser() {
         
         guard let currentUserId = FirebaseManager.shared.auth.currentUser?.uid else { return }
         
         FirebaseManager.shared.firestore
             .collection("recentChatUser")
             .order(by: "timestamp", descending: true)
             .addSnapshotListener { documentSnapshot, error in
//             .getDocuments { documentSnapshot, error in

         
                 if let error = error {
                     
                     self.alertMessage = error.localizedDescription
                     return
                     
                 }
                 
                 guard let data = documentSnapshot else { return }
                 
                 self.allRecentChatUsers = data.documents.compactMap({ snapshot in
                     
                     let id = snapshot.documentID
                     let fromId = snapshot.get("fromId") as? String ?? ""
                     let toId = snapshot.get("toId") as? String ?? ""
                     let username = snapshot.get("username") as? String ?? ""
                     let profileImageUrl = snapshot.get("profileImageUrl") as? String ?? ""
                     let text = snapshot.get("text") as? String ?? ""
                     let timestamp = snapshot.get("timestamp") as? Timestamp
//                     let timestamp = snapshot.get("timestamp") as? Date ?? Date.now
                     
//                     let str = snapshot.get("timestamp")
//                     print(str ?? 1)
                     
                     if currentUserId == fromId {
                         
                         return RecentChatUser(id: id, fromId: fromId, toId: toId, username: username, profileImageUrl: profileImageUrl, text: text, timestamp: timestamp!)
                         
                         
                     } else { return nil }
                 })
                 
                 self.filterMainMessage = self.allRecentChatUsers
             }
     }
    
    
    //MARK: - fetchMessage
//        func fetchMessage(selectedUser: User?) {
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
//                        self.allMessages.append(.init(data: data))
//                    })
//                    self.filterMessage = self.allMessages
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

                guard let data = documentSnapshot else { return }

                self.allMessages = data.documents.compactMap({ snap in

                    let id = snap.documentID
                    let fromId = snap.get("fromId") as? String ?? ""
                    let toId = snap.get("toId") as? String ?? ""
                    let text = snap.get("text") as? String ?? ""
                    let timestamp = snap.get("timestamp") as? Timestamp
//                    let timestamp = snap.get("timestamp") as? Date ?? Date.now

//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "MMM d yyyy"
//                    let date = formatter.string(from: timestamp.dateValue())
//                    formatter.dateFormat = "HH:mm"
//                    let time = formatter.string(from: timestamp.dateValue())

                    return Message(id: id, fromId: fromId, toId: toId, text: text, timestamp: timestamp!)

                })
                self.filterChat = self.allMessages
            }
    }
    
    
    //MARK: - filterApplyOnUsers
    func filterForMainMessage() {
        
        withAnimation(.linear){
            
            self.filterMainMessage = self.allRecentChatUsers.filter({
                return $0.username.lowercased().contains(self.searchMainMessage.lowercased())
            })
        }
    }
    
    
    //MARK: - filterApplyOnUsers
    func filterForNewMessage() {
        
        withAnimation(.linear){
            
            self.filterNewMessage = self.allSuggestUsers.filter({
                return $0.username.lowercased().contains(self.searchNewMessage.lowercased())
            })
        }
    }
    
    
    //MARK: - filterApplyOnMessages
    func filterForChat() {
        
        withAnimation(.linear){
            
            self.filterChat = self.allMessages.filter({
                
                return $0.text.lowercased().contains(self.searchChat.lowercased())
                
            })
        }
    }
}
