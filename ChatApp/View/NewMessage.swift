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
    @Environment(\.presentationMode) var presentationMode
    @State var searchUser : String = ""
    
//    init() {
//        fetchAllUsers()
//    }
    
    init() {
        vm.fetchAllUser()
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 20)!]
    }
    
    var body: some View {
        NavigationView{
            VStack{
                HStack {
                    Text("To: ")
                        .foregroundColor(.gray)
                    TextField("Type a name", text: $searchUser)
                        .autocapitalization(.none)
                }
                .padding(15)
                .background(.gray.opacity(0.08))
                .cornerRadius(10)
                
                VStack(alignment: .leading){
                    Text("Suggested")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    ScrollView{
                        ForEach(vm.allUser) { user in
                            
                            Button {
                                
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
                            .padding(.vertical, 10)
                        }
                    }
                    .navigationTitle("New Messages")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "arrow.backward")
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                    }
                }
            }
        }
        
    }
}

struct NewMessages_Previews: PreviewProvider {
    static var previews: some View {
        NewMessage()
    }
}
