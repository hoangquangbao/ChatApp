//
//  AddParticipants.swift
//  ChatApp
//
//  Created by Quang Bao on 14/12/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct AddParticipants: View {
    @ObservedObject var vm = HomeViewModel()
    @State var isBackToNewMessage = false
//    @State var filterGroupMessage = [User]()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            VStack{
                
                topbarAddParticipants
                mainAddParticipants

            }
            .navigationBarTitle("Add Participants", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                
                if vm.participantList.count >= 2 {
                    
                    isBackToNewMessage = true
                    
                } else {
                    
                    vm.searchAddParticipants = ""
                    vm.participantList.removeAll()
                    presentationMode.wrappedValue.dismiss()

                }
                
            }, label: {
                
                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.purple)
                
            })
            )
            .navigationBarItems(trailing:
                                    Button(action: {
                
                vm.searchAddParticipants = ""
                vm.isShowNewGroup = true
                
            }, label: {
                
                Text("NEXT")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(vm.participantList.count <= 1 ? .gray : .purple)
                
            }).disabled(vm.participantList.count <= 1)
            )
            
            //Navigation to NewGroup
            .fullScreenCover(isPresented: $vm.isShowNewGroup, onDismiss: nil, content: {
                NewGroup(vm: vm)
            })
            
            //Navigation back to NewMessage
            .actionSheet(isPresented: $isBackToNewMessage) {
                
                ActionSheet(
                    
                    title: Text("Discard group?"),
                    message: Text("If you quit before creating your group, your changes won't be save."),
                    buttons: [
                        .cancel(),
                        .destructive(
                            Text("Discard Group"),
                            action: {
                                
                                vm.searchAddParticipants = ""
                                vm.participantList.removeAll()
                                presentationMode.wrappedValue.dismiss()
                                
                            })
                    ])
            }
            
            //Filter...
            .onChange(of: vm.searchAddParticipants) { newValue in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    if newValue == vm.searchAddParticipants && vm.searchAddParticipants != "" {
                        
                        vm.filterForGroupMessage()
                        
                    }
                }
                
                if vm.searchAddParticipants == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterAddParticipants = vm.suggestUser
                        
                    }
                }
            }
        }
    }
    
    
    //MARK: - topbarGroupMessage
    var topbarAddParticipants : some View {
        
        VStack(spacing: 3){
            HStack {
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Type a name", text: $vm.searchAddParticipants)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                
            }
            .padding(.top)
            
            Divider()
//                .frame(height: 1)
//                .padding(.horizontal, 30)
//                .background(Color.gray)
            
            //Selected user list
            ScrollView(.horizontal) {
                
                HStack(spacing: 25){
                    
                    ForEach(vm.participantList){ user in
                        
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
    var mainAddParticipants : some View {
        
        ScrollView{
            
            LazyVStack(alignment: .leading){
                                
                ForEach(vm.filterAddParticipants) { user in
                    
                    Button {
                      
                    //If the user not exist in groupChat array then add it.
                      if(isNotExist(user: user)) {
                          
                          vm.searchAddParticipants = ""
                          vm.participantList.append(user)
                          
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
                                .font(.system(size: 15, weight: .bold))
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
        
        let data = vm.participantList.filter {
              
              return $0.uid.contains(user.uid)
              
        }
        
        return data.isEmpty ? true : false
        
    }
}


