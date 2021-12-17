//
//  NewGroup.swift
//  ChatApp
//
//  Created by Quang Bao on 14/12/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewGroup: View {
    
    @ObservedObject var vm = HomeViewModel()
        
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
         
            VStack{
                
                topbarNewGroup
                mainNewGroup
                NavigationLink(destination: Chat(vm: vm), isActive: $vm.isShowChat) {
                    EmptyView()
                }
                
            }
            .navigationBarTitle("New Group", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {

                presentationMode.wrappedValue.dismiss()

            }, label: {

                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.purple)

            })
            )
            .navigationBarItems(trailing:
                                    Button(action: {
                
                vm.createGroupChat()
                vm.isShowChat = true
                
//                vm.isShowNewGroup = false
//                vm.isShowAddParticipants = false
//                vm.isShowNewMessage = false

            }, label: {

                Text("CREATE")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(vm.groupName == "" ? .gray : .purple)

            }).disabled(vm.groupName == "")
            )
        }
    }
    
    
    //MARK: - topbarNewGroup
    var topbarNewGroup : some View {
        
        VStack{
            
            Text("Name your new chat")
                .padding()

            TextField("Group Name", text: $vm.groupName)
            
            Divider()
            
        }
        .padding()
        
    }
    
    
    //MARK: - mainNewGroup
    var mainNewGroup : some View {
            
            ScrollView{
                LazyVStack(alignment: .leading){
                    
                    Text("\(vm.participantList.count) participants")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.vertical)

                    ForEach(vm.participantList) { user in
                        
                        HStack(spacing: 15){
                            
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 45, height: 45)
                                .mask(Circle())
                                .shadow(color: .purple, radius: 2)
                            
                            Text(user.username)
                                .font(.system(size: 15, weight: .bold))
                                                    
                        }
                        .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal)
            }
    }
}

