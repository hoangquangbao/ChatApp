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
    @State var isShowConfirmDiscardGroup = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                
                topAddParticipants
                mainAddParticipants
                
            }
            .navigationBarTitle("Add Participants", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                
                if vm.participantList.count >= 2 {
                    
                    isShowConfirmDiscardGroup = true
                    
                } else {
                    
                    vm.resetIsAddedStatus()
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

            .fullScreenCover(isPresented: $vm.isShowNewGroup, onDismiss: nil, content: {
                NewGroup(vm: vm)
            })
            
            .actionSheet(isPresented: $isShowConfirmDiscardGroup) {
                
                ActionSheet(
                    
                    title: Text("Discard group?"),
                    message: Text("If you quit before creating your group, your changes won't be save."),
                    buttons: [
                        .cancel(),
                        .destructive(
                            Text("Discard Group"),
                            action: {
                                
                                vm.resetIsAddedStatus()
                                
                                vm.groupname = ""
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
                        
                        vm.filterForAddParticipants()
                        
                    }
                }
                
                if vm.searchAddParticipants == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterSuggestParticipant = vm.allSuggestUser
                        
                    }
                }
            }
        }
    }
    
    
    //MARK: - topAddParticipants
    private var topAddParticipants : some View {
        
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
            
            //Selected user list
            ScrollView(.horizontal) {
                
                HStack(spacing: 25){
                    
                    ForEach(vm.participantList){ user in
                        
                        VStack(spacing: 10){
                            
                            Button(action: {
                                
                                //1. Remove the user from participantList..
                                if let index = vm.participantList.firstIndex(where: { us in
                                    us.id == user.id
                                }) { vm.participantList.remove(at: index) }
                                
                                /*COMMENT*/
                                //2. Get location of the user on allSuggestUser..
                                // set isAdded value is false to change the User status is checkmark.green
                                
                                //Trạng thái isAdded phải change từ gốc suggestUser.
                                //Nếu change từ ngọn ở filterAddParticipants thì khi tìm kiếm, data load lại nó sẽ sai.
                                //Nên ta khóa hàm này lại, chuyển sang dùng hàm dưới.
                                //                                if let index = vm.filterAddParticipants.firstIndex(where: { us in
                                //                                    us.uid == user.uid
                                //                                }) { vm.filterAddParticipants[index].isAdded = false }
                                
                                if let index = vm.allSuggestUser.firstIndex(where: { us in
                                    
                                    us.id == user.id
                                    
                                }) { vm.allSuggestUser[index].isAdded = false }
                                
                                //3. Update.
                                vm.filterSuggestParticipant = vm.allSuggestUser
                                
                            }, label: {
                                
                                WebImage(url: URL(string: user.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .mask(Circle())
                                    .shadow(color: .purple, radius: 2)
                                    .overlay(
                                        Image(systemName: "minus")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(.pink)
                                            .clipShape(Circle())
                                            .offset(x: 20, y: -20)
                                    )
                            })
                            
                            Text(user.name)
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                            
                        }
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 3)
                
            }
        }
        .padding(.horizontal)
        
    }
    
    
    //MARK: - mainAddParticipants
    private var mainAddParticipants : some View {
        
        ScrollView{
            
            LazyVStack(alignment: .leading){
                
                ForEach(vm.filterSuggestParticipant) { user in
                    
                    Button {
                        
                        //Add user to participantList if it's not exists
                        if(isNotExist(user: user)) {
                            
                            vm.searchAddParticipants = ""
                            
                            //Add the user to participantList
                            vm.participantList.append(user)
                            
                            //Khóa hàm này vì lý do : xem ở /*COMMENT*/ ở trên
                            //                          if let index = vm.filterAddParticipants.firstIndex(where: { us in
                            //                              us.uid == user.uid
                            //                          }) { vm.filterAddParticipants[index].isAdded = true }
                            if let index = vm.allSuggestUser.firstIndex(where: { us in
                                us.id == user.id
                            }) { vm.allSuggestUser[index].isAdded = true }
                            vm.filterSuggestParticipant = vm.allSuggestUser
                            
                        }
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
                            
                            //                            Image(systemName: "plus.circle")
                            //                                .foregroundColor(.gray)
                            if user.isAdded {
                                
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .padding(2)
                                    .background(.green)
                                    .clipShape(Circle())
                                
                            } else {
                                
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .padding(2)
                                    .background(.gray)
                                    .clipShape(Circle())
                                
                            }
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
            
            return $0.id.contains(user.id)
            
        }
        
        return data.isEmpty ? true : false
        
    }
}


