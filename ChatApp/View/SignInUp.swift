//
//  SignInUp.swift
//  ChatApp
//
//  Created by Quang Bao on 09/11/2021.
//

import SwiftUI

struct SignInUp: View {
    
    @State var isSignMode = false
    @State var email : String = ""
    @State var username : String = ""
    @State var password :  String = ""
    @State var isHidePassword : Bool = true
    
    
    var body: some View {
        
        Picker("", selection: $isSignMode) {
            Text("SIGN IN")
                .tag(true)
            Text("SIGN UP")
                .tag(false)
        }.pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
        
        VStack(spacing: 30) {
            
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.purple)
                TextField("Email", text: $email)
                
            }
            .padding()
            .background()
            .cornerRadius(45)
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.purple)
                TextField(" User name", text: $username)
                
            }
            .padding()
            .background()
            .cornerRadius(45)
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.purple)
                
                if isHidePassword {
                    SecureField("Password ", text: $password)
                    
                } else {
                    TextField("Password ", text: $password)
                    
                }
                Button(action: {
                    isHidePassword.toggle()
                }) {
                    Image(systemName: self.isHidePassword ? "eye.slash" : "eye")
                        .accentColor(.gray)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background()
            .cornerRadius(45)
            .padding(.horizontal)
            .padding(.bottom,50)
            
            Button {
                
            } label: {
                Text("SIGN UP")
                    .underline()
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.purple)
            }
        }
    }
}

struct SignInUp_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
