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
    @State var selectedGrpID : String?
    
    @State var text : String = ""
    @State var imageMessage: UIImage?
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
            
            //            .onChange(of: vm.searchChat) { newValue in
            //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //                    if newValue == vm.searchChat && vm.searchChat != "" {
            //                        //Check func in here
            //                        vm.filterForChat()
            //                    }
            //                }
            //
            //                if vm.searchChat == ""{
            //
            //                    //do nothing
            //                    withAnimation(.linear){
            //                        vm.filterChat = vm.allMessages
            //
            //                    }
            //                }
            //            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        //.navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    //MARK: - topbarChat
    var topbar : some View {
        
        VStack{
            
            HStack(spacing: 15) {
                
                Image("LotusLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .mask(Circle())
                    .shadow(color: .black, radius: 2)
                
                VStack(alignment: .leading, spacing: 5){
                    
                    Text(vm.groupName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    Text("\(vm.participantList.count) participants")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                }
                
                Spacer()
                
                Button {
                    
                    vm.searchChat = ""
                    //presentationMode.wrappedValue.dismiss()
                    //vm.fetchRecentChatUser()
                    
                    //For Group
                    vm.groupName = ""
                    vm.participantList.removeAll()
                    
                    DispatchQueue.main.async {
                        //vm.isShowGroupChat = false
                        presentationMode.wrappedValue.dismiss()

                    }
                    DispatchQueue.main.async {
                        //vm.isShowNewGroup = false
                        presentationMode.wrappedValue.dismiss()

                    }
                    DispatchQueue.main.async {
                        //vm.isShowAddParticipants = false
                        presentationMode.wrappedValue.dismiss()

                    }
                    //                    DispatchQueue.main.async {
                    //                        vm.isShowNewMessage = false
                    //                    }
                    
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
                    .frame(height: 1)
                    .padding(.horizontal, 30)
                    .background(Color.gray)
                
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
    }
    
    
    //MARK: - mainChat
    var main : some View {
        
        ScrollView {
            
            LazyVStack{
                
            }
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
    }
    
    
    //MARK: - bottomChat
    var bottom : some View {
        
        HStack(spacing: 10) {
            
            Button {
                
                vm.isShowImagePickerMessage = true
                
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
                        
                        vm.sendGroupChat(selectedGrpID: selectedGrpID!, text: text, imgMessage: "")
                        text = ""
                        
                    }
                }
            
            //Hidding Send button
            if !text.isEmpty{
                
                Button {
                    
                    vm.sendGroupChat(selectedGrpID: selectedGrpID!, text: text, imgMessage: "")
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
