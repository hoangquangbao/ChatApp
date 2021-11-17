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
                    
                } label: {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(.system(size: 25))
                }
            }
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
    private var messageView : some View {
        
        ScrollView {
            
            VStack(spacing: 30){
                
//                ForEach(1...20, id: \.self) { userNumber in
                ForEach(vm.allUser) { user in

                    if vm.anUser?.uid != user.uid {
                        HStack(spacing: 10){
                            
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .mask(Circle())

                            
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
