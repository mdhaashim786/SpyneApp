//
//  PhotoItemView.swift
//  Spyne
//
//  Created by mhaashim on 14/11/24.
//

import SwiftUI
import RealmSwift

struct PhotoItemView: View {
    
    @State private var image: Image?
    
    @ObservedRealmObject var photo: PhotoModel

    var body: some View {
        
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .scaleEffect(0.5)
            }
        }
        .task {
            guard image == nil else { return }
            
            if let imageData = UIImage(data: photo.imageData) {
                image = Image(uiImage: imageData)
            }
        }
    }
}
