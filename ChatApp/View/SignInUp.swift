//
//  SignInUp.swift
//  ChatApp
//
//  Created by Quang Bao on 09/11/2021.
//

import SwiftUI
import Firebase

class FirebaseManager : NSObject {
    
    let auth : Auth
    
    static let shared = FirebaseManager()
    
    override init() {
        
        FirebaseApp.configure()
        self.auth = Auth.auth()
        super.init()
    }
}

struct SignInUp: View {
    
    @State var isSignInMode = true
    @State var email : String = ""
    @State var username : String = ""
    @State var password :  String = ""
    @State var isHidePassword : Bool = true
    @State var isShowAlert : Bool = false
    @State var alertMessenger : String = ""
    
    //Avatar Image
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    
    
    //    init() {
    //        FirebaseApp.configure()
    //    }
    
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
            
            if !isSignInMode {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.purple)
                    TextField("User name", text: $username)
                }
                .padding()
                //                .background()
                //                .cornerRadius(45)
                .overlay(
                    RoundedRectangle(cornerRadius: 45).stroke(Color.purple, lineWidth: 1)
                )
                .padding(.horizontal)
                //                .shadow(color: .purple, radius: 1)
                //                .overlay(
                //                    RoundedRectangle(cornerRadius: 45).stroke(Color.purple, lineWidth: 1)
                //                )
                .overlay (
                    //Add avatar in here
                    Button {
                        
                        shouldShowImagePicker.toggle()
                    } label: {
                        VStack {
                            if let image = self.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .mask(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .padding()
                                    .foregroundColor(.gray)
                            }
                        }
                        .overlay(RoundedRectangle(cornerRadius: 45)
                                    .stroke(.gray, lineWidth: 1)
                        )
                    }
                        .padding()
                    ,alignment: .trailing
                )
            }
            
            HStack {
                
                Image(systemName: "envelope.fill")
                    .foregroundColor(.purple)
                
                TextField("Email", text: $email, onEditingChanged: { (isChanged) in
                    if !isChanged {
                        if !self.isValidEmail(self.email) {
                            isShowAlert = true
                            alertMessenger = "Invalidate email format!"
                        }
                    }
                }
                )
            }
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding()
            //.background()
            //.cornerRadius(45)
            .overlay(
                RoundedRectangle(cornerRadius: 45).stroke(Color.purple, lineWidth: 1)
            )
            .padding(.horizontal)
            //.shadow(color: .purple, radius: 1)
            
            
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
                .autocapitalization(.none)
                .padding()
                //                .background()
                //                .cornerRadius(45)
                .overlay(
                    RoundedRectangle(cornerRadius: 45).stroke(Color.purple, lineWidth: 1)
                )
                .padding(.horizontal)
                //                .shadow(color: .purple, radius: 1)
                
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
                
                handleSignOption()
            } label: {
                Text(isSignInMode ? "SIGN IN" : "SIGN UP")
                    .underline()
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.purple)
            }
        }
        .alert(isPresented: $isShowAlert) {
            //Alert(title: Text(alertMessenger))
            Alert(title: Text("Messenger"), message: Text(alertMessenger), dismissButton: .default(Text("Got it!")))
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
            //                .ignoresSafeArea()
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
    
    
    //MARK: - Handle SIGNIN and SIGNUP option
    func handleSignOption() {
        
        if isSignInMode {
            
            signIn()
        } else {
            
            signUp()
        }
    }
    
    
    //MARK: - SignIn
    func signIn() {
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            
            if let err = err {
                
                isShowAlert = true
                alertMessenger = err.localizedDescription
                return
            }
        }
    }
    
    
    //MARK: - SignUp
    func signUp() {
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            
            if let err = err {
                
                isShowAlert = true
                alertMessenger = err.localizedDescription
                return
            }
            
            //Auto move SIGN IN tab...
            isSignInMode = true
            
            //...and show alert successfully created
            isShowAlert = true
            alertMessenger = "Your account has been successfully cereated!"
        }
    }
}

struct SignInUp_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
