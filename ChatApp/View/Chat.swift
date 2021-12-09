//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 18/11/2021.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct Chat: View {
    
    @ObservedObject var vm = HomeViewModel()
//    @Binding var isShowChatMessage : Bool

    @State var text : String = ""
    @State var isShowImagePickerMessage : Bool = false
    @State var imgMessage : Data = Data(count: 0)
    //@State var selectedUser : User?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
            
            VStack {
                
                topbarChat
                mainChat
                bottomChat
                
            }
            .navigationBarHidden(true)
            .onChange(of: vm.searchChat) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if newValue == vm.searchChat && vm.searchChat != "" {
                        //Check func in here
                        vm.filterForChat()
                    }
                }
                
                if vm.searchChat == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterChat = vm.allMessages
                        
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        //.navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    //MARK: - topbarChat
    var topbarChat : some View {
        
        VStack{
            
            HStack(spacing: 15) {
                
                WebImage(url: URL(string: vm.selectedUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .mask(Circle())
                    .shadow(color: .black, radius: 2)
                
                VStack(alignment: .leading ,spacing: 5){
                    
                    Text("\(vm.selectedUser?.username ?? "")")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    HStack(spacing: 5){
                        
                        Image(systemName: "circle.fill")
                            .frame(width: 10, height: 10)
                            .mask(Circle())
                            .foregroundColor(.green)
                        
                        Text("Online Now")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                    }
                }
                
                Spacer()
                
                Button {
                    
                    vm.searchMainMessage = ""
                    vm.searchNewMessage = ""
                    vm.searchChat = ""
                    //presentationMode.wrappedValue.dismiss()
                    //vm.fetchRecentChatUser()
                    vm.isShowChat = false
                    
                } label: {
                    
                    Image(systemName: "multiply")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.purple)
                    
                }
            }
            .padding(.bottom, 15)
            
            VStack{
                
                TextField("Search in chat", text: $vm.searchChat)
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
    var mainChat : some View {
        
        VStack{
            
            if vm.allMessages.count == 0{
                
                Spacer()
                Text("Haven't any message. Start now!")
                    .foregroundColor(.gray)
                Spacer()
                
            } else {
                
                ScrollView {
                    LazyVStack{
                        ForEach(vm.filterChat){ content in
                            HStack{
                                
                                //My message
                                if content.fromId != vm.selectedUser?.uid{
                                    
                                    Spacer()
                                    
                                    //If this is photo then 20:01
                                    if content.imgMessage == "" {
                                        
                                        Text(content.text)
                                            .padding()
                                            .background(Color("BG_Chat"))
                                            .clipShape(ChatBubble(mymsg: true))
                                            .foregroundColor(.white)
                                        
                                    } else {
                                        
                                        WebImage(url: URL(string: content.imgMessage ?? ""))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                
                                    }
                                }
                                else{
                                    
                                    Group{
                                        
                                        if vm.selectedUser?.profileImageUrl != nil{
                                            
                                            WebImage(url: URL(string: vm.selectedUser?.profileImageUrl ?? ""))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 25, height: 25)
                                                .mask(Circle())
                                            
                                        } else {
                                            
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 25))
                                                .padding(10)
                                                .foregroundColor(.black)
                                                .background(
                                                    Circle()
                                                        .stroke(.black)
                                                )
                                        }
                                    }
                                    
                                    Text(content.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(ChatBubble(mymsg: false))
                                    
                                    Spacer()
                                    
                                }
                            }
                            .padding(.horizontal)
                            .contextMenu{
                                
                                Button {
                                    
                                    vm.deleteSenderMessage(selectedUser: self.vm.selectedUser!, selectedMessage: content)
                                    
                                } label: {
                                    
                                    Text("Remove")
                                    
                                }
                            }
                        }
                    }
                    .rotationEffect(.degrees(180))
                }
                .rotationEffect(.degrees(180))
            }
        }
    }
    
    //MARK: - bottomChat
    var bottomChat : some View {
        
        HStack(spacing: 10) {
            
            Button {
                
//                isShowImagePickerMessage = true
                vm.isShowImagePicker = true
                
            } label: {
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.purple)
                
            }
            .fullScreenCover(isPresented: $vm.isShowImagePicker, onDismiss: {
                
                if vm.image != nil
                {
                    vm.sendMessage(selectedUser: vm.selectedUser, text: "")
                }
                
            }) {
                
//                ImagePickerMessage(isShowImagePickerMessage: self.$isShowImagePickerMessage, imgMessage: self.$imgMessage)
                ImagePicker(image: $vm.image)
                
            }
            
            TextField("Aa", text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.done)
            //                .padding()
                .background()
            //                .cornerRadius(45)
                .onSubmit {
                    
                    if !text.isEmpty{
                        
                        vm.sendMessage(selectedUser: vm.selectedUser, text: text)
                        text = ""
                        
                    }
                }
            
            //Hidding Send button
            if !text.isEmpty{
                
                Button {
                        
                    vm.sendMessage(selectedUser: vm.selectedUser, text: text)
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


struct ChatBubble : Shape {
    
    var mymsg : Bool
    
    func path(in rect: CGRect) -> Path {
            
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight,mymsg ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        
        return Path(path.cgPath)
        
    }
}

