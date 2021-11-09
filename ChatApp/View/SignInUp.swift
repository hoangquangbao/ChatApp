//
//  SignInUp.swift
//  ChatApp
//
//  Created by Quang Bao on 09/11/2021.
//

import SwiftUI

struct SignInUp: View {
    
    @State var isSignMode = false
    
    var body: some View {
                    
            Picker("Please choose", selection: $isSignMode) {
                Text("SIGN IN")
                    .tag(true)
                Text("SIGN UP")
                    .tag(false)
            }.pickerStyle(.segmented)
                .padding()
    }
}

struct SignInUp_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
