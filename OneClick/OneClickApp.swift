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
            MainView()
        }
    }
}

struct MainView: View {
    var body: some View {
        TabView {
            FunctionalityView()
                .tabItem {
                    Label("Functionality", systemImage: "info.circle")
                }
        }
        .frame(width: 400, height: 300) // Set the size of the window
    }
}

struct FunctionalityView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("OneClick Functionality")
                .font(.title)
                .padding(.bottom, 10)
            
            Text("You can easily manage and access your most frequently used URLs, applications, and files with one click")
            
            Text("Features:")
                .font(.headline)
                .padding(.top, 10)
            
            Text("• Open all your saved URLs and applications with a single click.")
            Text("• Add new URLs, applications, and files to the menu.")
            Text("• Delete URLs, applications, and files from the menu.")
            
            Spacer()
        }
        .padding()
    }
}
