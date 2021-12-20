//
//  MainMessagesViewModel.swift
//  ChatApp
//
//  Created by Quang Bao on 16/11/2021.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import CoreMedia

class HomeViewModel: ObservableObject {
    
    //User
    @Published var currentUser : User?
    @Published var isShowActivityIndicator : Bool = false
    
    //Show error or caution
    @Published var isShowAlert : Bool = false
    @Published var alertMessage : String = ""
    
    //Home
    @Published var email : String = ""
    @Published var username : String = ""
    @Published var password :  String = ""
    @Published var isShowImagePicker = false
    @Published var profileImage: UIImage?
    @Published var isSignInMode : Bool = true
    @Published var isShowResetPasswordView : Bool = false
    
    //Main Message
    @Published var isShowMainMessage : Bool = false
    @Published var isShowSignOutButton : Bool = false
    @Published var isShowHomePage : Bool = false
    @Published var allRecentChatUsers = [LastMessage]()
    @Published var searchMainMessage = ""
    @Published var filterMainMessage = [LastMessage]()
    var firestoreListenerRecentChatUser: ListenerRegistration?
    
    //New Message
    @Published var isShowNewMessage : Bool = false
    @Published var searchNewMessage = ""
    @Published var filterNewMessage = [User]()
    @Published var suggestUser = [User]()
    var firestoreListenerUserToSuggest: ListenerRegistration?
    
    //Add Participants
    @Published var isShowAddParticipants : Bool = false
    @Published var searchAddParticipants = ""
    @Published var filterAddParticipants = [User]()
    @Published var participantList = [User]()
    
    //New Group
    @Published var isShowNewGroup : Bool = false
    @Published var groupname : String = ""
    
    //Chat
    @Published var isShowChat : Bool = false
    @Published var allMessages = [Message]()
    @Published var searchChat = ""
    @Published var filterChat = [Message]()
    @Published var isShowImagePickerMessage = false
    var firestoreListenerMessage: ListenerRegistration?
    
    //GroupChat
    @Published var isShowGroupChat : Bool = false
    @Published var searchGroupChat = ""
    @Published var memberIdList = [String]()
    @Published var selectedGroup : GroupUser?

    
    
