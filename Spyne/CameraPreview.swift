//
//  CameraPreview.swift
//  Spyne
//
//  Created by mhaashim on 14/11/24.
//

import SwiftUI

struct CameraPreview: View {
    @Binding var image: Image?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
