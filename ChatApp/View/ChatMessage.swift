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
    @State var text : String = ""
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
                        .foregroundColor(.gray)
                    
                }
            }
            .padding(.bottom, 15)
            
            VStack{
                
                TextField("Search in chat", text: $search)
                
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
            
            if vm.allMessage.count == 0{
                
                Spacer()
                Text("Haven't any message. Start now!")
                    .foregroundColor(.gray)
                Spacer()
                
            } else {
                
                ScrollView {
                    
                    VStack{
                        ForEach(vm.allMessage){ content in
                            
                            HStack{
                                
                                if content.fromId != selectedUser?.uid{
                                    
                                    Spacer()
                                    
                                    Text(content.text)
                                        .padding()
                                        .background(Color("BG_Chat"))
                                        .clipShape(ChatBubble(mymsg: true))
                                        .foregroundColor(.white)
                                    
                                }
                                else{
                                    
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
                    .foregroundColor(.gray)
                
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
                    vm.getMessage(selectedUser: selectedUser)
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

