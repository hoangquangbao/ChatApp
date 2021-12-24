//
//  GroupDetail.swift
//  ChatApp
//
//  Created by Quang Bao on 23/12/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupDetail: View {
    
    @ObservedObject var vm = HomeViewModel()
    @State var selectedGroup : GroupUser?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                
                topGroupDetail
                mainGroupDetail
                
            }
            .navigationBarItems(leading:
                                    Button(action: {
                
                presentationMode.wrappedValue.dismiss()
                
            }, label: {
                
                Image(systemName: "arrow.backward")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.purple)
                
            })
            )
        }
    }
    
    
    //MARK: - topGroupDetail
    private var topGroupDetail: some View {
        
        VStack{
            
            WebImage(url: URL(string: selectedGroup?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .mask(Circle())
                .shadow(color: .black, radius: 2)
            
            Text(selectedGroup!.name)
                .font(.system(size: 25, weight: .bold, design: .rounded))
            
        }
    }
    
    
    //MARK: - mainGroupDetail
    private var mainGroupDetail: some View {
        
        ScrollView{
            
            LazyVStack(alignment: .leading){
                
                Text("Members")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding()
                
                ForEach(vm.allMember){ user in
                    HStack(spacing: 15){
                        
                        WebImage(url: URL(string: user.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 45)
                            .mask(Circle())
                            .shadow(color: .purple, radius: 2)
                        
                        Text(user.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                    }
                    .padding()
                }
            }
        }
    }
}
