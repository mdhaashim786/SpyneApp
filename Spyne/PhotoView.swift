//
//  PhotoView.swift
//  Spyne
//
//  Created by mhaashim on 14/11/24.
//

import SwiftUI
import RealmSwift

struct PhotoView: View {
    var photoId: ObjectId
    @State private var image: Image?
    
    @State var photoM: PhotoModel?
    
    @ObservedResults(PhotoModel.self) var photos
    
    @Environment(\.dismiss) var dismiss
    private let imageSize = CGSize(width: 1024, height: 1024)
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.secondary)
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            buttonsView()
                .offset(x: 0, y: -50)
        }
        .task {
            guard image == nil, let realm = Realm.instance else { return }
            
            self.photoM = realm.objects(PhotoModel.self).filter("id == %d", photoId).first
            
            if let imageData = photoM?.imageData, let UiImage = UIImage(data: imageData) {
                image = Image(uiImage: UiImage)
            }
        }
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            
            Button {
                Task {
                    if let photo = photoM {
                        NetworkSession.uploadImageFromRealm(photo: photo)
                    }
                }
            } label: {
                Label("Upload", systemImage: "icloud.and.arrow.up.fill")
                    .font(.system(size: 24))
            }
            
            Button {
                Task {
                    try? Realm.instance?.write {
                        photoM?.isFavorite.toggle()
                    }
                }
            } label: {
                Label("Favorite", systemImage: photoM?.isFavorite ?? true ? "heart.fill" : "heart")
                    .font(.system(size: 24))
            }

            Button {
                Task {
                    if let photoModel = photoM {
                        await MainActor.run {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                photoM = nil
                                $photos.remove(photoModel)
                            })
                                                          
                        }
                        
                        
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.system(size: 24))
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
        .background(Color.secondary.colorInvert())
        .cornerRadius(15)
    }
}

