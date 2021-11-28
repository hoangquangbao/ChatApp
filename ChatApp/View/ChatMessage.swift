//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 18/11/2021.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ChatMessage: View {

    @ObservedObject var vm : HomeViewModel
    
    //Get chat content
    @State var text : String = ""
    
    //Get selected user from other Page
    @State var selectedUser : User?
    @State var search : String = ""
    
    
    @Environment(\.presentationMode) var presentationMode
        
    var body: some View {
        
        NavigationView{
            
            VStack {
                
                topbarChat
                mainChat
                bottomChat
                
            }
            .navigationBarHidden(true)
            .onChange(of: vm.searchMessage) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if newValue == vm.searchMessage && vm.searchMessage != "" {
                        //Check func in here
                        vm.filterApplyOnMessages()
                    }
                }
                
                if vm.searchMessage == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterMessage = vm.allMessages
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        //.onAppear{ vm.getMessage(selectedUser: selectedUser)}
    }
    
    
    //MARK: - topbarChat
    var topbarChat : some View {
        
        VStack{
            
            HStack(spacing: 15) {
                
                Group{
                    
                    if selectedUser?.profileImageUrl != nil{
                        
                        WebImage(url: URL(string: selectedUser?.profileImageUrl ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
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
                .shadow(color: .black, radius: 2)
                
                VStack(alignment: .leading ,spacing: 5){
                    
                    Text("\(selectedUser?.username ?? "")")
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
                    
                    presentationMode.wrappedValue.dismiss()
                    
                } label: {
                    
                    Image(systemName: "multiply")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.purple)
                    
                }
            }
            .padding(.bottom, 15)
            
            VStack{
                
                TextField("Search in chat", text: $vm.searchMessage)
                    .autocapitalization(.none)
                
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
                    
                    VStack{
                        ForEach(vm.filterMessage){ content in
                            
                            HStack{
                                
                                //For conttent chat
                                if content.fromId != selectedUser?.uid{
                                    
                                    Spacer()
                                    
                                    Text(content.text)
                                        .padding()
                                        .background(Color("BG_Chat"))
                                        .clipShape(ChatBubble(mymsg: true))
                                        .foregroundColor(.white)
                                    
                                }
                                else{
                                    
                                    //For avatar
                                    Group{
                                        
                                        if selectedUser?.profileImageUrl != nil{
                                            
                                            WebImage(url: URL(string: selectedUser?.profileImageUrl ?? ""))
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
                
            } label: {
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.purple)
                
            }
            
            TextField("Aa", text: $text)
                .autocapitalization(.none)
                .submitLabel(.send)
//                .padding()
                .background()
//                .cornerRadius(45)
            
            Button {
                
                if !text.isEmpty{
                    
                    vm.sendMessage(selectedUser: selectedUser, text: text)
                    text = ""
                    vm.fetchMessage(selectedUser: selectedUser)
                }
            } label: {
                
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.purple)
                
            }
        }
        .padding()
        .background()
        .cornerRadius(45)
        .padding(.horizontal)
    }
}


struct ChatBubble : Shape {
    
    var mymsg : Bool
    
    func path(in rect: CGRect) -> Path {
            
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight,mymsg ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        
        return Path(path.cgPath)
    }
}

