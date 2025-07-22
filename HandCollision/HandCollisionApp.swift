//
//  HandCollisionApp.swift
//  HandCollision
//
//  Created by 青坂雪 on 2025/7/22.
//

import SwiftUI
import RealityKit
import RealityKitContent

@main
struct HandCollisionApp: App {
    
    @State private var appModel = AppModel()
    
    init() {
        ObjectComponent.registerComponent()
        ObjectCreatePointComponent.registerComponent()
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
