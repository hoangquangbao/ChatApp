//
//  ResetPassword.swift
//  ChatApp
//
//  Created by Quang Bao on 29/11/2021.
//

import SwiftUI

struct ResetPassword: View {
    
    @ObservedObject var vm = HomeViewModel()
    @State var email : String = ""
    
    //Show error or caution
    @State var isShowAlert : Bool = false
    @State var alertMessage : String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
            
            VStack(alignment: .leading){
                
                Text("Reset password")
                    .font(.system(size: 30, weight: .bold))
                    .padding(.bottom, 10)
                
                Text("Enter your email and we'll send an email with instructions to reset your password.")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                
                Text("Email address")
                    .foregroundColor(.gray)
                    .padding(.bottom, 1)
                
                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .submitLabel(.go)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.purple, lineWidth: 1))
                    .padding(.bottom, 10)
                
                Button {
                    
                    if !vm.isValidEmail(self.email) {
                        
                        isShowAlert.toggle()
                        alertMessage = "Invalidate email format!"
                        
                    } else {
                        
                        FirebaseManager.shared.auth.sendPasswordReset(withEmail: email) { error in
                            
                            isShowAlert = true
                            alertMessage = error?.localizedDescription ?? "Success. Reset email send successfully, check your email."
                            
                        }
                    }
                    
                } label: {
                    
                    Text("Reset")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.purple)
                        .cornerRadius(10)
                }
                
                Spacer()
                
            }
            .padding(.horizontal)
            .navigationBarItems(leading:
                                    Button(action: {
                //presentationMode.wrappedValue.dismiss()
                vm.isShowResetPasswordView = false
            }, label: {
                
                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.purple)
                
            })
            )
            .alert(isPresented: $isShowAlert) {
                
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("Got it!")))
                
            }
        }
    }
}

struct ResetPassword_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ResetPassword()
        
    }
}
