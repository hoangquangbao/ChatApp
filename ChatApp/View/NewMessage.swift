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
    @State var selectedUser : User?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                
                topNewMassage
                mainNewMessage
                NavigationLink(destination: Chat(vm: vm, selectedUser: selectedUser), isActive: $vm.isShowChat) {
                    EmptyView()
                    
                }
            }
            .navigationBarTitle("New Message", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                vm.searchNewMessage = ""
                presentationMode.wrappedValue.dismiss()
                
            }, label: {
                
                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.purple)
                
            })
            )
            .fullScreenCover(isPresented: $vm.isShowAddParticipants, onDismiss: nil, content: {
                AddParticipants(vm: vm)
            })
            
            //Filter...
            .onChange(of: vm.searchNewMessage) { newValue in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    if newValue == vm.searchNewMessage && vm.searchNewMessage != "" {
                        
                        vm.filterForNewMessage()
                        
                    }
                }
                
                if vm.searchNewMessage == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterAllSuggestUser = vm.allSuggestUser
                        
                    }
                }
            }
        }
    }
    
    
    //MARK: - topNewMassage
    private var topNewMassage : some View {
        
        VStack(spacing: 3){
            HStack {
                
                Text("To: ")
                    .foregroundColor(.gray)
                
                TextField("Type a name", text: $vm.searchNewMessage)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                
            }
            
            Divider()
            
        }
        .padding()
    }
    
    
    //MARK: - mainNewMessage
    private var mainNewMessage : some View {
        
        ScrollView{
            
            Button {
                
                vm.searchNewMessage = ""
                vm.isShowAddParticipants = true
                
            } label: {
                HStack(){
                    
                    Image(systemName: "person.3.fill")
                    Text("Create a New Group")
                        .font(.system(size: 15))
                    Spacer()
                    
                }
                .foregroundColor(.black)
                .padding(.horizontal)
                
            }
            
            LazyVStack(alignment: .leading){
                
                Text("Suggested")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding()
                
                ForEach(vm.filterAllSuggestUser) { user in
                    
                    Button {
                        
                        selectedUser = user
                        
                        vm.searchNewMessage = ""
                        vm.fetchMessage(selectedObjectId: user.id)
                        vm.isShowChat = true
                        
                    } label: {
                        
                        HStack(spacing: 15){
                            
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 45, height: 45)
                                .mask(Circle())
                                .shadow(color: .purple, radius: 2)
                            
                            Text(user.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 15)
                }
            }
        }
    }
}



