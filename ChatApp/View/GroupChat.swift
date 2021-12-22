//
//  GroupChat.swift
//  ChatApp
//
//  Created by Quang Bao on 17/12/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupChat: View {
    
    @ObservedObject var vm = HomeViewModel()
//    @State var selectedGroupId : String?
    @State var selectedGroup : GroupUser?
    @State var imageGroup: UIImage?

    
    @State var text : String = ""
    @State var isShowImagePickerMessage : Bool = false
    @State var imgMessage : Data = Data(count: 0)
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
            
            VStack {

                topbar
                main
                if vm.isShowActivityIndicator {
                    
                    bottom.overlay(
                        ActivityIndicator()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                        
                    )
                } else {
                    
                    bottom
                    
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $vm.isShowMainMessage) {
                MainMessage()
            }
            .fullScreenCover(isPresented: $vm.isShowImagePickerGroup, onDismiss: {
                
                if imageGroup != nil
                {
                    
                    //Activate activity indicator..
                    //..true: when start send Image Message (bottomChat)
                    //..false: when fetchMessage success (fetchMessage)
                    vm.isShowActivityIndicator = true
                    
                    vm.uploadImageGroup(selectedGroup: selectedGroup, text: "", imageGroup: imageGroup)

                }
                
            }) {
                
                ImagePickerGroup(imageGroup: $imageGroup)
                
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        //.navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    //MARK: - topbarChat
    var topbar : some View {
        
        VStack{
            
            HStack(spacing: 15) {
                
                WebImage(url: URL(string: selectedGroup?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .mask(Circle())
                    .shadow(color: .black, radius: 2)
                
                VStack(alignment: .leading, spacing: 5){
                    
                    Text(selectedGroup!.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    Text("\(selectedGroup!.member.count + 1) participants")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                }
                
                Spacer()
                
                Button {
                    
                    vm.searchGroupChat = ""
                    vm.participantList.removeAll()
                    
                    vm.isShowMainMessage = true

                } label: {
                    
                    Image(systemName: "multiply")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.purple)
                    
                }
            }
            .padding(.bottom, 15)
            
            VStack{
                
                TextField("Search in chat", text: $vm.searchGroupChat)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Divider()
//                    .frame(height: 1)
//                    .padding(.horizontal, 30)
//                    .background(Color.gray)
                
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
    }
    
    
    //MARK: - mainChat
    var main : some View {
        
        VStack {
            ScrollView {
                LazyVStack {
                        ForEach(vm.filterChat){ content in
                            VStack() {
                                
                                if content.fromId == vm.currentUser?.id {
                                    
                                    HStack() {
                                        
                                        Spacer()
                                        
                                        //If text == "", it's a photo
                                        let text = content.text
                                        if text == "" {
                                            
                                            WebImage(url: URL(string: content.imgMessage ))
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(15)
                                                .frame(maxWidth: UIScreen.main.bounds.width - 150)
                                            
                                        } else {
                                            
                                            Text(text)
                                                .padding()
                                                .background(Color("BG_Chat"))
                                                .clipShape(ChatBubble(mymsg: true))
                                                .foregroundColor(.white)
                                            
                                        }
                                    }
                                } else {
                                    
                                    HStack(alignment: .bottom){
                                        
                                            let memberGroup = vm.getUserInfo(selectedObjectId: content.fromId)

                                            WebImage(url: URL(string: memberGroup.profileImageUrl ))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 25, height: 25)
                                                .mask(Circle())
                                            
                                        VStack {
                                            
                                            Text(memberGroup.name)
                                                .foregroundColor(.gray)
                                                .font(.system(size: 8))
                                            
                                            //If text == "", it's a photo
                                            let text = content.text
                                            if text == "" {
                                                
                                                WebImage(url: URL(string: content.imgMessage ))
                                                    .resizable()
                                                    .scaledToFit()
                                                    .cornerRadius(15)
                                                    .frame(maxWidth: UIScreen.main.bounds.width - 150)
                                                    .padding(.leading, 0)
                                                //.scaledToFit()
                                                //                                                .padding(.top)
                                                
                                            } else {
                                                
                                                Text(text)
                                                    .padding()
                                                    .background(Color.gray.opacity(0.2))
                                                    .clipShape(ChatBubble(mymsg: false))
                                                
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                }
                .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(180))
        }
    }
    
    
    //MARK: - bottomChat
    var bottom : some View {
        
        HStack(spacing: 10) {
            
            Button {
                
                vm.isShowImagePickerGroup = true
                
            } label: {
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.purple)
                
            }
            
            TextField("Aa", text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.done)
                .background()
                .onSubmit {
                    
                    if !text.isEmpty{
                        
                        vm.sendGroup(selectedGroup: selectedGroup!, text: text, imgMessage: "")
                        text = ""
                        
                    }
                }
            
            //Hidding Send button
            if !text.isEmpty{
                
                Button {
                    
                    vm.sendGroup(selectedGroup: selectedGroup!, text: text, imgMessage: "")
                    text = ""
                    
                } label: {
                    
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.purple)
                    
                }
            }
        }
        .padding()
        .background()
        .cornerRadius(45)
        .padding(.horizontal)
        .animation(.easeOut)
    }
}
