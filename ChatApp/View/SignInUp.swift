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
    //Upload image to Firebase
    let storage : Storage
    let firestore : Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        
        FirebaseApp.configure()
        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
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
    @State var alertMessage : String = ""
    
    //Get Avatar Image
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    
    //DashboardMessenge
    @State var isShowDashboardMessenge : Bool = false
    
    
    
    //    init() {
    //        FirebaseApp.configure()
    //    }
    
    var body: some View {
        
       // NavigationView {
            
            //VStack {
                Picker("", selection: $isSignInMode) {
                    Text("SIGN IN")
                        .tag(true)
                    Text("SIGN UP")
                        .tag(false)
                }.pickerStyle(.segmented)
                    .padding(.horizontal)
                .padding(.bottom)
//                .shadow(color: .white, radius: 5)
                
                VStack(spacing: 30) {
                    
                    if !isSignInMode {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.purple)
                            TextField("User name", text: $username)
                        }
                        .autocapitalization(.none)
                        .padding()
                        //                .background()
                        //                .cornerRadius(45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30).stroke(Color.purple, lineWidth: 1)
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
                                            .frame(width: 55, height: 55)
                                            .mask(Circle())
                                    } else {
                                        Image(systemName: "person.crop.circle.badge.plus")
                                            .padding()
                                            .foregroundColor(.gray)
                                    }
                                }
                                .overlay(RoundedRectangle(cornerRadius: 27)
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
                                    alertMessage = "Invalidate email format!"
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
                        RoundedRectangle(cornerRadius: 30).stroke(Color.purple, lineWidth: 1)
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
                            RoundedRectangle(cornerRadius: 30).stroke(Color.purple, lineWidth: 1)
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
                .alert(isPresented: $isShowAlert) {
                    //Alert(title: Text(alertMessenger))
                    Alert(title: Text("Messenger"), message: Text(alertMessage), dismissButton: .default(Text("Got it!")))
                }
                .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                    ImagePicker(image: $image)
                    //                .ignoresSafeArea()
                }
//                .sheet(isPresented: $isShowDashboardMessenge, onDismiss: nil) {
//                    DasboardMessenge()
//                }
                .fullScreenCover(isPresented: $isShowDashboardMessenge) {
                    DasboardMessenge()
                }
            //}
        //}
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
                        alertMessage = err.localizedDescription
                        return
                    } else {
                        isShowDashboardMessenge.toggle()
                    }
            }
    }
    
    
    //MARK: - SignUp
    func signUp() {
                
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            
            if let err = err {
                
                isShowAlert = true
                alertMessage = err.localizedDescription
                return
            }
            
            //Auto move SIGN IN tab...
            isSignInMode = true
            
            //...and show alert successfully created
            isShowAlert = true
            alertMessage = "Your account has been successfully cereated!"
            
            //Upload image to Firebase
            uploadImageToStorage()
        }
    }
    
    //MARK: - This will upload images into Storage and prints out the locations as well
    func uploadImageToStorage() {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            let ref = FirebaseManager.shared.storage.reference(withPath: uid)
            guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
            ref.putData(imageData, metadata: nil) { metadata, err in
                if let err = err {
//                    alertMessenger = "Failed to push image to Storage: \(err)"
                    isShowAlert = true
                    alertMessage = err.localizedDescription
                    return
                }

                ref.downloadURL { url, err in
                    if let err = err {
//                        alertMessenger = "Failed to retrieve downloadURL: \(err)"
                        isShowAlert = true
                        alertMessage = err.localizedDescription
                        return
                    }

//                    alertMessenger = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                    
                    guard let url = url else { return }
                    storeUserInformation(imageProfileUrl: url)
//                    print(url.absoluteString)
                }
            }
        }
    
    //MARK: - This will save newly created users to Firestore database collections
    func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["username": username,"email": email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    isShowAlert = true
                    alertMessage = err.localizedDescription
                    return
                }
                print("Success")
            }
    }
}

struct SignInUp_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
