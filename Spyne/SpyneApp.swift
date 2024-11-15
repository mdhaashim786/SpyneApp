//
//  SpyneApp.swift
//  Spyne
//
//  Created by mhaashim on 13/11/24.
//

import SwiftUI

@main
struct SpyneApp: App {

    init() {
        UINavigationBar.applyCustomAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

fileprivate extension UINavigationBar {
    
    static func applyCustomAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
