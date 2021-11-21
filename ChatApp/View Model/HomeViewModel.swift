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
    
    func fetchAllUsers() {
        
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentSnapshot, error in
            if let error = error {
                
                self.alertMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
                
            }
            
            documentSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                let user = User(data: data)
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid{
                    self.allUser.append(.init(data: data))
                }
                
            })
        }
    }
   
    //MARK: - handleSignOut
    func handleSignOut() {
        
        isUserCurrenlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        
    }
    
//    func sendMsg(user: String,uid: String,pic: String,date: Date,msg: String){
//
//        let db = Firestore.firestore()
//
//        let myuid = Auth.auth().currentUser?.uid
//
//        db.collection("users").document(uid).collection("recents").document(myuid!).getDocument { (snap, err) in
//
//            if err != nil{
//
//                print((err?.localizedDescription)!)
//                // if there is no recents records....
//
//                self.setRecents(user: user, uid: uid, pic: pic, msg: msg, date: date)
//                return
//            }
//
//            if !snap!.exists{
//
//                self.setRecents(user: user, uid: uid, pic: pic, msg: msg, date: date)
//            }
//            else{
//
//                self.updateRecents(uid: uid, lastmsg: msg, date: date)
//            }
//        }
//
//        updateDB(uid: uid, msg: msg, date: date)
//    }
//
//    func setRecents(user: String,uid: String,pic: String,msg: String,date: Date){
//
//        let db = FirebaseManager.shared.firestore
//
//        let myuid = FirebaseManager.shared.auth.currentUser?.uid
//
//        let myname = UserDefaults.standard.value(forKey: "UserName") as! String
//
//        let mypic = UserDefaults.standard.value(forKey: "pic") as! String
//
//        let userData = ["name":myname,"pic":mypic,"lastmsg":msg,"date":date] as [String : Any]
//
//        db.collection("users").document(uid).collection("recents").document(myuid!).setData() { (err) in
//
//            if err != nil{
//
//                print((err?.localizedDescription)!)
//                return
//            }
//        }
//
//        db.collection("users").document(myuid!).collection("recents").document(uid).setData(["name":user,"pic":pic,"lastmsg":msg,"date":date]) { (err) in
//
//            if err != nil{
//
//                print((err?.localizedDescription)!)
//                return
//            }
//        }
//    }
//
//    func updateRecents(uid: String,lastmsg: String,date: Date){
//
//        let db = Firestore.firestore()
//
//        let myuid = Auth.auth().currentUser?.uid
//
//        db.collection("users").document(uid).collection("recents").document(myuid!).updateData(["lastmsg":lastmsg,"date":date])
//
//         db.collection("users").document(myuid!).collection("recents").document(uid).updateData(["lastmsg":lastmsg,"date":date])
//    }
//
//    func updateDB(uid: String,msg: String,date: Date){
//
//        let db = Firestore.firestore()
//
//        let myuid = Auth.auth().currentUser?.uid
//
//        db.collection("msgs").document(uid).collection(myuid!).document().setData(["msg":msg,"user":myuid!,"date":date]) { (err) in
//
//            if err != nil{
//
//                print((err?.localizedDescription)!)
//                return
//            }
//        }
//
//        db.collection("msgs").document(myuid!).collection(uid).document().setData(["msg":msg,"user":myuid!,"date":date]) { (err) in
//
//            if err != nil{
//
//                print((err?.localizedDescription)!)
//                return
//            }
//        }
//    }

    //MARK: - getMsgs
//    func getMsgs() {
//        
//        let db = FirebaseManager.shared.firestore
//        
//        let uid = FirebaseManager.shared.auth.currentUser?.uid
//        
//        db.collection("msgs").document(uid!).collection(uid).getDocuments { snap, err in
//            
//            if err != nil{
//                print()
//            }
//        }
//    }
}
