//
//  UIImage.swift
//  ChatApp
//
//  Created by Quang Bao on 10/12/2021.
//

import SwiftUI
import Firebase

extension UIImage {
    func upload(with folder: String, completion: @escaping (URL?) -> Void) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        //let fileName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let data = self.jpegData(compressionQuality: 0.4)
//        let storage = Storage.storage().reference()
        let storage = FirebaseManager.shared.storage.reference()
        storage.child(folder).putData(data!, metadata: metadata) { meta, error in
            if let error = error {
                print(error)
                completion(nil)
                return
            }

            storage.child(folder).downloadURL { url, error in
                if let error = error {
                    // Handle any errors
                    print(error)
                    completion(nil)
                }
                else {
                    completion(url)
                }
            }
        }
    }
}
