//
//  ContentView.swift
//  HandCollision
//
//  Created by 青坂雪 on 2025/7/22.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        VStack {
            Spacer()
            if appModel.immersiveSpaceState == .open {
                Text("点击`Create Sphere`在左手创建一个球体，用右手指尖触碰可以触发触碰动画。")
                Spacer()
                Button("Create Sphere") {
                    appModel.createSphereAction!()
                }
            }
            Spacer()
            ToggleImmersiveSpaceButton()
            Spacer()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
