//
//  GroupChat.swift
//  ChatApp
//
//  Created by Quang Bao on 17/12/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupChat: View {
    
    @ObservedObject var vm = HomeViewModel()
    @State var selectedGroup : GroupUser?
    @State var imageGroup: UIImage?
    @State var text : String = ""
    @State var isShowImagePickerMessage : Bool = false
    @State var imgMessage : Data = Data(count: 0)
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
            
            VStack {
                
                topGroupChat
                mainGroupChat
                if vm.isShowActivityIndicator {
                    
                    bottomGroupChat.overlay(
                        ActivityIndicator()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                        
                    )
                } else {
                    
                    bottomGroupChat
                    
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $vm.isShowGroupDetail, onDismiss: nil, content: {
                GroupDetail(vm: vm, selectedGroup: selectedGroup)
            })
            .fullScreenCover(isPresented: $vm.isShowImagePickerGroup, onDismiss: {
                
                if imageGroup != nil
                {
                    
                    //Activate activity indicator..
                    //..true: when start send Image Message (bottomChat)
                    //..false: when fetchMessage success (fetchMessage)
                    vm.isShowActivityIndicator = true
                    
                    vm.uploadImageMessageOfGroup(selectedGroup: selectedGroup, text: "", imageGroup: imageGroup)
                    
                }
                
            }) {
                
                ImagePickerGroup(imageGroup: $imageGroup)
                
            }
            .onChange(of: vm.searchChat) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if newValue == vm.searchChat && vm.searchChat != "" {
                        //Check func in here
                        vm.filterForChat()
                        
                    }
                }
                
                if vm.searchChat == ""{
                    
                    //do nothing
                    withAnimation(.linear){
                        vm.filterAllMessages = vm.allMessages
                        
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        
    }
    
    
    //MARK: - topGroupChat
    private var topGroupChat : some View {
        
        VStack{
            
            HStack(spacing: 15) {
                
                Button {
                    
                    vm.searchChat = ""
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.async {
                        vm.isShowNewGroup = false
                    }
                    
                } label: {
                    
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.purple)
                    
                }
                
                WebImage(url: URL(string: selectedGroup?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .mask(Circle())
                    .shadow(color: .black, radius: 2)
                
                VStack(alignment: .leading, spacing: 5){
                    
                    Text(selectedGroup!.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    Text("\(selectedGroup!.member.count) participants")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                }
                
                Spacer()
                
                Button {
                    
                    vm.fetchMemberList(selectedGroup: selectedGroup)
                    vm.isShowGroupDetail = true
                    
                } label: {
                    
                    Image(systemName: "info.circle")
                        //.padding(8)
                        .foregroundColor(.purple)
                        .font(.system(size: 20))
                        //.background(.purple)
                        //.mask(Circle())
                    
                }
            }
            .padding(.bottom, 15)
            
            VStack{
                
                TextField("Search in chat", text: $vm.searchChat)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Divider()
                //                    .frame(height: 1)
                //                    .padding(.horizontal, 30)
                //                    .background(Color.gray)
                
            }
            .padding(.vertical)
            
        }
        .padding(.horizontal)
        
    }
    
    
    //MARK: - mainGroupChat
    private var mainGroupChat : some View {
        
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(vm.filterAllMessages){ content in
                        VStack() {
                            
                            if content.fromId == vm.currentUser?.id {
                                
                                HStack() {
                                    
                                    Spacer()
                                    
                                    //If text == "", it's a photo
                                    let text = content.text
                                    if text == "" {
                                        
                                        WebImage(url: URL(string: content.imgMessage ))
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(15)
                                            .frame(maxWidth: UIScreen.main.bounds.width - 150)
                                        
                                    } else {
                                        
                                        Text(text)
                                            .padding()
                                            .background(Color("BG_Chat"))
                                            .clipShape(ChatBubble(mymsg: true))
                                            .foregroundColor(.white)
                                        
                                    }
                                }
                            } else {
                                
                                HStack(alignment: .bottom){
                                    
                                    let memberGroup = vm.getUserInfo(selectedObjectId: content.fromId)
                                    let firstName = getFirstName(name: memberGroup.name)
                                    
                                    WebImage(url: URL(string: memberGroup.profileImageUrl ))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 25, height: 25)
                                        .mask(Circle())
                                    
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        
                                        //If text == "", it's a photo
                                        let text = content.text
                                        if text == "" {
                                            
                                            WebImage(url: URL(string: content.imgMessage ))
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(15)
                                                .frame(maxWidth: UIScreen.main.bounds.width - 150)
                                                .padding(.leading, 0)
                                            //.scaledToFit()
                                            //                                                .padding(.top)
                                            
                                        } else {
                                            
                                            Text(text)
                                                .padding()
                                                .background(Color.gray.opacity(0.2))
                                                .clipShape(ChatBubble(mymsg: false))
                                            
                                        }
                                        
                                        Text(firstName)
                                            .foregroundColor(.gray)
                                            .font(.system(size: 8))
                                        
                                    }
                                    
                                    Spacer()
                                    
                                }
                            }
                        }
                        .padding(.horizontal)
                        .contextMenu{
                            
                            Button {
                                
                                let memberGroup = vm.getUserInfo(selectedObjectId: content.fromId)
                                vm.deleteMessage(selectedUser: memberGroup, selectedMessage: content)
                                
                            } label: {
                                
                                Text("Remove")
                                
                            }
                        }
                    }
                }
                .rotationEffect(.degrees(180))
                
            }
            .rotationEffect(.degrees(180))
            
        }
    }
    
    
    //MARK: - bottomGroupChat
    private var bottomGroupChat : some View {
        
        HStack(spacing: 10) {
            
            Button {
                
                vm.isShowImagePickerGroup = true
                
            } label: {
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.purple)
                
            }
            
            TextField("Aa", text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.done)
                .background()
                .onSubmit {
                    
                    if !text.isEmpty{
                        
                        vm.sendGroupMessage(selectedGroup: selectedGroup!, text: text, imgMessage: "")
                        text = ""
                        
                    }
                }
            
            //Hidding Send button
            if !text.isEmpty{
                
                Button {
                    
                    vm.sendGroupMessage(selectedGroup: selectedGroup!, text: text, imgMessage: "")
                    text = ""
                    
                } label: {
                    
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.purple)
                    
                }
            }
        }
        .padding()
        .background()
        .cornerRadius(45)
        .padding(.horizontal)
        .animation(.easeOut)
        
    }
    
    
    //MARK: - getFirstName
    func getFirstName(name: String) -> String {
        
        var components = name.components(separatedBy: " ")
        
        if components.count > 0{
            
            let firstName = components.removeFirst()
            return firstName
            
        }
        return name
        
    }
    
    
//    func dismissTo(vc: UIViewController?, count: Int?, animated: Bool, completion: (() -> Void)? = nil) {
//        var loopCount = 0
//        var dummyVC: UIViewController? = self
//        for _ in 0..<(count ?? 100) {
//            loopCount = loopCount + 1
//            dummyVC = dummyVC?.presentingViewController
//            if let dismissToVC = vc {
//                if dummyVC != nil && dummyVC!.isKind(of: dismissToVC.classForCoder) {
//                    dummyVC?.dismiss(animated: animated, completion: completion)
//                }
//            }
//        }
//
//        if count != nil {
//            dummyVC?.dismiss(animated: animated, completion: completion)
//        }
//    }
}
