//
//  NewMessages.swift
//  ChatApp
//
//  Created by Quang Bao on 18/11/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewMessage: View {
    
    @ObservedObject var vm = HomeViewModel()
    
    @State var searchUser : String = ""
    @State var isShowChatMessage : Bool = false
    @State var selectedUser : User?
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        NavigationView{
            
            VStack{
                
                topbarNewMassage
                mainNewMessage

            }
            .navigationBarTitle("New Message", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                
                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
            })
            )
        }
    }
    
    
    //MARK: - topbarNewMessage
    private var topbarNewMassage : some View {
        
        VStack{
            
            HStack {
                
                Text("To: ")
                    .foregroundColor(.gray)
                
                TextField("Type a name", text: $searchUser)
                    .autocapitalization(.none)
                    .submitLabel(.search)
                
            }
            
            Divider()
             .frame(height: 1)
             .padding(.horizontal, 30)
             .background(Color.gray)
            
        }
        .padding()
        
    }
    
    
    //MARK: - mainNewMessage
    private var mainNewMessage : some View {
        
        VStack(alignment: .leading){
            
            Text("Suggested")
                .font(.system(size: 20))
                .padding(.horizontal)
            
            ScrollView{
                
                ForEach(vm.allUser) { user in
                    
                    Button {
                        
                        selectedUser = user
                        vm.getMessage(selectedUser: selectedUser)
                        isShowChatMessage.toggle()
                        
                    } label: {
                        
                        HStack(spacing: 10){
                            
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .mask(Circle())
                                .shadow(color: .gray, radius: 2)
                            
                            Text(user.username)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    NavigationLink(destination: ChatMessage(vm: vm, selectedUser: self.selectedUser), isActive: $isShowChatMessage) {
                        EmptyView()
                    }
                }
            }
        }
    }
}



