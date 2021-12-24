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
    
    @StateObject var vm = HomeViewModel()
    @State var selectedUser : User?
    
    var body: some View {
        NavigationView{
            VStack {
                
                topMainMessage
                mainMainMessage
                NavigationLink("", destination: Chat(vm:vm, selectedUser: selectedUser), isActive: $vm.isShowChat)
                NavigationLink("", destination: GroupChat(vm:vm, selectedGroup: vm.selectedGroup), isActive: $vm.isShowGroup)
                
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(true)
            
            .fullScreenCover(isPresented: $vm.isShowHomePage, onDismiss: nil) {
                //Home()
                ContentView()
            }
            
            .fullScreenCover(isPresented: $vm.isShowNewMessage, onDismiss: nil) {
                NewMessage(vm: vm)
            }
            
            //Filter...
            .onChange(of: vm.searchMainMessage) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    if newValue == vm.searchMainMessage && vm.searchMainMessage != "" {
                        
                        vm.filterForMainMessage()
                        
                    }
                }
                
                if vm.searchMainMessage == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterAllLastMessage = vm.allLastMessage
                        
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    //MARK: - topMainMessage
    private var topMainMessage : some View {
        
        VStack(alignment: .leading){
            
            HStack(spacing: 20) {
                
                Button {
                    
                    vm.isShowSignOutButton = true
                    
                } label: {
                    
                    WebImage(url: URL(string: vm.currentUser?.profileImageUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .mask(Circle())
                        .shadow(color: .purple, radius: 2)
                    
                }
                .actionSheet(isPresented: $vm.isShowSignOutButton) {
                    
                    ActionSheet(
                        
                        title: Text("Setting"),
                        message: Text("Do you want to SignOut?"),
                        buttons: [
                            .cancel(),
                            .destructive(
                                Text("Sign Out"),
                                action: {
                                    
                                    vm.handleSighOut()
                                    
                                })
                        ])
                }
                
                Text(vm.currentUser?.name ?? "")
                    .font(.system(size: 20, weight: .bold))
                
                
                Spacer()
                
                Button {
                    
                    vm.searchMainMessage = ""
                    vm.isShowNewMessage = true
                    
                } label: {
                    
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(.system(size: 25))
                        .foregroundColor(.purple)
                    
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
                //                    .frame(height: 1)
                //                    .padding(.horizontal, 30)
                //                    .background(Color.gray)
                
            }
            .padding(.vertical)
            
            Text("Recent")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
        }
        .padding(.horizontal)
        
    }
    
    
    //MARK: - mainMainMessage
    private var mainMainMessage : some View {
        
        VStack {
            
            if vm.allLastMessage.count == 0{
                
                Spacer()
                Text("Haven't any chat. Start now!")
                    .foregroundColor(.gray)
                Spacer()
                
            } else {
                
                ScrollView {
                    
                    LazyVStack{
                        
                        ForEach(vm.filterAllLastMessage) { object in
                            
                            VStack{
                                
                                Button {
                                    
                                    vm.searchMainMessage = ""
                                    
                                    let selectedObjectId = object.toId
                                    vm.fetchMessage(selectedObjectId: selectedObjectId)
                                    
                                    //if have "-" is group else it is user
                                    if (selectedObjectId.contains("-")) {
                                        
                                        vm.fetchGroupInfo(groupId: selectedObjectId)
                                        //isShowGroup = true should put in fetchGroupInfo because when we initialization a new group that need to call "fetchGroup" and show "Group UI". Otherwise, isShowGroup = true put in here is not good
                                        //vm.isShowGroup = true
                                        
                                    } else {
                                        
                                        selectedUser = vm.getUserInfo(selectedObjectId: selectedObjectId )
                                        vm.isShowChat = true
                                        
                                    }
                                    
                                } label: {
                                    
                                    HStack(spacing: 15){
                                        
                                        WebImage(url: URL(string: object.profileImageUrl))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .mask(Circle())
                                            .shadow(color: .purple, radius: 2)
                                        
                                        VStack(alignment: .leading, spacing: 4){
                                            
                                            Text(object.name)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(.black)
                                            
                                            Text(object.text)
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Text(timeAgoDisplay(timestamp: object.timestamp))
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical, 15)
                            }
                            .contextMenu{
                                
                                Button {
                                    
                                    vm.deleteLastMessage(selectedUser: object)
                                    
                                } label: {
                                    
                                    Text("Remove")
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - timeAgoDisplay
    //Convert "timestam" from Timestamp type to Date type. After that set timeAgo format
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
}

