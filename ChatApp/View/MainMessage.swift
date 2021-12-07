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
    
    //@Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            VStack {
                
                topNav
                mainMessageView
                
            }
            .navigationBarHidden(true)
            .onChange(of: vm.searchMainMessage) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    if newValue == vm.searchMainMessage && vm.searchMainMessage != "" {
                        
                        vm.filterForMainMessage()
                        
                    }
                }
                
                if vm.searchMainMessage == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterMainMessage = vm.allRecentChatUsers
                        
                    }
                }
            }
        }
    }
    
    
    //MARK: - topbarMessenges
    private var topNav : some View {
        
        VStack(alignment: .leading){
            
            HStack(spacing: 20) {
                
                Button {
                    
                    isShowSignOutButton = true
                    
                } label: {
                    
                    WebImage(url: URL(string: vm.anUser?.profileImageUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .mask(Circle())
                        .shadow(color: .purple, radius: 2)
                    
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
                                    
                                    UserDefaults.standard.setIsLoggedIn(value: false)
                                    
                                    try? FirebaseManager.shared.auth.signOut()
                                    
                                    //presentationMode.wrappedValue.dismiss()
                                    
                                    isShowHomePage = true
                                    
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
                    
                    isShowNewMessage = true
                    
                } label: {
                    
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(.system(size: 25))
                        .foregroundColor(.purple)
                    
                }
                .fullScreenCover(isPresented: $isShowNewMessage, onDismiss: nil) {
                    NewMessage(vm: vm)
                }
            }
            
            VStack{
                
                HStack {
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $vm.searchMainMessage)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
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
                .foregroundColor(.gray)
            
        }
        .padding(.horizontal)
    }
    
    
    //MARK: - messengesView
    private var mainMessageView : some View {
        
        ScrollView {
            
            LazyVStack{
                
                ForEach(vm.filterMainMessage) { user in
                    
                    VStack{
                        
                        Button {
                            
                            //Get the user follow User data type to provide to fetchMessage
                            selectedUser = getSelectedUser(uid: user.toId )
                            vm.fetchMessage(selectedUser: selectedUser)
                            isShowChatMessage = true
                            
                        } label: {
                            
                            HStack(spacing: 10){
                                
                                WebImage(url: URL(string: user.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .mask(Circle())
                                    .shadow(color: .purple, radius: 2)
                                
                                VStack(alignment: .leading, spacing: 4){
                                    
                                    Text(user.username)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Text(user.text)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                    
                                }
                                
                                Spacer()
                                
                                Text(timeAgoDisplay(timestamp: user.timestamp))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 15)
                        NavigationLink(destination: Chat(vm: vm, selectedUser: selectedUser), isActive: $isShowChatMessage) {
                            EmptyView()
                        }
                        
                    }
                    .contextMenu{
                        
                        Button {
                            
                            vm.deleteRecentChatUser(selectedUser: user)
                            
                        } label: {
                            
                            Text("Remove")
                            
                        }
                    }
                }

            }
        }
    }

    
    //MARK: - timeAgoDisplay
    //Convert data type of "timestam" from Timestamp to Date. After that set timeAgo format
    func timeAgoDisplay(timestamp : Timestamp) -> String {
        
        let today = Date()
        let startOfNow = today
        let startOfTimeStamp = timestamp.dateValue()
        let secondsAgo = Calendar.current.dateComponents([.second], from: startOfTimeStamp, to: startOfNow).second!
    
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            return "\(secondsAgo)s ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute)m ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour)h ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day)d ago"
        }
        return "\(secondsAgo / week)w ago"
        
    }
    
    
    //MARK: - Transfer data type of selected user from "RecentChatUser" to "User"
    //Refer link for find an object in array: https://stackoverflow.com/questions/28727845/find-an-object-in-array
    //"func fetchUserToSuggest()" have to init at begin run app, it help "vm.allSuggestUsers" variable have data before calling "func getSelectedUser(uid: String) -> User". If not our get an error "Unexpectedly found nil while unwrapping an Optional value"
    func getSelectedUser(uid: String) -> User {
        
        return vm.allSuggestUsers.first{$0.uid == uid }!
        
    }
}

