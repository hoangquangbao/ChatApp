//
//  DasboardMessenge.swift
//  ChatApp
//
//  Created by Quang Bao on 14/11/2021.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct MainMessage : View {

    @ObservedObject var vm = HomeViewModel()
    @State var isShowSignOutButton : Bool = false
    @State var isShowHomePage : Bool = false
    @State var isShowNewMessage : Bool = false
    @State var isShowChatMessage : Bool = false
    @State var selectedUser : User?

    
    var body: some View {
        
        NavigationView{
            
            VStack {
                
                topNav
                mainMessageView
                
            }
            .navigationBarHidden(true)
            .onChange(of: vm.search, perform: { value in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    if value == vm.search && vm.search != "" {
                        
                        vm.filterUser()
                    }
                }
                
                if vm.search == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filter = vm.allSuggestUsers
                    }
                }
            })
        }
    }
    
    
    //MARK: - topbarMessenges
    private var topNav : some View {
        
        VStack(alignment: .leading){
            
            HStack(spacing: 20) {
                
                Button {
                    
                    isShowSignOutButton.toggle()
                    
                } label: {
                    
                    WebImage(url: URL(string: vm.anUser?.profileImageUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .mask(Circle())
                        .shadow(color: .black, radius: 2)
                    
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
                                    try? FirebaseManager.shared.auth.signOut()
                                    isShowHomePage.toggle()
                                })
                        ])
                }
                    .fullScreenCover(isPresented: $isShowHomePage, onDismiss: nil) {

                    
                    Home()
                    
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
                        .foregroundColor(.black)
                    
                }
                .fullScreenCover(isPresented: $isShowNewMessage, onDismiss: nil) {
                    NewMessage()
                }
            }
            
            VStack{
                
                HStack {
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $vm.search)
                        .autocapitalization(.none)
                        .submitLabel(.search)
                    
                }

                Divider()
                 .frame(height: 1)
                 .padding(.horizontal, 30)
                 .background(Color.gray)
                
            }
            .padding(.vertical)
            
            Text("Recent")
                .font(.system(size: 20))
            
        }
        .padding(.horizontal)
    }
    
    
    //MARK: - messengesView
    private var mainMessageView : some View {
        
        ScrollView {
            
            ForEach(vm.filter) { user in
                
                Button {
                    
                    selectedUser = user
                    vm.fetchMessage(selectedUser: selectedUser)
                    isShowChatMessage.toggle()
                    
                } label: {
                    
                    HStack(spacing: 10){
                        
                        WebImage(url: URL(string: user.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .mask(Circle())
                            .shadow(color: .gray, radius: 2)
                        
                        VStack(alignment: .leading, spacing: 4){
                            
                            Text(user.username)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Messenge send to user")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                        }
                        
                        Spacer()
                        
                        Text("11:20 AM")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                NavigationLink(destination: ChatMessage(vm: vm, selectedUser: selectedUser), isActive: $isShowChatMessage) {
                    EmptyView()
                }
            }
        }
    }
}

