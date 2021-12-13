//
//  ImagePickerMessage.swift
//  ChatApp
//
//  Created by Quang Bao on 09/12/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImagePickerMessage: UIViewControllerRepresentable {
    
    @Binding var imageMessage: UIImage?
    //@Binding var imgMessage: Data
    
    private let controller = UIImagePickerController()
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(parent: self)
        
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let parent: ImagePickerMessage
        
        init(parent: ImagePickerMessage) {
            
            self.parent = parent
            
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            parent.imageMessage = info[.originalImage] as? UIImage
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
    
    //    @Binding var isShowImagePickerMessage : Bool
    //    @Binding var imgMessage : Data
    //
    //    func makeCoordinator() -> Coordinator {
    //
    //        return ImagePickerMessage.Coordinator(parent1: self)
    //
    //    }
    //
    //    func makeUIViewController(context: Context) -> UIImagePickerController {
    //
    //        let picker = UIImagePickerController()
    //        picker.sourceType = .photoLibrary
    //        picker.delegate = context.coordinator
    //        return picker
    //
    //    }
    //
    //    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    //
    //    }
    //
    //    class Coordinator : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //
    //        var parent : ImagePickerMessage
    //
    //        init(parent1: ImagePickerMessage) {
    //
    //            parent = parent1
    //
    //        }
    //
    //        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //
    //            parent.isShowImagePickerMessage.toggle()
    //
    //        }
    //
    //        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //
    //            let image = info[.originalImage] as! UIImage
    //            parent.imgMessage = image.jpegData(compressionQuality: 0.5)!
    //            parent.isShowImagePickerMessage.toggle()
    //
    //        }
    //    }
}
