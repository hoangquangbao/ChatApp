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
    @State var imageMessage: UIImage?
//    @State var isShowImagePickerMessage : Bool = false
    //@State var imgMessage : Data = Data(count: 0)
    @State var selectedUser : User?
    
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
//            .fullScreenCover(isPresented: $vm.isShowMainMessage) {
//                MainMessage()
//            }
            .fullScreenCover(isPresented: $vm.isShowImagePickerMessage, onDismiss: {
                
                if imageMessage != nil
                {
                    
                    //Activate activity indicator..
                    //..true: when start send Image Message (bottomChat)
                    //..false: when fetchMessage success (fetchMessage)
                    vm.isShowActivityIndicator = true
                    
                    vm.uploadImageMessage(selectedUser: selectedUser, text: "", imageMessage: imageMessage!)
                    //vm.sendMessage(selectedUser: vm.selectedUser, text: "", imgMessage: <#String#>)
                }
                
            }) {
                
                //                ImagePickerMessage(isShowImagePickerMessage: self.$isShowImagePickerMessage, imgMessage: self.$imgMessage)
                ImagePickerMessage(imageMessage: $imageMessage)
                
            }
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
    var topbar : some View {
        
        VStack{
            
            HStack(spacing: 15) {
                    
                    WebImage(url: URL(string: selectedUser?.profileImageUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .mask(Circle())
                        .shadow(color: .black, radius: 2)
                    
                    VStack(alignment: .leading ,spacing: 5){
                        
                        Text("\(selectedUser?.name ?? "")")
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
                    
                    vm.searchChat = ""
                    //vm.isShowMainMessage = true
                    
                    DispatchQueue.main.async {
                        
                        //vm.isShowChat = false
                        presentationMode.wrappedValue.dismiss()

                    }
                    
                    //Delete allMessages data in here if not when open another chat, it have fast show in < 1 sencond.
                    vm.allMessages.removeAll()
                    vm.filterChat.removeAll()
//                    DispatchQueue.main.async {
//                        vm.isShowNewGroup = false
//                    }
//                    DispatchQueue.main.async {
//                        vm.isShowAddParticipants = false
//                    }
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
                
                TextField("Search in chat", text: $vm.searchChat)
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
        
        VStack{
            
            //            if vm.allMessages.count == 0{
            //
            //                Spacer()
            //                Text("Haven't any message. Start now!")
            //                    .foregroundColor(.gray)
            //                Spacer()
            //
            //} else {
            
            ScrollView {
                LazyVStack{
                        ForEach(vm.filterChat){ content in
                            VStack(){
                                
                                //My message
//                                if content.fromId != selectedUser?.uid{
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
                                            //.scaledToFit()
                                            //                                                .padding(.top)
                                            
                                        }
                                        //My firiend's message
                                        else {
                                            
                                            Text(text)
                                                .padding()
                                                .background(Color("BG_Chat"))
                                                .clipShape(ChatBubble(mymsg: true))
                                                .foregroundColor(.white)
                                            
                                        }
                                    }
                                } else {
                                    
                                    HStack(alignment: .bottom){
                                        
                                        WebImage(url: URL(string: selectedUser?.profileImageUrl ?? ""))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 25, height: 25)
                                            .mask(Circle())
                                        
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
                                        
                                        Spacer()
                                        
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .contextMenu{
                                
                                Button {
                                    
                                    vm.deleteMessage(selectedUser: selectedUser!, selectedMessage: content)
                                    
                                } label: {
                                    
                                    Text("Remove")
                                    
                                }
                            }
                        }
                }
                .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(180))
            //}
        }
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
            //                .padding()
                .background()
            //                .cornerRadius(45)
                .onSubmit {
                    
                    if !text.isEmpty{
                        
                        vm.sendMessage(selectedUser: selectedUser, text: text, imgMessage: "")
                        text = ""
                        
                    }
                }
            
            //Hidding Send button
            if !text.isEmpty{
                
                Button {
                    
                    vm.sendMessage(selectedUser: selectedUser, text: text, imgMessage: "")
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

