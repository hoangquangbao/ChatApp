//
//  Home.swift
//  ChatApp
//
//  Created by Quang Bao on 09/11/2021.
//

import SwiftUI

struct Home: View {
    
    @State var isSignMode : Bool = false
    
    
    var body: some View {
        
        VStack {
            Image("LotusLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100, alignment: .center)
                .mask(Circle())
                .padding(.bottom)
                .shadow(color: .purple, radius: 10)
            
            Text("Be carefull talk with your friend anything!")
                .font(.system(size: 10, weight: .semibold, design: .serif))
                .padding(.bottom)
            
            NavigationView {
                    
                    ScrollView {
                        SignInUp()
                    }
                    //.shadow(color: .gray, radius: 3)
                    .background(
                        Image("BG3")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            //.blur(radius: 5)
                    )
                    .edgesIgnoringSafeArea(.bottom)
            }
            .cornerRadius(20)
            .shadow(color: .purple, radius: 10)
        }
//        .background(
//            Image("BG4")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//                .blur(radius: 1)
//        )
        //.edgesIgnoringSafeArea(.bottom)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
