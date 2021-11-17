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
        
//        NavigationView{
            
            VStack {
                
                Image("ImageSignInUpPage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 250, alignment: .center)
                    .mask(Circle())
                    .padding()
                    .shadow(color: .white, radius: 2)
                                            
                ScrollView {
                    SignInUp()
                }
            }
            .navigationBarHidden(true)
            //.background(.black)
        //}
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
