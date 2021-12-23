//
//  ImagePickerGroup.swift
//  ChatApp
//
//  Created by Quang Bao on 21/12/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImagePickerGroup: UIViewControllerRepresentable {
    
    @Binding var imageGroup: UIImage?
    private let controller = UIImagePickerController()
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(parent: self)
        
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let parent: ImagePickerGroup
        
        init(parent: ImagePickerGroup) {
            
            self.parent = parent
            
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            parent.imageGroup = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            
            picker.dismiss(animated: true)
            
        }
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        controller.delegate = context.coordinator
        return controller
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
