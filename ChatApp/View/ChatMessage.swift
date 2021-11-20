//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 18/11/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatMessage: View {
    
    @ObservedObject var vm = HomeViewModel()
    @State var txt : String = ""
    @State var friend : User?
    @State var search : String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
            
            VStack {
                
                topbarChat
                mainChat
                bottomChat
                
            }
            .navigationBarHidden(true)
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
    }
    
    
    //MARK: - topbarChat
    var topbarChat : some View {
        
        VStack{
            
            HStack(spacing: 15) {
                
                Group{
                    
                    if friend?.profileImageUrl != nil{
                        
                        WebImage(url: URL(string: friend?.profileImageUrl ?? ""))
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
                    
                    Text("\(friend?.username ?? "")")
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
                 .frame(height: 2)
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
            
            Text("Haven't any message. Start now!")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            
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
            
            TextField("Aa", text: $txt)
                .autocapitalization(.none)
                .submitLabel(.send)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(45)

            Button {
        
            } label: {
                
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20, weight: .bold))
                
            }
        }
        .padding(.horizontal)
    }
}
