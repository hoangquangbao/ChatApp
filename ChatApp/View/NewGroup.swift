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
    @State var groupId : String?
    //@State var selectedGroup : GroupUser?

        
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
         
            VStack{
                
                topbarNewGroup
                
                if vm.isShowActivityIndicator{
                    
                    mainNewGroup.overlay(
                        
                        ActivityIndicator()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        
                    )
                } else {
                    
                    mainNewGroup
                    
                }
                
                NavigationLink(destination: GroupChat(vm: vm, selectedGroup: vm.selectedGroup), isActive: $vm.isShowGroupChat) {
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
                
                vm.isShowActivityIndicator = true
                
                groupId = NSUUID().uuidString
                vm.uploadProfileImageGroup(groupId: groupId!)

//                vm.isShowNewGroup = false
//                vm.isShowAddParticipants = false
//                vm.isShowNewMessage = false

            }, label: {

                Text("CREATE")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(vm.groupname == "" ? .gray : .purple)

            }).disabled(vm.groupname == "")
            )
        }
    }
    
    
    //MARK: - topbarNewGroup
    var topbarNewGroup : some View {
        
        VStack{
            
            Text("Name your new chat")
                .padding()

            TextField("Group Name", text: $vm.groupname)
            
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
                            
                            Text(user.name)
                                .font(.system(size: 15, weight: .bold))
                                                    
                        }
                        .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal)
            }
    }
}

