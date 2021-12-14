//
//  GroupMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 14/12/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupMessage: View {
    
    @ObservedObject var vm = HomeViewModel()
//    @State var filterGroupMessage = [User]()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            VStack{
                
                topbarGroupMessage
                mainGroupMessage
                
            }
            .navigationBarTitle("Group Message", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                
                //vm.isShowNewMessage = false
                presentationMode.wrappedValue.dismiss()
                
            }, label: {
                
                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.purple)
                
            })
            )
            .navigationBarItems(trailing:
                                    Button(action: {
                
                //vm.isShowNewMessage = false
                //presentationMode.wrappedValue.dismiss()
                
            }, label: {
                
                Text("NEXT")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(vm.groupChat.count < 2 ? .gray : .purple)
                
            }).disabled(vm.groupChat.count < 2)
            )
            
            //Filter...
            .onChange(of: vm.searchGroupMessage) { newValue in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    if newValue == vm.searchGroupMessage && vm.searchGroupMessage != "" {
                        
                        vm.filterForGroupMessage()
                        
                    }
                }
                
                if vm.searchGroupMessage == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterGroupMessage = vm.suggestUser
                        
                    }
                }
            }
        }
    }
    
    
    //MARK: - topbarGroupMessage
    var topbarGroupMessage : some View {
        
        VStack(spacing: 3){
            HStack {
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Type a name", text: $vm.searchGroupMessage)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                
            }
            .padding(.top)
            
            Divider()
                .frame(height: 1)
                .padding(.horizontal, 30)
                .background(Color.gray)
            
            //Selected user list
            ScrollView(.horizontal) {
                
                HStack(spacing: 25){
                    
                    ForEach(vm.groupChat){ user in
                        
                        VStack(spacing: 10){
                            
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .mask(Circle())
                                .shadow(color: .purple, radius: 2)
                            
                            Text(user.username)
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                            
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .padding(.horizontal)
    }
    
    
    //MARK: - mainGroupMessage
    var mainGroupMessage : some View {
        
        ScrollView{
            
            LazyVStack(alignment: .leading){
                                
                ForEach(vm.filterGroupMessage) { user in
                    
                    Button {
                      
                    //If the user not exist in groupChat array then add it.
                      if(isNotExist(user: user)) {
                          
                          vm.groupChat.append(user)
                          
                      }

                    } label: {
                        
                        HStack(spacing: 15){
                            
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 45, height: 45)
                                .mask(Circle())
                                .shadow(color: .purple, radius: 2)
                            
                            Text(user.username)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "plus.circle")
                                .foregroundColor(.gray)
                            
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 15)
                }
            }
        }
    }
    
    
    //MARK: - isNotExist
    //Check if a user is selected or not
    func isNotExist(user: User) -> Bool {
        
        let data = vm.groupChat.filter {
              
              return $0.uid.contains(user.uid)
              
        }
        
        return data.isEmpty ? true : false
        
    }
}

