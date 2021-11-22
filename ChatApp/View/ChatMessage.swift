//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 18/11/2021.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ChatMessage: View {
    
    @ObservedObject var vm = HomeViewModel()
    @State var text : String = ""
    @State var selectedUser : User?
    @State var search : String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
//    init(){
//        vm.getMessage(friend: friend)
//    }
        
    var body: some View {
        
        NavigationView{
            
            VStack {
                
                topbarChat
                mainChat
                bottomChat
                
            }
            .navigationBarHidden(true)
//            .onAppear{
//
//                vm.getMessage(selectedUser: selectedUser)
//
//            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        //        .navigationBarTitle("\(friend?.username ?? "Chat")", displayMode: .inline)
        //        .navigationBarItems(leading:
        //                                Button(action: {
        //            presentationMode.wrappedValue.dismiss()
        //        }, label: {
        //            Image(systemName: "arrow.backward")
        //                .font(.system(size: 15, weight: .bold))
        //        })
        //        )
//        .onAppear {
//
//            vm.getMessage(friend: friend)
//
//        }
    }
    
    
    //MARK: - topbarChat
    var topbarChat : some View {
        
        VStack{
            
            HStack(spacing: 15) {
                
                Group{
                    
                    if selectedUser?.profileImageUrl != nil{
                        
                        WebImage(url: URL(string: selectedUser?.profileImageUrl ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .mask(Circle())
                        
                    } else {
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 25))
                            .padding(10)
                            .foregroundColor(.black)
                            .background(
                                Circle()
                                    .stroke(.black)
                            )
                        
                    }
                }
                .shadow(color: .gray, radius: 2)
                
                VStack(alignment: .leading ,spacing: 5){
                    
                    Text("\(selectedUser?.username ?? "")")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    HStack(spacing: 5){
                        
                        Image(systemName: "circle.fill")
                            .frame(width: 10, height: 10)
                            .mask(Circle())
                            .foregroundColor(.green)
                        
                        Text("Online Now")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        
                    }
                }
                
                Spacer()
                
                Button {
                    
                    presentationMode.wrappedValue.dismiss()
                    
                } label: {
                    
                    Image(systemName: "multiply")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.gray)
                    
                }
            }
            .padding(.bottom, 20)
            
            VStack{
                
                TextField("Search in chat", text: $search)
                
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 30)
                    .background(Color.gray)
                
            }
            .padding(.vertical)
            
        }
        .padding(.horizontal)
    }
    
    
    //MARK: - mainChat
    var mainChat : some View {
        
        ScrollView {
            
//            if vm.allMessage.count == 0{
//
//                Spacer()
////                Indicator()
//                            Text("Haven't any message. Start now!")
//                Spacer()
                
//            } else {
                ForEach(vm.allMessage){ i in
                    
                    Text(i.text)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
        
//                }

            }
        }
    }
    
    
    //MARK: - bottomChat
    var bottomChat : some View {
        
        HStack(spacing: 10) {
            
            Button {
                
            } label: {
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.gray)
                
            }
            
            TextField("Aa", text: $text)
                .autocapitalization(.none)
                .submitLabel(.send)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(45)
            
            Button {
                
                vm.sendMessage(selectedUser: selectedUser, text: text)
                text = ""
                
            } label: {
                
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20, weight: .bold))
                
            }
        }
        .padding(.horizontal)
    }
    
//    func readMsg() {
//
//        FirebaseManager.shared.firestore.collection("message").addSnapshotListener { snap, err in
//
//            if err != nil{
//                print(err?.localizedDescription)
//                return
//            }
//            guard let data = snap else {return}
//
//            data.documentChanges.forEach { doc in
//                if doc.type == .added{
//                    let msg = try! doc.document.data(as: Message.self)
//
//                    DispatchQueue.main.async {
//                        self.msgs.append(msg)
//                    }
//                }
//            }
//        }
//
//    }
}
