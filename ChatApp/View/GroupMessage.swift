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
        }
    }
    
    
    //MARK: - topbarGroupMessage
    var topbarGroupMessage : some View {
        
        VStack(spacing: 3){
            HStack {
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Type a name", text: $vm.searchNewMessage)
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
                                .frame(width: 50, height: 50)
                                .mask(Circle())
                                .shadow(color: .purple, radius: 2)
                            
                            Text(user.username)
                                .font(.system(size: 8, weight: .bold))
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
                
                ForEach(vm.filterNewMessage) { user in
                    
                    Button {
                        
                        vm.groupChat.append(user)
                        
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
}

struct GroupMessage_Previews: PreviewProvider {
    static var previews: some View {
        GroupMessage()
    }
}
