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
    @Binding var isShowNewMessage : Bool
    @Binding var isShowChat : Bool
    
    @Environment(\.presentationMode) var presentationMode
//    let didSelectNewUser : (User) -> ()

    
//    init(){
//        vm..fetchAllUsers()
//    }
    //    init() {
    //        vm.fetchAllUser()
    //        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 20)!]
    //    }
    
    var body: some View {
        
        NavigationView{
            VStack{
                topbarNewMassage
                mainNewMessage
            }
            .navigationBarTitle("New Message", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
//                self.isShowNewMessage.toggle()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
            })
            )
        }
    }
    
    //MARK: - topbarNewMessage
    private var topbarNewMassage : some View {
        HStack {
            Text("To: ")
                .foregroundColor(.gray)
            TextField("Type a name", text: $searchUser)
                .autocapitalization(.none)
                .submitLabel(.search)
        }
        .padding(15)
        .background(.gray.opacity(0.08))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    //MARK: - mainNewMessage
    private var mainNewMessage : some View {

        VStack(alignment: .leading){
            Text("Suggested")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            ScrollView{
                ForEach(vm.allUser) { user in
                    Button {
//                        didSelectNewUser(user)
                        isShowChat.toggle()
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
//                        NavigationLink(destination: ChatMessage(friend: user, isShowChat: $isShowChat), isActive: $isShowChat) {
//                            EmptyView()
//                        }
                    }
                    .padding(.vertical, 10)
                    .fullScreenCover(isPresented: $isShowChat, onDismiss: nil) {
                        ChatMessage(friend: user, isShowChat: $isShowChat)
                    }

                }
            }

            

            //                    .navigationTitle("New Messages")
            //                    .toolbar {
            //                        ToolbarItemGroup(placement: .navigationBarLeading) {
            //                            Button {
            //                                presentationMode.wrappedValue.dismiss()
            //                            } label: {
            //                                Image(systemName: "arrow.backward")
            //                                    .font(.system(size: 20, weight: .bold))
            //                            }
            //                        }
            //                    }
            
        }
    }
}

