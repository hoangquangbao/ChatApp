//
//  DasboardMessenge.swift
//  ChatApp
//
//  Created by Quang Bao on 14/11/2021.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct MainMessage: View {
    
    @ObservedObject var vm = HomeViewModel()
    
    @State var isShowSignOutButton : Bool = false
    @State var isShowNewMessage : Bool = false
    @State var searchUser : String = ""
    
    var body: some View {
            VStack {
                topbarMessage
                messageView
            }
    }
    
    //MARK: - topbarMessenges
    private var topbarMessage : some View {
        VStack {
            HStack(spacing: 20) {
                Button {
                    isShowSignOutButton.toggle()
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
                    let img = vm.anUser?.profileImageUrl
                    if img != "" {
                        WebImage(url: URL(string: vm.anUser?.profileImageUrl ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .mask(Circle())
                            .shadow(color: .black, radius: 2)
                    } else {
                        Image("LotusLogo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .mask(Circle())
                    }
                }

                let usn = vm.anUser?.username
                if usn != "" {
                    Text(vm.anUser?.username ?? "")
                        .font(.system(size: 20, weight: .bold))
                } else {
                    Text("Me")
                        .font(.system(size: 20, weight: .bold))
                }
                
                Spacer()
                
                    Button {
                        isShowNewMessage.toggle()
                    } label: {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .font(.system(size: 25))
                    }
            }
            .padding(.horizontal)
            .actionSheet(isPresented: $isShowSignOutButton) {
                ActionSheet(
                    title: Text("Setting"),
                    message: Text("Do you want to SignOut?"),
                    buttons: [
                        .cancel(),
                        .destructive(
                            Text("Sign Out"),
                            action: {
                                vm.handleSignOut()
                            })
                    ])
            }
            .fullScreenCover(isPresented: $vm.isUserCurrenlyLoggedOut, onDismiss: nil) {
                Home()
            }
            .fullScreenCover(isPresented: $isShowNewMessage, onDismiss: nil) {
                NewMessage()
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Type a name", text: $searchUser)
                    .autocapitalization(.none)
            }
            .padding(15)
            .background(.gray.opacity(0.08))
            .cornerRadius(10)
        }
    }
    
    //MARK: - messengesView
    private var messageView : some View {
        
        ScrollView {
            
            VStack(spacing: 30){
                
//                ForEach(1...20, id: \.self) { userNumber in
                ForEach(vm.allUser) { user in
                        HStack(spacing: 10){
                            
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .mask(Circle())
                                .shadow(color: .gray, radius: 2)

//                                .clipped()
//                                .cornerRadius(50)
//                                .overlay(RoundedRectangle(cornerRadius: 45)
//                                            .stroke(.black, lineWidth: 1)
//                                )
                            
                            VStack(alignment: .leading, spacing: 4){
                                Text(user.username)
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
        MainMessage()
    }
}
