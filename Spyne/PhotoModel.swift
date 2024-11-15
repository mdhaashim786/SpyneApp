//
//  PhotoModel.swift
//  Spyne
//
//  Created by mhaashim on 14/11/24.
//

import RealmSwift
import SwiftUI


struct dateFormater {
    
    
    let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
    }
    
    func convertToString(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}

class PhotoModel: Object, Identifiable {
    
    enum UserUploadStatus: Int, PersistableEnum, CaseIterable, Identifiable, CustomStringConvertible {
        var id: Int { self.rawValue }
        
        case inprogress, completed, failure, notuploaded
        
        var description: String {
            switch self {
            case .inprogress: return "inprogress"
            case .completed: return "completed"
            case .failure: return "failure"
            case .notuploaded: return "notuploaded"
            }
        }
    }
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var imageData: Data
    @Persisted var timestamp: Date = Date()
    @Persisted var isFavorite: Bool = false
    @Persisted var uploadStatus: UserUploadStatus = .notuploaded
    @Persisted var imageName: String = dateFormater().convertToString(from: Date())
    @Persisted var imagePath: String = ""
    
    convenience init(imageData: Data) {
        self.init()
        self.imageData = imageData
    }
}
