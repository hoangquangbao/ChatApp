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
    
    //Show ChatMessage Page
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
                    .foregroundColor(.purple)
            })
            )
            .onChange(of: vm.searchUser) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    if newValue == vm.searchUser && vm.searchUser != "" {
                        
                        vm.filterApplyOnUsers()
                        
                    }
                }
                
                if vm.searchUser == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterUser = vm.allSuggestUsers
                        
                    }
                }
            }
        }
    }
    
    
    //MARK: - topbarNewMessage
    private var topbarNewMassage : some View {
        
        VStack(alignment: .leading){
            
            HStack {
                
                Text("To: ")
                    .foregroundColor(.gray)
                
                TextField("Type a name", text: $vm.searchUser)
                    .autocapitalization(.none)
                    .submitLabel(.search)
                
            }
            
            Divider()
             .frame(height: 1)
             .padding(.horizontal, 30)
             .background(Color.gray)
            
            Text("Suggested")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.gray)
                //.padding(.horizontal)
            
        }
        .padding()
    }
    
    
    //MARK: - mainNewMessage
    private var mainNewMessage : some View {
        
            ScrollView{
                
                ForEach(vm.filterUser) { user in
                    
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
                            
                            Text(user.username)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 15)
                    NavigationLink(destination: ChatMessage(vm: vm, selectedUser: self.selectedUser), isActive: $isShowChatMessage) {
                        EmptyView()
                    }
                }
            }
    }
}



