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
    @State var isHidePassword : Bool = true
    
    var body: some View {
        
        VStack {
            
            if vm.isShowActivityIndicator {
                
                signView.overlay(
                    
                    ActivityIndicator()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                    
                )
            } else {
                
                signView
                
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $vm.isShowAlert) {
            Alert(title: Text("Messenger"), message: Text(vm.alertMessage), dismissButton: .default(Text("Got it!")))
        }
    }
    
    
    //MARK: - signView
    private var signView : some View{
        
        ScrollView{
            
            Image("ImageSignInUpPage")
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250, alignment: .center)
                .mask(Circle())
                .padding()
                .shadow(color: .white, radius: 2)
            
            Picker("", selection: $vm.isSignInMode) {
                
                Text("SIGN IN")
                    .tag(true)
                
                Text("SIGN UP")
                    .tag(false)
                
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
            //Reset item value if transfer tab SIGN IN <=> SIGN UP
            .onChange(of: vm.isSignInMode) { newValue in
                
                vm.username = ""
                vm.email = ""
                vm.password = ""
                vm.profileImage = nil
                
            }
            
            VStack(spacing: 30) {
                
                if !self.vm.isSignInMode {
                    
                    HStack {
                        
                        Image(systemName: "person.fill")
                            .foregroundColor(.purple)
                        TextField("User name", text: $vm.username)
                        
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.done)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 30).stroke(Color.purple, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .overlay (
                        //Add avatar in here
                        Button {
                            
                            vm.isShowImagePicker = true
                            
                        } label: {
                            
                            VStack {
                                
                                if let image = vm.profileImage {
                                    
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
                .disableAutocorrection(true)
                .submitLabel(.done)
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
                    .disableAutocorrection(true)
                    .submitLabel(.done)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 30).stroke(Color.purple, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    if vm.isSignInMode {
                        
                        Button {
                            
                            vm.isShowResetPasswordView = true
                            
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
                    
                    Text(vm.isSignInMode ? "SIGN IN" : "SIGN UP")
                        .underline()
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.purple)
                    
                }
            }
            .fullScreenCover(isPresented: $vm.isShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $vm.profileImage)
            }
            .fullScreenCover(isPresented: $vm.isShowMainMessage) {
                MainMessage()
            }
            .fullScreenCover(isPresented: $vm.isShowResetPasswordView) {
                ResetPassword()
            }
        }
    }
    
    
    //MARK: - Handle SIGNIN and SIGNUP option
    func handleSignOption() {
        
        if vm.isSignInMode {
            
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
