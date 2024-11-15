//
//  Realm+Extensions.swift
//  Spyne
//
//  Created by mhaashim on 14/11/24.
//

import RealmSwift

extension Realm {
    static var instance: Realm? {
        let realm: Realm
        do {
            realm = try Realm()
        } catch {
            debugPrint(error)
            return nil
        }
        return realm
    }
}
