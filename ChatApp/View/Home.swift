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
            
            Text("Feel free to talk to your friends about anything!")
                .font(.system(size: 11, weight: .semibold))
                .padding(.bottom)
            
            NavigationView {
                    
                    ScrollView {
                        SignInUp()
                    }
                    .background(
                        Image("BG3")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    )
                    .edgesIgnoringSafeArea(.bottom)
            }
            .cornerRadius(20)
            .shadow(color: .black, radius: 10)
        }
        //.edgesIgnoringSafeArea(.bottom)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
