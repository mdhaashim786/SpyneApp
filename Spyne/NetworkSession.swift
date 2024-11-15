//
//  NetworkSession.swift
//  Spyne
//
//  Created by mhaashim on 15/11/24.
//

import Foundation
import RealmSwift

class NetworkSession {

    // Helper function to create a multipart/form-data body
    static func createMultipartBody(data: Data, fileName: String, boundary: String) -> Data {
        var body = Data()
        
        // Append the image data
        let boundaryPrefix = "--\(boundary)\r\n"
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        // Append the final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }

    static func getImageFilePath(for photo: PhotoModel) -> URL? {
        // Fetch the image data from Realm
        //let realm = Realm.instance
        // Ensure the photo object has valid image data
        let imageData = photo.imageData
        
        // Create a unique file name
        let fileName = "\(photo.imageName).png"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            // Write the image data to the temporary file
            try imageData.write(to: fileURL)
            print("Image saved to temporary file at: \(fileURL)")
            return fileURL
        } catch {
            print("Error saving image to temporary file: \(error)")
            return nil
        }
    }
    
    static func uploadImageFromRealm(photo: PhotoModel) {
        guard let fileURL = getImageFilePath(for: photo) else {
            print("Failed to get file URL")
            return
        }
        guard let url = URL(string: "https://www.clippr.ai/api/upload") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the multipart/form-data body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            body.append(imageData)
        }
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let session = URLSession.shared
        let task = session.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Upload failed with error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Upload completed with status code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
        }
        
        task.resume()
    }



}
