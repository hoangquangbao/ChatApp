//
//  SignInUp.swift
//  ChatApp
//
//  Created by Quang Bao on 09/11/2021.
//

import SwiftUI

struct SignInUp: View {
    
    @State var isSignInMode = true
    @State var email : String = ""
    @State var username : String = ""
    @State var password :  String = ""
    @State var isHidePassword : Bool = true
    @State var signStatusMessenger : String = ""
    @State var isInvalidateEmailFormat : Bool = false
    
    
    @State var showAlert = true
    
    
    var body: some View {
        
        Picker("", selection: $isSignInMode) {
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
                
                TextField("Email", text: $email, onEditingChanged: { (isChanged) in
                    if !isChanged {
                        if !self.isValidEmail(self.email) {
                            signStatusMessenger = "Invalidate email format!"
                            
                            isInvalidateEmailFormat = true
                        }
                    }
                }
                )
                    .alert(isPresented: $isInvalidateEmailFormat) {
                        Alert(title: Text("Invalidate email format!"))
                    }
            }
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding()
            .background()
            .cornerRadius(45)
            .padding(.horizontal)
            
            
            if !isSignInMode {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.purple)
                    TextField(" User name", text: $username)
                    
                }
                .padding()
                .background()
                .cornerRadius(45)
                .padding(.horizontal)
            }
            
            VStack(alignment: .trailing) {
                
                HStack {
                    Image(systemName: "key.fill")
                        .foregroundColor(.purple)
                    
                    if isHidePassword {
                        SecureField(" Password ", text: $password)
                        
                    } else {
                        TextField(" Password ", text: $password)
                        
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
                
                if isSignInMode {
                    Button {
                        
                    } label: {
                        Text("Fogot your password ?")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.purple)
                            .padding(.trailing)
                    }
                }
            }
            
            Spacer(minLength: 20)
            
            Button {
                
            } label: {
                Text(isSignInMode ? "SIGN IN" : "SIGN UP")
                    .underline()
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.purple)
            }
        }
    }
    
    
    //MARK: - Validate Email Format
    func isValidEmail(_ string: String) -> Bool {
        
        if string.count > 100 {
            return false
        }

        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
//        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
    
    
    //MARK: - Show Alert error messenger
//    func showSimpleAlert() {
//
//        let alert = UIAlertController(title: "Sign out?", message: "You can always access your content by signing back in",         preferredStyle: UIAlertController.Style.alert)
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
//            return
//        }))
//        //self.present(alert, animated: true, completion: nil)
//    }
    
    
    //MARK: - Handle SIGNIN and SIGNUP option
    func handleSignOption() {
        
        if isSignInMode {
            
            print("SignIn")
        } else {
            
            print("SignUp")
        }
    }
    
}

struct SignInUp_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
