//
//  NetworkSession.swift
//  Spyne
//
//  Created by mhaashim on 15/11/24.
//

import Foundation
import RealmSwift
import UIKit

class NetworkSession: ObservableObject {

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
    
    @Published var isUploading: Bool = false
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
      var fieldString = "--\(boundary)\r\n"
      fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
      fieldString += "\r\n"
      fieldString += "\(value)\r\n"

      return fieldString
    } // convertFormField

    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
      let data = NSMutableData()

      data.appendString("--\(boundary)\r\n")
      data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
      data.appendString("Content-Type: \(mimeType)\r\n\r\n")
      data.append(fileData)
      data.appendString("\r\n")

      return data as Data
    } // convertFileData
    
    // File Upload Request
    func uploadRequest(photo: PhotoModel) {
        
        isUploading = true
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        guard let url = URL(string: "https://www.clippr.ai/api/upload") else {return}

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = NSMutableData()

        httpBody.appendString(convertFormField(named: "image", value: "", using: boundary))
        
        guard let imageData = UIImage(data: photo.imageData)?.jpegData(compressionQuality: 1.0) else {return}
        
        
        httpBody.append(convertFileData(fieldName: "image",
                                        fileName: "\(photo.imageName).png",
                                        mimeType: "image/png",
                                        fileData: imageData,
                                        using: boundary))
            
        
        
        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          // Handle the response here
            guard let data = data, error == nil else { return }
            let dataString = String(NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "")

            if let error = error {
                print("Upload failed with error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Upload completed with status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    Task { @MainActor in
                        if let realm = photo.realm {
                            do {
                                try realm.write {
                                    photo.uploadStatus = .completed
                                }
                            } catch {
                                print("Failed to update photo: \(error.localizedDescription)")
                            }
                            
                        }
                    }
                }
                else {
                    Task { @MainActor in
                        if let realm = photo.realm {
                            do {
                                try realm.write {
                                    photo.uploadStatus = .failure
                                }
                            } catch {
                                print("Failed to update photo: \(error.localizedDescription)")
                            }
                            
                        }
                    }
                }
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            
        }
        
        task.resume()
        isUploading = false
        
    } // uploadRequest



}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

