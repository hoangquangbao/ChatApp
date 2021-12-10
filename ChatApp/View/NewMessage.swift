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
//    @ObservedObject var vm : HomeViewModel
//    @State var isShowChatMessage : Bool = false

//    @State var selectedUser : User?
    
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
                
                vm.isShowNewMessage = false
                //presentationMode.wrappedValue.dismiss()
                
            }, label: {
                
                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.purple)
                
            })
            )
            .onChange(of: vm.searchNewMessage) { newValue in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    if newValue == vm.searchNewMessage && vm.searchNewMessage != "" {
                        
                        vm.filterForNewMessage()
                        
                    }
                }
                
                if vm.searchNewMessage == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterNewMessage = vm.allSuggestUsers
                        
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    //MARK: - topbarNewMessage
    private var topbarNewMassage : some View {
        
        VStack(alignment: .leading){
            
            HStack {
                
                Text("To: ")
                    .foregroundColor(.gray)
                
                TextField("Type a name", text: $vm.searchNewMessage)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                
            }
            
            Divider()
                .frame(height: 1)
                .padding(.horizontal, 30)
                .background(Color.gray)
            
            Text("Suggested")
                .font(.system(size: 20))
                .foregroundColor(.gray)
            //.padding(.horizontal)
            
        }
        .padding()
    }
    
    
    //MARK: - mainNewMessage
    private var mainNewMessage : some View {
        
        ScrollView{
            
            LazyVStack{
                
                ForEach(vm.filterNewMessage) { user in
                    
                    Button {
                        
                        vm.selectedUser = user
                        vm.fetchMessage(selectedUser: vm.selectedUser)
                        vm.searchNewMessage = ""
                        vm.isShowChat = true
                        
                    } label: {
                        
                        HStack(spacing: 10){
                            
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .mask(Circle())
                                .shadow(color: .purple, radius: 2)
                            
                            Text(user.username)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 15)
//                    NavigationLink(destination: Chat(vm: vm, selectedUser: self.vm.selectedUser), isActive: $vm.isShowChatMessage) {
                    NavigationLink(destination: Chat(vm: vm), isActive: $vm.isShowChat) {
                        EmptyView()
                    }
                    //                        .fullScreenCover(isPresented: $isShowChatMessage, onDismiss: nil) {
                    //                            Chat(vm: vm, selectedUser: selectedUser)
                    //                        }
                }
            }
        }
    }
}



