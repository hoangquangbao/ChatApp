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
            
            Spacer(minLength: 0)
            
            Image("LotusLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100, alignment: .center)
                .mask(Circle())
                .padding(.vertical)
                .shadow(color: .black, radius: 10)
            
            Text("Feel free to talk to your friends about anything!")
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .foregroundColor(.purple)
                .padding(.bottom)
            
            Spacer(minLength: 120)
            
            ScrollView {
                SignInUp()
            }
            //                    .background(
            //                        Image("BG")
            //                            .resizable()
            //                            .scaledToFill()
            //                            .ignoresSafeArea()
            //                            .blur(radius: 10)
            //                    )
        }
        .background(
            Image("BG1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 4)
        )
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
