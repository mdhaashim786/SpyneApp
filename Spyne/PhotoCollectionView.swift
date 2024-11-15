//
//  PhotoCollectionView.swift
//  Spyne
//
//  Created by mhaashim on 14/11/24.
//

import SwiftUI
import RealmSwift

struct PhotoCollectionView: View {
    //@ObservedObject var photoCollection : PhotoCollection
    
    @ObservedResults(PhotoModel.self, sortDescriptor: SortDescriptor(keyPath: "timestamp", ascending: false)) var photos
    
    @Environment(\.displayScale) private var displayScale
        
    private static let itemSpacing = 12.0
    private static let itemCornerRadius = 15.0
    private static let itemSize = CGSize(width: 90, height: 90)
    
    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2), height: Self.itemSize.height * min(displayScale, 2))
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: itemSize.width, maximum: itemSize.height), spacing: itemSpacing)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Self.itemSpacing) {
                ForEach(photos) { asset in
                    NavigationLink {
                        PhotoView(photoId: asset.id)
                    } label: {
                        photoItemView(asset: asset)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding([.vertical], Self.itemSpacing)
        }
        .navigationTitle("Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .statusBar(hidden: false)
    }
    
    private func photoItemView(asset: PhotoModel) -> some View {
        
        PhotoItemView(photo: asset)
            .frame(width: Self.itemSize.width, height: Self.itemSize.height)
            .clipped()
            .cornerRadius(Self.itemCornerRadius)
            .overlay(alignment: .bottomLeading) {
                if asset.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: 4, y: -4)
                }
                
            }
            .overlay(alignment: .bottomTrailing) {
                switch asset.uploadStatus{
                case .notuploaded:
                    Image(systemName: "icloud.slash.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: -4, y: -4)
                case .inprogress:
                    ProgressView()
                case .completed:
                    Image(systemName: "checkmark.icloud.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: -4, y: 4)
                case .failure:
                    Image(systemName: "exclamationmark.icloud.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: -4, y: -4)
                }
            }
        
    }
}
