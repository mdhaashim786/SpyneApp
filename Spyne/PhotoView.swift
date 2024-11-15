//
//  PhotoView.swift
//  Spyne
//
//  Created by mhaashim on 14/11/24.
//

import SwiftUI
import UserNotifications
import RealmSwift

struct PhotoView: View {
    var photoId: ObjectId
    @State private var image: Image?
    
    @ObservedObject var networkSession = NetworkSession()
    
    @State var photoM: PhotoModel?
    
    @State var showAlert: Bool = false
    
    @ObservedResults(PhotoModel.self) var photos
    
    @Environment(\.dismiss) var dismiss
    private let imageSize = CGSize(width: 1024, height: 1024)
    
    @State var imageUploadStatus: String = "icloud.and.arrow.up.fill"
    
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
        .overlay {
            if networkSession.isUploading {
                ProgressView()
                    .controlSize(.regular)
            }
        }
        .overlay(
            EmptyView()
                .alert("Photo alredy uploaded", isPresented: $showAlert, actions: {
                    Button("OK") {
                        showAlert = false
                    }
                })
            ,
            alignment: .bottomTrailing
        )
        
        .allowsHitTesting(!networkSession.isUploading)
        
        .task {
            guard image == nil, let realm = Realm.instance else { return }
            
            self.photoM = realm.objects(PhotoModel.self).filter("id == %d", photoId).first
            
            if let imageData = photoM?.imageData, let UiImage = UIImage(data: imageData), let status = photoM?.uploadStatus {
                image = Image(uiImage: UiImage)
                
                imageUploadStatus = {
                    switch status {
                        
                    case .inprogress:
                        "icloud.and.arrow.up.fill"
                    case .completed:
                        "checkmark.icloud.fill"
                    case .failure:
                        "exclamationmark.icloud.fill"
                    case .notuploaded:
                        "icloud.and.arrow.up.fill"
                    }
                }()
                
                
            }
        }
        
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            
            Button {
                Task {
                    if let photo = photoM {
                        if photo.uploadStatus == .completed {
                            showAlert = true
                        } else {
                            networkSession.uploadRequest(photo: photo)
                        }
                    }
                }
            } label: {
                Label("Upload", systemImage: imageUploadStatus)
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
