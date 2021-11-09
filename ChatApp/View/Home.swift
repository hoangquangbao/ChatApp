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
                .frame(width: 120, height: 120, alignment: .center)
                .mask(Circle())
                .padding(.bottom)
            
            Text("Talk with your friend anything!")
                .font(Font.system(size:13, design: .serif))
            //.fontWeight(.bold)
                //.foregroundColor(.)
                .padding(.bottom)
            
            NavigationView {
                    
                    ScrollView {
                        
                        SignInUp()
                    }
                    .shadow(color: .gray, radius: 5)
            }
            .cornerRadius(50)
            .shadow(color: .yellow, radius: 3, y: -3)
        }
        .background(
            Image("BG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 5)
        )
        .edgesIgnoringSafeArea(.bottom)
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
