//
//  DasboardMessenge.swift
//  ChatApp
//
//  Created by Quang Bao on 14/11/2021.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct MainMessenger: View {
    
    @ObservedObject var baseViewModel = HomeViewModel()
    
    @State var isShowSetting : Bool = false
    @State var searchUser : String = ""
    
    var body: some View {
        VStack {
            topbarMessenges
            messengerView
        }
    }
    
    //MARK: - topbarMessenges
    var topbarMessenges : some View {
        VStack {
            HStack(spacing: 20) {
                Button {
                    isShowSetting.toggle()
                } label: {
                    //                    if let url = baseViewModel.chatUser?.profileImageUrl {
                    //
                    //                        WebImage(url: URL(string: url))
                    //                            .resizable()
                    //                            .scaledToFill()
                    //                            .frame(width: 50, height: 50)
                    //                            .mask(Circle())
                    //
                    //                    } else {
                    //
                    //                        Image(systemName: "person.fill")
                    //                            .font(.system(size: 25))
                    //                            .padding(10)
                    //                            .background(
                    //                                Circle()
                    //                                    .stroke()
                    //                            )
                    //                    }
                    let img = baseViewModel.chatUser?.profileImageUrl
                    if img != "" {
                        WebImage(url: URL(string: baseViewModel.chatUser?.profileImageUrl ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .mask(Circle())
                    } else {
                        Image("LotusLogo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .mask(Circle())
                    }
                }

                let usn = baseViewModel.chatUser?.username
                if usn != "" {
                    Text(baseViewModel.chatUser?.username ?? "")
                        .font(.system(size: 20, weight: .bold))
                } else {
                    Text("Me")
                        .font(.system(size: 20, weight: .bold))
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(.system(size: 25))
                }
            }
            .actionSheet(isPresented: $isShowSetting) {
                ActionSheet(
                    title: Text("Setting"),
                    message: Text("What do you want to do?"),
                    buttons: [
                        .cancel(),
                        .destructive(
                            Text("Sign Out"),
                            action: {
//                                if FirebaseAuth.Auth.auth().currentUser?.uid == nil {
                                    print("Sign Out")
//                                    handleSignOut()
//                                }
                                
//                                if FirebaseManager.shared.auth.currentUser?.uid != nil {
//                                    handleSignOut()
//                                }
                            })
                    ])
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchUser)
                    .autocapitalization(.none)
            }
            .padding(15)
            .background(.gray.opacity(0.08))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    //MARK: - messengesView
    var messengerView : some View {
        
        ScrollView {
            
            VStack(spacing: 30){
                
                ForEach(1...20, id: \.self) { userNumber in
                    
                    HStack(spacing: 10){
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.orange)
                            .padding(10)
                            .background(
                                Circle()
                                    .stroke(.orange)
                            )
                        
                        VStack(alignment: .leading, spacing: 4){
                            Text("Username")
                                .font(.system(size: 17, weight: .bold))
                            
                            Text("Messenge send to user")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("11:20 AM")
                            .font(.system(size: 12))
                    }
                }
            }
            .padding()
        }
    }
    
    func handleSignOut() {
        
        do {
//            try FirebaseAuth.Auth.auth().signOut()
            try FirebaseManager.shared.auth.signOut()
        
        } catch let logoutError {
            print(logoutError.localizedDescription)
        }
    }
}

struct DasboardMessenge_Previews: PreviewProvider {
    static var previews: some View {
        MainMessenger()
    }
}
