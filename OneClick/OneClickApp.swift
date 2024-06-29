//
//  OneClickApp.swift
//  OneClick
//
//  Created by donggwan lee on 6/27/24.
//

import SwiftUI

@main
struct OneClickApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            EmptyView() // This ensures no visible window is created
        }
    }
}