    init(){
        
        fetchCurrentUser()
        fetchLastMessage()
        //This initialization main purpose is using for "func getSelectedUser(uid: String) -> User" in MainMessage. It conver data type from RecentChatUser to User.
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
                
                UserDefaults.standard.setIsLoggedIn(value: true)
                self.isShowMainMessage = true
                
            }
        }
    }
    
    
    //MARK: - hadleSignOut
    func handleSighOut() {
        
        try? FirebaseManager.shared.auth.signOut()
        UserDefaults.standard.setIsLoggedIn(value: false)
        self.isShowHomePage = true
        self.isShowMainMessage = false
        
    }
    
    
    //MARK: - SignUp
    func signUp() {
        
        //Check name is set?
        if self.username == ""{
            
            isShowAlert = true
            alertMessage = "What is your user name?"
            return
            
        } else {
            
            //Check avatar image is set?
            if  self.profileImage == nil{
                
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
                    
                    //Activate activity indicator..
                    //..true: when start signUp (signUp)
                    //..false: when store user information success (storeUserInformation)
                    self.isShowActivityIndicator = true
                    
                    //Upload image to Firebase
                    self.uploadProfileImageUser()
                    
                }
            }
        }
    }
    
    
    //MARK: - This will upload images into Storage and prints out the locations as well
    func uploadProfileImageUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        guard let imageData = self.profileImage?.jpegData(compressionQuality: 0.5) else { return }
        
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
    
    
    //MARK: - uploadImgMessageToStorage
    func uploadImgMessage(selectedUser: User?, text: String, imgMessage: UIImage?) {
        
        let imgMessageID =  NSUUID().uuidString
        
        let ref = FirebaseManager.shared.storage.reference(withPath: imgMessageID)
        
        guard let imageData = imgMessage?.jpegData(compressionQuality: 0.5) else { return }
        
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
                
                let imgMessageUrl = url.absoluteString
                
                self.sendMessage(selectedUser: selectedUser, text: text, imgMessage: imgMessageUrl)
                //print("imgMessageLink= " + self.imageMessageLink)
            }
        }
        
        //        let metadata = StorageMetadata()
        //        metadata.contentType = "image/jpeg"
        //
        //        let storage = Storage.storage().reference()
        //        storage.child("imageMessage").putData(imageV.jpegData(compressionQuality: 0.4), metadata: metadata) { meta, error in
        //            if let error = error {
        //                print(error)
        //                return
        //            }
        //
        //            storage.child(folder).downloadURL { url, error in
        //                if let error = error {
        //                    // Handle any errors
        //                    print(error)
        //                }
        //            }
        //        }
    }
    
    
    //MARK: - uploadImgMessageToStorage
    //    func uploadImgAvtGroupChatToStorage(selectedUser: [User]?) {
    //
    //        let imgMessageID =  NSUUID().uuidString
    //
    //        let ref = FirebaseManager.shared.storage.reference(withPath: imgMessageID)
    //
    //        guard let imageData = imgMessage?.jpegData(compressionQuality: 0.5) else { return }
    //
    //        ref.putData(imageData, metadata: nil) { metadata, err in
    //
    //            if let err = err {
    //
    //                self.isShowAlert = true
    //                self.alertMessage = err.localizedDescription
    //                return
    //
    //            }
    //
    //            ref.downloadURL { url, err in
    //
    //                if let err = err {
    //
    //                    self.isShowAlert = true
    //                    self.alertMessage = err.localizedDescription
    //                    return
    //
    //                }
    //
    //                guard let url = url else { return }
    //
    //                let imgMessageUrl = url.absoluteString
    //
    //                self.sendMessage(selectedUser: selectedUser, text: text, imgMessage: imgMessageUrl)
    //                //print("imgMessageLink= " + self.imageMessageLink)
    //            }
    //        }
    //
    //        //        let metadata = StorageMetadata()
    //        //        metadata.contentType = "image/jpeg"
    //        //
    //        //        let storage = Storage.storage().reference()
    //        //        storage.child("imageMessage").putData(imageV.jpegData(compressionQuality: 0.4), metadata: metadata) { meta, error in
    //        //            if let error = error {
    //        //                print(error)
    //        //                return
    //        //            }
    //        //
    //        //            storage.child(folder).downloadURL { url, error in
    //        //                if let error = error {
    //        //                    // Handle any errors
    //        //                    print(error)
    //        //                }
    //        //            }
    //        //        }
    //    }
    
    
    //MARK: - This will save newly created users to Firestore database collections
    func storeUserInformation(profileImageUrl: URL) {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let userData = ["name": username,
                        "email": email,
                        "id": uid,
                        "profileImageUrl": profileImageUrl.absoluteString]
        
        FirebaseManager.shared.firestore
            .collection("user")
            .document(uid)
            .setData(userData) { err in
                
                if let err = err {
                    
                    self.isShowAlert = true
                    self.alertMessage = err.localizedDescription
                    return
                    
                }
                
                //Activate activity indicator..
                //..true: when start signUp (signUp)
                //..false: when store user information success (storeUserInformation)
                self.isShowActivityIndicator = false
                
                self.username = ""
                self.email = ""
                self.password = ""
                self.profileImage = nil
                
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
            .collection("user")
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
                
                self.currentUser = .init(data: data)
                
            }
    }
    
    
    //MARK: - fetchUserToSuggest
    func fetchUserToSuggest() {
        
        firestoreListenerUserToSuggest?.remove()
        self.suggestUser.removeAll()
        
        firestoreListenerUserToSuggest = FirebaseManager.shared.firestore
            .collection("user")
            .addSnapshotListener { documentSnapshot, error in
                
                if let error = error {
                    
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
                
                documentSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = User(data: data)
                    if user.id != FirebaseManager.shared.auth.currentUser?.uid {
                        
                        self.suggestUser.append(.init(data: data))
                        
                    }
                })
                
                self.filterNewMessage = self.suggestUser
                self.filterAddParticipants = self.suggestUser
                
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
    
    
    //MARK: - sendMessage
    func sendMessage(selectedUser: User?, text: String, imgMessage: String) {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = selectedUser?.id else { return }
        
        print("imgMessage: " + imgMessage)
        let senderMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        // "id" field is key to delete message in deletedMessage function
        let senderMessageData = ["id" : senderMessageDocument.documentID,
                                 "fromId" : fromId,
                                 "toId" : toId,
                                 "text" : text,
                                 "imgMessage" : imgMessage,
                                 "timestamp" : Timestamp()] as [String : Any]
        
        senderMessageDocument.setData(senderMessageData) { error in
            
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
        
        let recipientMessageData = ["id" : recipientMessageDocument.documentID,
                                    "fromId" : fromId,
                                    "toId" : toId,
                                    "text" : text,
                                    "imgMessage" : imgMessage,
                                    "timestamp" : Timestamp()] as [String : Any]
        
        recipientMessageDocument.setData(recipientMessageData) { error in
            
            if let error = error {
                
                self.alertMessage = error.localizedDescription
                print(self.alertMessage)
                return
                
            }
        }
        
        //self.recentChatUser(selectedUser: selectedUser, text: text)
        self.lastMessageOfSender(selectedUser: selectedUser, text: text)
        self.lastMessageOfReceiver(selectedUser: selectedUser, text: text)
        
        print("isShowNewMessage: \(isShowNewMessage)")
        
    }
    
    
    //MARK: - fetchMessage
    func fetchMessage(selectedUser: User?) {
        
        firestoreListenerMessage?.remove()
        self.allMessages.removeAll()
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = selectedUser?.id else { return    }
        
        firestoreListenerMessage = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp", descending: false)
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
                    let imgMessage = snap.get("imgMessage") as? String ?? ""
                    let timestamp = snap.get("timestamp") as? Timestamp
                    //                    let timestamp = snap.get("timestamp") as? Date ?? Date.now
                    
                    //                    let formatter = DateFormatter()
                    //                    formatter.dateFormat = "MMM d yyyy"
                    //                    let date = formatter.string(from: timestamp.dateValue())
                    //                    formatter.dateFormat = "HH:mm"
                    //                    let time = formatter.string(from: timestamp.dateValue())
                    
                    return Message(id: id, fromId: fromId, toId: toId, text: text, imgMessage: imgMessage, timestamp: timestamp!)
                    
                })
                self.filterChat = self.allMessages
                
                //Activate activity indicator..
                //..true: when start send Image Message (bottomChat)
                //..false: when fetchMessage success (fetchMessage)
                self.isShowActivityIndicator = false
            }
    }
    
    
    //MARK: - deleteSenderMessage
    func deleteMessage(selectedUser: User, selectedMessage: Message) {
        
        //        FirebaseManager.shared.firestore
        //            .collection("messages")
        //            .document(selectedMessage.fromId)
        //            .collection(selectedMessage.toId)
        //            .document(selectedMessage.id)
        //            .delete { error in
        //
        //                if let err = error {
        //
        //                    self.isShowAlert = true
        //                    self.alertMessage = err.localizedDescription
        //
        //                }
        //            }
        
        //Check selected message to delete belongs to sender or receiver. After that set correct path to delete.
        let constant = FirebaseManager.shared.firestore
            .collection("messages")
            .document(isDeleteSenderMessage(selectedUser: selectedUser, selectedMessage: selectedMessage) ? selectedMessage.fromId : selectedMessage.toId)
            .collection(isDeleteSenderMessage(selectedUser: selectedUser, selectedMessage: selectedMessage) ? selectedMessage.toId : selectedMessage.fromId)
        
        
        //Check if the selected message to delete is last message then assigned lastmessage = "..." (lastmessage using in MainMessage UI)
        constant
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { querySnapshot, error in
                
                if let error = error {
                    
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
                
                //Fetch lastMessage..
                if let data = querySnapshot?.documents.first {
                    
                    let lastMessage = data.get("id") as? String ?? ""
                    
                    //..assign lastMessage is "..." in recentChatUser
                    if lastMessage == selectedMessage.id {
                        
                        self.lastMessageOfSender(selectedUser: selectedUser, text: "...")
                        
                    }
                }
            }
        
        //Delete selected message
        constant
            .document(selectedMessage.id)
            .delete { error in
                
                if let err = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = err.localizedDescription
                    
                }
            }
    }
    
    
    //MARK: - checkIsLastMessage
    func isDeleteSenderMessage(selectedUser: User, selectedMessage: Message) -> Bool {
        
        return FirebaseManager.shared.auth.currentUser?.uid == selectedMessage.fromId
        
    }
    
    
    //MARK: - recentUserChat
    //    func recentChatUser(selectedUser: User?, text: String){
    //
    //        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
    //
    //        guard let toId = selectedUser?.uid else { return }
    //
    //        let uidS = fromId + toId
    //
    //        let uidR = toId + fromId
    //
    //        //Sender
    //        guard let nameS = selectedUser?.name else { return }
    //
    //        guard let profileImageUrlS = selectedUser?.profileImageUrl else { return }
    //
    //        let senderData = ["fromId" : fromId,
    //                          "toId" : toId,
    //                          "name" : nameS,
    //                          "profileImageUrl" : profileImageUrlS,
    //                          "text" : text,
    //                          "timestamp" : Timestamp()] as [String : Any]
    //
    //        FirebaseManager.shared.firestore
    //            .collection("lastMessage") //.collection("recentUserChat")
    //            .document(uidS)
    //            .setData(senderData) { error in
    //
    //                if let error = error {
    //
    //                    self.isShowAlert = true
    //                    self.alertMessage = error.localizedDescription
    //                    return
    //
    //                }
    //            }
    //
    //        //Receiver
    //        guard let nameR = anUser?.name else { return }
    //
    //        guard let profileImageUrlR = anUser?.profileImageUrl else { return }
    //
    //        let receiverData = ["fromId" : toId,
    //                            "toId" : fromId,
    //                            "name" : nameR,
    //                            "profileImageUrl" : profileImageUrlR,
    //                            "text" : text,
    //                            "timestamp" : Timestamp()] as [String : Any]
    //
    //        FirebaseManager.shared.firestore
    //            .collection("lastMessage")
    //            .document(uidR)
    //            .setData(receiverData) { error in
    //
    //                if let error = error {
    //
    //                    self.isShowAlert = true
    //                    self.alertMessage = error.localizedDescription
    //                    return
    //
    //                }
    //            }
    //    }
    
    
    //MARK: - lastMessageOfSender
    func lastMessageOfSender(selectedUser: User?, text: String) {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = selectedUser?.id else { return }
        
        let uid = fromId + toId
        
        guard let name = selectedUser?.name else { return }
        
        guard let profileImageUrl = selectedUser?.profileImageUrl else { return }
        
        //If text == "", it's a photo
        let checkText = (text == "") ? "A photo" : text
        
        let senderData = ["fromId" : fromId,
                          "toId" : toId,
                          "name" : name,
                          "profileImageUrl" : profileImageUrl,
                          "text" : checkText,
                          "timestamp" : Timestamp()] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection("lastMessage") //.collection("recentUserChat")
            .document(uid)
            .setData(senderData) { error in
                
                if let error = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
            }
    }
    
    
    //MARK: - lastMessageOfReceiver
    func lastMessageOfReceiver(selectedUser: User?,text: String) {
        
        guard let fromId = selectedUser?.id else { return }
        
        guard let toId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let uid = fromId + toId
        
        guard let name = currentUser?.name else { return }
        
        guard let profileImageUrl = currentUser?.profileImageUrl else { return }
        
        //If text == "", it's a photo
        let checkText = (text == "") ? "A photo" : text
        
        let receiverData = ["fromId" : fromId,
                            "toId" : toId,
                            "name" : name,
                            "profileImageUrl" : profileImageUrl,
                            "text" : checkText,
                            "timestamp" : Timestamp()] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection("lastMessage")
            .document(uid)
            .setData(receiverData) { error in
                
                if let error = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
            }
    }
    
    
    //MARK: - fetchLastMessage
    func fetchLastMessage() {
        
        firestoreListenerRecentChatUser?.remove()
        self.allRecentChatUsers.removeAll()
        
        guard let currentUserId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        firestoreListenerRecentChatUser = FirebaseManager.shared.firestore
            .collection("lastMessage")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { documentSnapshot, error in
                
                if let error = error {
                    
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
                
                guard let data = documentSnapshot else { return }
                
                self.allRecentChatUsers = data.documents.compactMap({ snapshot in
                    
                    let id = snapshot.documentID
                    let fromId = snapshot.get("fromId") as? String ?? ""
                    let toId = snapshot.get("toId") as? String ?? ""
                    let name = snapshot.get("name") as? String ?? ""
                    let profileImageUrl = snapshot.get("profileImageUrl") as? String ?? ""
                    let text = snapshot.get("text") as? String ?? ""
                    let timestamp = snapshot.get("timestamp") as? Timestamp
                    //                     let timestamp = snapshot.get("timestamp") as? Date ?? Date.now
                    
                    if currentUserId == fromId {
                        
                        return LastMessage(id: id, fromId: fromId, toId: toId, name: name, profileImageUrl: profileImageUrl, text: text, timestamp: timestamp!)
                        
                        
                    } else { return nil }
                })
                
                self.filterMainMessage = self.allRecentChatUsers
                
                
                print(self.allRecentChatUsers.count == 0 ? "allRecentChatUsers: Empty" : "allRecentChatUsers: Have data")
                
            }
    }
    
    
    //MARK: - deleteRecentChatUser
    func deleteRecentChatUser(selectedUser: LastMessage) {
        
        FirebaseManager.shared.firestore
            .collection("lastMessage")
            .document(selectedUser.fromId + selectedUser.toId)
            .delete { error in
                
                if let err = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = err.localizedDescription
                    
                }
            }
    }
    //MARK: - filterApplyOnUsers
    func filterForMainMessage() {
        
        withAnimation(.linear){
            
            self.filterMainMessage = self.allRecentChatUsers.filter({
                
                return $0.name.lowercased().contains(self.searchMainMessage.lowercased())
                
            })
        }
    }
    
    
    //MARK: - filterForNewMessage
    func filterForNewMessage() {
        
        withAnimation(.linear){
            
            self.filterNewMessage = self.suggestUser.filter({
                
                return $0.name.lowercased().contains(self.searchNewMessage.lowercased())
                
            })
        }
    }
    
    
    //MARK: - filterSuggestUsers
    //    func filterSuggestUsers() -> [User] {
    //
    //        var data : [User]?
    //        withAnimation(.linear){
    //
    ////            self.filterNewMessage = self.allSuggestUsers.filter({
    //            data = self.allSuggestUsers.filter({
    //
    //                return $0.name.lowercased().contains(self.searchNewMessage.lowercased())
    //
    //            })
    //        }
    //        return data!
    //    }
    
    
    //MARK: - filterForAddParticipants
    func filterForAddParticipants() {
        
        withAnimation(.linear){
            
            self.filterAddParticipants = self.suggestUser.filter({
                
                return $0.name.lowercased().contains(self.searchAddParticipants.lowercased())
                
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
    
    
    //MARK: - This will upload images into Storage and prints out the locations as well
    func uploadProfileImageGroup(groupId : String) {
                
        let ref = FirebaseManager.shared.storage.reference(withPath: groupId)
        
        //Set default profileImage
        let profileImage = UIImage(named: "LotusLogo")
        
        guard let imageData = profileImage?.jpegData(compressionQuality: 0.5) else { return }

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
                
                self.storeGroupInformation(groupId: groupId, profileImageUrl: url)
            }
        }
    }
    
    
    //MARK: - storeGroupChatInformation
    func storeGroupInformation(groupId: String, profileImageUrl: URL) {
        
        guard let admin = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        for user in participantList {
            memberIdList.append(user.id)
        }
        
        if self.memberIdList.isEmpty { return }
        
        let groupUser = ["id" : groupId,
                         "name" : groupname,
                         "profileImageUrl" : profileImageUrl.absoluteString,
                         "admin" : admin,
                         "member" : memberIdList] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection("group")
            .document(groupId)
            .setData(groupUser) { error in
                
                if let error = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                }
            }
        
        fetchGroup(groupId: groupId)
    }
    
    
    //MARK: - fetchGroup
    func fetchGroup(groupId: String) {
        
        FirebaseManager.shared.firestore
            .collection("group")
            .document(groupId)
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
                
                self.selectedGroup = .init(data: data)
                
                self.lastGroupMessageOfSender(selectedGroup: self.selectedGroup, text: "You created this group")
                self.lastGroupMessageOfReceiver(selectedGroup: self.selectedGroup, text: "\(self.currentUser!.name) created this group")
                
                self.isShowActivityIndicator = false
                self.isShowGroupChat = true

            }
    }
    
    
    //MARK: - sendGroupMessage
    func sendGroupMessage(selectedGroup: GroupUser, text: String, imgMessage: String) {
        
        //Với mỗi id trong [memberIdList + currentUser], ta lưu theo struct Message/UserID/GroupID/MessageID/MessageContent
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let groupId = selectedGroup.id
        
        //Store Sender Message
        let senderMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(groupId)
            .document()
        
        // "id" field is key to delete message in deletedMessage function
        let senderMessageData = ["id" : senderMessageDocument.documentID,
                                 "fromId" : fromId,
                                 "toId" : groupId,
                                 "text" : text,
                                 "imgMessage" : imgMessage,
                                 "timestamp" : Timestamp()] as [String : Any]
        
        senderMessageDocument.setData(senderMessageData) { error in
            
            if let error = error {
                
                self.alertMessage = error.localizedDescription
                print(self.alertMessage)
                return
                
            }
        }
        
        //Store Recipient Message
        for toId in memberIdList {
            
            let recipientMessageDocument = FirebaseManager.shared.firestore
                .collection("messages")
                .document(toId)
                .collection(groupId)
                .document()
            
            let recipientMessageData = ["id" : recipientMessageDocument.documentID,
                                        "fromId" : fromId,
                                        "toId" : toId,
                                        "text" : text,
                                        "imgMessage" : imgMessage,
                                        "timestamp" : Timestamp()] as [String : Any]
            
            recipientMessageDocument.setData(recipientMessageData) { error in
                
                if let error = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    print(self.alertMessage)
                    return
                    
                }
            }
        }

        self.lastGroupMessageOfSender(selectedGroup: selectedGroup, text: text)
        self.lastGroupMessageOfReceiver(selectedGroup: selectedGroup, text: text)
        
    }
    
    
    //MARK: - lastGroupMessageOfSender
    func lastGroupMessageOfSender(selectedGroup: GroupUser?, text: String) {

        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let groupId = selectedGroup?.id else { return }

        let id = fromId + groupId

        guard let groupName = selectedGroup?.name else { return }
        
        guard let profileImageUrl = selectedGroup?.profileImageUrl else { return }

        //If text == "", it's a photo
        let checkText = (text == "") ? "A photo" : text

        let senderData = ["fromId" : fromId,
                          "toId" : groupId,
                          "name" : groupName,
                          "profileImageUrl" : profileImageUrl,
                          "text" : checkText,
                          "timestamp" : Timestamp()] as [String : Any]

        FirebaseManager.shared.firestore
            .collection("lastMessage") //.collection("recentUserChat")
            .document(id)
            .setData(senderData) { error in

                if let error = error {

                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return

                }
            }
    }
    
    
    //MARK: - lastGroupMessageOfReceiver
    func lastGroupMessageOfReceiver(selectedGroup: GroupUser?,text: String) {
                
        guard let groupId = selectedGroup?.id else { return }
        
        for toId in memberIdList {
            
            let id = toId + groupId

            guard let name = selectedGroup?.name else { return }
            
            guard let profileImageUrl = selectedGroup?.profileImageUrl else { return }
            
            //If text == "", it's a photo
            let checkText = (text == "") ? "A photo" : text
            
            let receiverData = ["fromId" : toId,
                                "toId" : groupId,
                                "name" : name,
                                "profileImageUrl" : profileImageUrl,
                                "text" : checkText,
                                "timestamp" : Timestamp()] as [String : Any]
            
            FirebaseManager.shared.firestore
                .collection("lastMessage")
                .document(id)
                .setData(receiverData) { error in
                    
                    if let error = error {
                        
                        self.isShowAlert = true
                        self.alertMessage = error.localizedDescription
                        return
                        
                    }
                }
        }
    }
}
