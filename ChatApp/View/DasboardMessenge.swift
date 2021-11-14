//
//  DasboardMessenge.swift
//  ChatApp
//
//  Created by Quang Bao on 14/11/2021.
//

import SwiftUI

struct DasboardMessenge: View {
    @State var isShowSetting : Bool = false
    
    var body: some View {
        
        VStack {
            topbarMessenges
            messengesView
            newMessenge
        }
    }
    
    //MARK: - topbarMessenges
    var topbarMessenges : some View {
        
        HStack(spacing: 20) {
            
            Image(systemName: "person.fill")
                .font(.system(size: 25))
            
            VStack(alignment: .leading, spacing: 5) {
                
                Text("USERNAME")
                    .font(.system(size: 25, weight: .bold))
                
                HStack {
                    
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.green)
                    
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button {
                
                isShowSetting.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
        .actionSheet(isPresented: $isShowSetting) {
            ActionSheet(
                title: Text("Setting"),
                message: Text("What do you want to do?"),
                buttons: [
                    .cancel(),
                    .destructive(
                        Text("Switch account"),
                        action: {
                            print("Switch account")
                            
                        }),
                    .destructive(
                        Text("Sign Out"),
                        action: {
                            print("Sign Out")
                            
                        })
            ])
        }
    }
    
    //MARK: - messengesView
    var messengesView : some View {
        
        ScrollView {
            
            VStack(spacing: 30){
                
                ForEach(1...20, id: \.self) { userNumber in
                    
                    HStack(spacing: 10){
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.purple)
                            .padding(10)
                            .background(
                                Circle()
                                    .stroke(.purple, lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading, spacing: 4){
                            
                            Text("Username")
                                .font(.system(size: 17, weight: .bold))
                            
                            Text("Messenge send to user")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("22d")
                            .font(.system(size: 12))
                    }
                }
            }
            .padding()
        }
    }
    
    //MARK: - newMessenge
    var newMessenge : some View {
        
        Button {
            
        } label: {
            
            HStack {
                
                Spacer()
                
                Text("+ New Message")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(45)
                
                Spacer()
            }
//                .padding()
//                .background(.purple)
//                .cornerRadius(45)
            .padding(.horizontal)
        }
    }
}

struct DasboardMessenge_Previews: PreviewProvider {
    static var previews: some View {
        DasboardMessenge()
    }
}
