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
    @Published var allLastMessage = [LastMessage]()
    @Published var searchMainMessage = ""
    @Published var filterAllLastMessage = [LastMessage]()
    var firestoreListenerRecentChatUser: ListenerRegistration?
    
    //New Message
    @Published var isShowNewMessage : Bool = false
    @Published var searchNewMessage = ""
    @Published var filterAllSuggestUser = [User]()
    @Published var allSuggestUser = [User]()
    var firestoreListenerUserToSuggest: ListenerRegistration?
    
    //Add Participants
    @Published var isShowAddParticipants : Bool = false
    @Published var searchAddParticipants = ""
    @Published var filterSuggestParticipant = [User]()
    @Published var participantList = [User]()
    
    //New Group
    @Published var isShowNewGroup : Bool = false
    @Published var groupname : String = ""
    
    //Chat
    @Published var isShowChat : Bool = false
    @Published var allMessages = [Message]()
    @Published var searchChat = ""
    @Published var filterAllMessages = [Message]()
    @Published var isShowImagePickerMessage = false
    var firestoreListenerMessage: ListenerRegistration?
    
    //GroupChat
    @Published var isShowGroup : Bool = false
    @Published var memberIdList = [String]()
    @Published var selectedGroup : GroupUser?
    @Published var isShowImagePickerGroup = false
    
    //GroupDetail
    @Published var isShowGroupDetail : Bool = false
    @Published var allMember = [User]()
    
    
    init(){
        
        fetchCurrentUser()
        fetchLastMessage()
        //This initialization main purpose is using for "func getUser(uid: String) -> User" in MainMessage. It conver data type from RecentChatUser to User.
        fetchSuggestUserList()
        
    }
    
    
    //MARK: - isValidEmail
    func isValidEmail(_ string: String) -> Bool {
        
        if string.count > 100 {
            return false
        }
        
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        //        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
        
    }
    
    
    //MARK: - signIn
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
    
    
    //MARK: - signUp
    func signUp() {
        
        //Check name already set?
        if self.username == ""{
            
            isShowAlert = true
            alertMessage = "What is your user name?"
            return
            
        } else {
            
            //Check avatar image already set?
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
                    
                    self.uploadUserProfileImage()
                    
                }
            }
        }
    }
    
    
    //MARK: - uploadUserProfileImage
    //This will upload images into Storage and prints out the locations as well
    func uploadUserProfileImage() {
        
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
                
                self.storeUserInfo(profileImageUrl: url)
            }
        }
    }
    
    
    //MARK: - storeUserInfo
    //This will save newly created users to Firestore database collections
    func storeUserInfo(profileImageUrl: URL) {
        
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
                
                self.username = ""
                self.email = ""
                self.password = ""
                self.profileImage = nil
                
                //Activate activity indicator..
                //..true: when start signUp (signUp)
                //..false: when store user information success (storeUserInformation)
                self.isShowActivityIndicator = false
                
                //...and show alert successfully created
                self.isShowAlert = true
                self.alertMessage = "Your account has been successfully cereated!"
                
                //Auto move SIGN IN tab...
                self.isSignInMode = true
                
            }
    }
    
    
    //MARK: - fetchCurrentUser
    func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("user")
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
                
                guard let data = snapshot?.data() else {
                    
                    self.isShowAlert = true
                    self.alertMessage = "No data found"
                    return
                    
                }
                
                self.currentUser = .init(data: data)
                
            }
    }
    
    
    //MARK: - fetchSuggestUserList
    func fetchSuggestUserList() {
        
        firestoreListenerUserToSuggest?.remove()
        self.allSuggestUser.removeAll()
        
        firestoreListenerUserToSuggest = FirebaseManager.shared.firestore
            .collection("user")
            .addSnapshotListener { documentSnapshot, error in
                
                if let error = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
                
                documentSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = User(data: data)
                    if user.id != FirebaseManager.shared.auth.currentUser?.uid {
                        
                        self.allSuggestUser.append(.init(data: data))
                        
                    }
                })
                
                self.filterAllSuggestUser = self.allSuggestUser
                self.filterSuggestParticipant = self.allSuggestUser
                
            }
    }
    
    
    //MARK: - uploadImageMessage
    func sendImageMessage(selectedUser: User?, text: String, imageMessage: UIImage?) {
        
        let imageMessageId =  NSUUID().uuidString
        let ref = FirebaseManager.shared.storage.reference(withPath: imageMessageId)
        guard let imageData = imageMessage?.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            
            if let error = error {
                
                self.isShowAlert = true
                self.alertMessage = error.localizedDescription
                return
                
            }
            
            ref.downloadURL { url, err in
                
                if let error = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
                
                guard let url = url else { return }
                
                let imgMessageUrl = url.absoluteString
                
                self.sendMessage(selectedUser: selectedUser, text: text, imgMessage: imgMessageUrl)
            }
        }
    }
    
    
    //MARK: - sendMessage
    func sendMessage(selectedUser: User?, text: String, imgMessage: String) {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = selectedUser?.id else { return }
        
        //For Sender
        let senderMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        // "id" is key to delete message in deletedMessage function
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
        
        //For Receiver
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
                
                self.isShowAlert = true
                self.alertMessage = error.localizedDescription
                return
                
            }
        }
        
        //self.recentChatUser(selectedUser: selectedUser, text: text)
        self.lastMessageOfSender(selectedUser: selectedUser, text: text)
        self.lastMessageOfReceiver(selectedUser: selectedUser, text: text)
        
    }
    
    
    //MARK: - fetchMessage
    func fetchMessage(selectedObjectId: String?) {
        
        firestoreListenerMessage?.remove()
        self.allMessages.removeAll()
        self.filterAllMessages.removeAll()
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = selectedObjectId else { return }
        
        firestoreListenerMessage = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { documentSnapshot, error in
                
                if let error = error {
                    
                    self.isShowAlert = true
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
                    
                    return Message(id: id, fromId: fromId, toId: toId, text: text, imgMessage: imgMessage, timestamp: timestamp!)
                    
                })
                
                self.filterAllMessages = self.allMessages
                
                //Activate activity indicator..
                //..true: when start send Image Message (bottomChat)
                //..false: when fetchMessage success (fetchMessage)
                self.isShowActivityIndicator = false
                
            }
    }
    
    
    //MARK: - getUserInfo
    //Transfer data type of selected user from "LastMessage" to "User"
    //Refer link for find an object in array: https://stackoverflow.com/questions/28727845/find-an-object-in-array
    //"func fetchSuggestUserList()" have to init at begin run app, it help "vm.allSuggestUsers" variable have data before calling "func getUserInfo(uid: String) -> User". If not our get an error "Unexpectedly found nil while unwrapping an Optional value"
    func getUserInfo(selectedObjectId: String) -> User {
        
        return allSuggestUser.first{$0.id == selectedObjectId }!
        
    }
    
    
    //MARK: - deleteMessage
    func deleteMessage(selectedObjectId: String, selectedMessage: Message) {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let toId = selectedObjectId
        
        let constant = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
        
        
        //If delete the last message then assigned last message = "..." (lastmessage using in MainMessage UI)
        //Fetch lastMessage
        constant
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { querySnapshot, error in
                
                if let error = error { return }
                
                if let data = querySnapshot?.documents.first {
                    
                    let lastMessage = data.get("id") as? String ?? ""
                    
                    //Check if it's last message then assign last message = "..."
                    if lastMessage == selectedMessage.id {
                        
                        //Group Message
                        if selectedObjectId.contains("-") {
                            
                            self.lastGroupMessageOfSender(selectedGroup: self.selectedGroup, text: "...")
                            //Standar Message
                        } else {
                            
                            let selectedUser = self.getUserInfo(selectedObjectId: selectedObjectId)
                            self.lastMessageOfSender(selectedUser: selectedUser, text: "...")
                            
                        }
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
        self.allLastMessage.removeAll()
        self.filterAllLastMessage.removeAll()
        
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
                
                self.allLastMessage = data.documents.compactMap({ snapshot in
                    
                    let id = snapshot.documentID
                    let fromId = snapshot.get("fromId") as? String ?? ""
                    let toId = snapshot.get("toId") as? String ?? ""
                    let name = snapshot.get("name") as? String ?? ""
                    let profileImageUrl = snapshot.get("profileImageUrl") as? String ?? ""
                    let text = snapshot.get("text") as? String ?? ""
                    let timestamp = snapshot.get("timestamp") as? Timestamp
                    
                    if currentUserId == fromId {
                        
                        return LastMessage(id: id,
                                           fromId: fromId,
                                           toId: toId,
                                           name: name,
                                           profileImageUrl: profileImageUrl,
                                           text: text,
                                           timestamp: timestamp!)
                        
                    } else { return nil }
                })
                
                self.filterAllLastMessage = self.allLastMessage
            }
    }
    
    
    //MARK: - deleteLastMessage
    func deleteLastMessage(selectedUser: LastMessage) {
        
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
    
    
    //MARK: - filterForMainMessage
    func filterForMainMessage() {
        
        withAnimation(.linear){
            
            self.filterAllLastMessage = self.allLastMessage.filter({
                
                return $0.name.lowercased().contains(self.searchMainMessage.lowercased())
                
            })
        }
    }
    
    
    //MARK: - filterForNewMessage
    func filterForNewMessage() {
        
        withAnimation(.linear){
            
            self.filterAllSuggestUser = self.allSuggestUser.filter({
                
                return $0.name.lowercased().contains(self.searchNewMessage.lowercased())
                
            })
        }
    }
    
    
    //MARK: - filterForAddParticipants
    func filterForAddParticipants() {
        
        withAnimation(.linear){
            
            self.filterSuggestParticipant = self.allSuggestUser.filter({
                
                return $0.name.lowercased().contains(self.searchAddParticipants.lowercased())
                
            })
        }
    }
    
    
    //MARK: - filterForChat
    func filterForChat() {
        
        withAnimation(.linear){
            
            self.filterAllMessages = self.allMessages.filter({
                
                return $0.text.lowercased().contains(self.searchChat.lowercased())
                
            })
        }
    }
    
    
    //MARK: - uploadProfileImageGroup
    //This will upload images into Storage and prints out the locations as well
    func uploadProfileImageGroup(groupId : String) {
        
        //Set default profileImage
        let profileImage = UIImage(named: "LotusLogo")
        
        let ref = FirebaseManager.shared.storage.reference(withPath: groupId)
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
                
                self.storeGroupInfo(groupId: groupId, profileImageUrl: url)
                
            }
        }
    }
    
    
    //MARK: - storeGroupInfo
    func storeGroupInfo(groupId: String, profileImageUrl: URL) {
        
        guard let admin = FirebaseManager.shared.auth.currentUser?.uid else { return }
        memberIdList.append(admin)
        
        //Get ID of all members
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
        
        fetchGroupInfo(groupId: groupId)
        
    }
    
    
    //MARK: - fetchGroupInfo
    func fetchGroupInfo(groupId: String) {
        
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
                
                if self.isCreatingNewGroup(groupId: groupId) {
                    
                    self.implementNewGroup(groupId: groupId)
                    
                }
                
                self.isShowGroup = true
                
            }
    }
    
    
    //MARK: - isCreatingNewGroup
    func isCreatingNewGroup(groupId: String) -> Bool {
        
        for lastMessage in self.allLastMessage {
            
            if groupId == lastMessage.toId {
                
                return false
                
            }
        }
        return true
        
    }
    
    
    //MARK: - implementNewGroup
    func implementNewGroup(groupId: String) {
        
        self.lastGroupMessage(selectedGroup: self.selectedGroup, text: "\(self.currentUser!.name) created this group")
        self.lastGroupMessageOfSender(selectedGroup: self.selectedGroup, text: "You created this group")
        
        self.fetchMessage(selectedObjectId: groupId)
        
        //Reset the value of all parameters involved to creating a new group
        self.resetIsAddedStatus()
        self.participantList.removeAll()
        self.memberIdList.removeAll()
        self.groupname = ""
        
        //Activate activity indicator..
        //..true: when start create new group (NewGroup)
        //..false: when create new group success (implementNewGroup)
        self.isShowActivityIndicator = false
        
    }
    
    
    //MARK: - resetIsAddedStatus
    //Reset add status to group for user
    func resetIsAddedStatus() {
        
        //Reset isAdded status for all users of participantList
        for user in self.participantList {
            
            if let index = self.allSuggestUser.firstIndex(where: { us in
                us.id == user.id
            }) {
                
                self.allSuggestUser[index].isAdded = false
                
            }
        }
        //Update.
        self.filterSuggestParticipant = self.allSuggestUser
        
    }
    
    
    //MARK: - uploadImageMessageOfGroup
    func sendImageMessageOfGroup(selectedGroup: GroupUser?, text: String, imageGroup: UIImage?) {
        
        let imageMessageId =  NSUUID().uuidString
        let ref = FirebaseManager.shared.storage.reference(withPath: imageMessageId)
        guard let imageData = imageGroup?.jpegData(compressionQuality: 0.5) else { return }
        
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
                
                self.sendGroupMessage(selectedGroup: selectedGroup!, text: text, imgMessage: imgMessageUrl)
                
            }
        }
    }
    
    
    //MARK: - sendGroupMessage
    func sendGroupMessage(selectedGroup: GroupUser, text: String, imgMessage: String) {
        
        //Ta lưu theo struct Message/UserID/GroupID/MessageID/MessageContent
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let groupId = selectedGroup.id
        
        for uid in selectedGroup.member {
            
            let messageDocument = FirebaseManager.shared.firestore
                .collection("messages")
                .document(uid)
                .collection(groupId)
                .document()
            
            let messageData = ["id" : messageDocument.documentID,
                               "fromId" : fromId,
                               "toId" : uid,
                               "text" : text,
                               "imgMessage" : imgMessage,
                               "timestamp" : Timestamp()] as [String : Any]
            
            messageDocument.setData(messageData) { error in
                
                if let error = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    print(self.alertMessage)
                    return
                    
                }
            }
        }
        
        self.lastGroupMessage(selectedGroup: self.selectedGroup, text: text)
        
    }
    
    
    //MARK: - lastGroupMessageOfSender
    //Using to assign lastmessage = "..." if user delete lastmessage
    func lastGroupMessageOfSender(selectedGroup: GroupUser?, text: String) {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let groupId = selectedGroup?.id else { return }
        let id = fromId + groupId
        
        guard let groupName = selectedGroup?.name else { return }
        guard let profileImageUrl = selectedGroup?.profileImageUrl else { return }
        
        //If text == "", it's a photo
        //text value alway is "..." or "You created this group" so no need checkText
        //let checkText = (text == "") ? "A photo" : text
        
        let senderData = ["fromId" : fromId,
                          "toId" : groupId,
                          "name" : groupName,
                          "profileImageUrl" : profileImageUrl,
                          "text" : text,
                          "timestamp" : Timestamp()] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection("lastMessage")
            .document(id)
            .setData(senderData) { error in
                
                if let error = error {
                    
                    self.isShowAlert = true
                    self.alertMessage = error.localizedDescription
                    return
                    
                }
            }
    }
    
    
    //MARK: - lastGroupMessage
    func lastGroupMessage(selectedGroup: GroupUser?,text: String) {
        
        guard let groupId = selectedGroup?.id else { return }
        guard let name = selectedGroup?.name else { return }
        guard let profileImageUrl = selectedGroup?.profileImageUrl else { return }
        
        for uid in selectedGroup!.member {
            
            let id = uid + groupId
            
            //If text == "", it's a photo
            let checkText = (text == "") ? "A photo" : text
            
            let receiverData = ["fromId" : uid,
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
    
    
    //MARK: - fetchMemberList
    func fetchMemberList(selectedGroup: GroupUser?) {
        
        self.allMember.removeAll()
        var user : User?
        
        for uid in selectedGroup!.member {
            
            //Không nên tìm currentId với hàm "getUserInfo". Vì nó sẽ tìm trong mảng suggestUser, và mảng suggestUser thì ko chứa currentId nên sẽ trả về nil. Trong khi câu lệnh return ta đã set alway != nil
            if (uid != currentUser?.id) {
                user = getUserInfo(selectedObjectId: uid)
                //                if user != nil {
                self.allMember.append(user!)
                //                }
            }
        }
        allMember.append(currentUser!)
        
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
}
