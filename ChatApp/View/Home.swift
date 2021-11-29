//
//  Home.swift
//  ChatApp
//
//  Created by Quang Bao on 09/11/2021.
//

import SwiftUI
import Firebase

struct Home: View {
    
    @ObservedObject var vm = HomeViewModel()
    @State var isSignInMode : Bool = true

//    @EnvironmentObject var vm : HomeViewModel
//    @StateObject var vm = HomeViewModel()

    @State var isHidePassword : Bool = true
    
    //Show error or caution
//    @State var isShowAlert : Bool = false
//    @State var alertMessage : String = ""
    
    //Show image library to change Avatar
//    @State var shouldShowImagePicker = false
//    @State var image: UIImage?
    
//    //Show MainMessage Page
//    @State var isShowMainMessageView : Bool = false
    
    //Show ResetPassword Page
    @State var isShowResetPasswordView : Bool = false
    
    var body: some View {
            
            VStack {
                
                Image("ImageSignInUpPage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 250, alignment: .center)
                    .mask(Circle())
                    .padding()
                    .shadow(color: .white, radius: 2)
                signView
            }
            .navigationBarHidden(true)
            .alert(isPresented: $vm.isShowAlert) {
                Alert(title: Text("Messenger"), message: Text(vm.alertMessage), dismissButton: .default(Text("Got it!")))
            }
    }
    
    
    //MARK: - signView
    private var signView : some View{
        
        ScrollView{
            
            Picker("", selection: $isSignInMode) {
                
                Text("SIGN IN")
                    .tag(true)
                
                Text("SIGN UP")
                    .tag(false)
                
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
            
            VStack(spacing: 30) {
                
                if !self.isSignInMode {
                    
                    HStack {
                        
                        Image(systemName: "person.fill")
                            .foregroundColor(.purple)
                        TextField("User name", text: $vm.username)
                        
                    }
                    .autocapitalization(.none)
                    .submitLabel(.go)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 30).stroke(Color.purple, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .overlay (
                        //Add avatar in here
                        Button {
                            
                            vm.isShowImagePicker.toggle()
                            
                        } label: {
                            
                            VStack {
                                
                                if let image = vm.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 55, height: 55)
                                        .mask(Circle())
                                    
                                } else {
                                    
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .padding()
                                        .foregroundColor(.gray)
                                    
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 30)
                                        .stroke(.purple, lineWidth: 1)
                            )
                        }
                            .padding()
                        ,alignment: .trailing
                    )
                }
                
                HStack {
                    
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.purple)
                    
                    TextField("Email", text: $vm.email, onEditingChanged: { isChanged in
                        if !isChanged {
                            
                            if !vm.isValidEmail(vm.email) {
                                
                                vm.isShowAlert = true
                                vm.alertMessage = "Invalidate email format!"
                                
                            }
                        }
                    }
                    )
                }
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .submitLabel(.go)
                .padding()
                //.background()
                //.cornerRadius(45)
                .overlay(
                    
                    RoundedRectangle(cornerRadius: 30).stroke(Color.purple, lineWidth: 1)
                    
                )
                .padding(.horizontal)
                //.shadow(color: .purple, radius: 1)
                
                VStack(alignment: .trailing) {
                    
                    HStack {
                        
                        Image(systemName: "key.fill")
                            .foregroundColor(.purple)
                        
                        if isHidePassword {
                            
                            SecureField(" Password ", text: $vm.password)
                            
                        } else {
                            
                            TextField(" Password ", text: $vm.password)
                            
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
                    .submitLabel(.go)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 30).stroke(Color.purple, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    if isSignInMode {
                        
                        Button {
                            
                            isShowResetPasswordView.toggle()
                            
                        } label: {
                            
                            Text("Fogot your password ?")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.purple)
                                .padding(.trailing)
                            
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    
                    handleSignOption()
                    
                } label: {
                    
                    Text(isSignInMode ? "SIGN IN" : "SIGN UP")
                        .underline()
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.purple)
                    
                }
            }
            .fullScreenCover(isPresented: $vm.isShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $vm.image)
            }
            .fullScreenCover(isPresented: $vm.isShowMainMessageView) {
                MainMessage()
            }
            .fullScreenCover(isPresented: $isShowResetPasswordView) {
                ResetPassword()
            }
        }
    }
    
    
    //MARK: - Handle SIGNIN and SIGNUP option
    func handleSignOption() {
        
        if isSignInMode {
            
            vm.signIn()
            
        } else {
            
            vm.signUp()
                
        }
    }
}

struct Home_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Home()
        
    }
}
