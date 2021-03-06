//
//  ContentView.swift
//  ChatApp
//
//  Created by Quang Bao on 09/11/2021.
//

import SwiftUI

struct ContentView: View {
        
    var body: some View {
        
        if isLoggedIn(){
            
            MainMessage()
            
        } else {
            
            Home()
            
        }
    }
    
    fileprivate func isLoggedIn() -> Bool {
        
        return UserDefaults.standard.isLoggedIn()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
        
    }
}
