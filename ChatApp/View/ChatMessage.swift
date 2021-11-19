//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 18/11/2021.
//

import SwiftUI

struct ChatMessage: View {
    
    @ObservedObject var vm = HomeViewModel()
    @State var txt : String = ""
    @Binding var isShowChat : Bool
    
    var body: some View {
        
        NavigationView{
            
            VStack {
                
//                topbarChat
                mainChat
                bottomChat
                
            }
            .navigationBarTitle("Chat", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                isShowChat.toggle()
            }, label: {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
            })
            )
        }
    }
    
    
    //MARK: - topbarChat
//    var topbarChat : some View {
//
//            HStack(spacing: 20) {
//
//                    Image(systemName: "person.fill")
//                        .font(.system(size: 25))
//                        .padding(10)
//                        .foregroundColor(.black)
//                        .background(
//                            Circle()
//                                .stroke(.black)
//                        )
//
//                Text("USERNAME")
//                    .font(.system(size: 20, weight: .bold))
//                    //.foregroundColor(.purple)
//
//                Spacer()
//            }
//            .padding(.horizontal)
//        }
    
    
    //MARK: - mainChat
    var mainChat : some View {
        
        ScrollView {
            Text("Content chat is show here")
            
        }
    }
    
    //MARK: - bottomChat
    var bottomChat : some View {
        
        HStack(spacing: 10) {
            
            TextField("Aa", text: $txt)
                .autocapitalization(.none)
                .padding()
                .background(.gray.opacity(0.1))
                .cornerRadius(45)
                .submitLabel(.send)

            Button {
        
            } label: {
                
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 30, weight: .bold))
                
            }
        }
        .padding(.horizontal)
    }
}
