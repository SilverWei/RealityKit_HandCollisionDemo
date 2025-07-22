//
//  ImmersiveView.swift
//  HandCollision
//
//  Created by 青坂雪 on 2025/7/22.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var worldEntity = Entity()
    @Environment(AppModel.self) var appModel
    @Environment(\.realityKitScene) private var realityKitScene
    @State private var objectResources: [String: Entity] = [:]
    @State private var eventSubscribes: [EventSubscription] = []

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let sceneEntity = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(sceneEntity)
                sceneEntity.addChild(worldEntity)
            }
            Task { // 待sceneEntity加载进realityKitScene后异步查询
                for entity in realityKitScene!.performQuery(.init(where: .has(ObjectComponent.self))) {
                    entity.transform = .identity
                    objectResources[entity.name] = entity
                    entity.removeFromParent()
                }
                for entity in realityKitScene!.performQuery(.init(where: .has(AnchoringComponent.self))) {
                    var anchoringComponent = entity.components[AnchoringComponent.self]!
                    anchoringComponent.trackingMode = .predicted
                    anchoringComponent.physicsSimulation = .none
                    entity.components.set(anchoringComponent)
                }
            }
            appModel.createSphereAction = {
                let cloneEntity = objectResources["Sphere"]!.clone(recursive: true)
                let objectCreatePointEntity = realityKitScene!.performQuery(.init(where: .has(AnchoringComponent.self)))
                    .first(where: { !$0.components.has(CollisionComponent.self) })! // 左手指尖没有绑Collision，所以用左手生成物体
                objectCreatePointEntity.addChild(cloneEntity)
                worldEntity.addChild(cloneEntity, preservingWorldTransform: true)
            }
            do {
                let subscribe = content.subscribe(to: CollisionEvents.Began.self) { event in
                    // entityA和entityB都需要有CollisionComponent，且entityA与entityB之间至少有一个得有PhysicsBodyComponent
                    guard event.entityA.components.has(AnchoringComponent.self),
                          event.entityB.components.has(ObjectComponent.self) else { return }
                    let objectEntity = event.entityB
                    objectEntity.stopAllAnimations()
                    var resetTransform = Transform.identity // 受动画影响过的transform
                    resetTransform.translation = objectEntity.transform.translation
                    objectEntity.transform = resetTransform
                    let animationName = "Play" // Reality Composer Pro里创建的Timelines动画名称
                    let animationResource = objectEntity
                        .components[AnimationLibraryComponent.self]!
                        .animations
                        .first(where: { $0.key.components(separatedBy: "/").last == animationName })!
                        .value
                    objectEntity.playAnimation(animationResource)
                }
                eventSubscribes.append(subscribe)
            }
        }
        .task {
            await checkAuthorization()
        }
        .onDisappear {
            eventSubscribes.forEach { $0.cancel() }
        }
    }
    /// 授权检查
    private func checkAuthorization() async {
        // Info需要`Privacy - Hands Tracking Usage Description`权限请求
        let configuration = SpatialTrackingSession.Configuration(
            tracking: [.hand]
        )
        if let unavailableCapabilities = await SpatialTrackingSession().run(configuration) {
            if unavailableCapabilities.anchor.contains(.world) {
                fatalError("World tracking is not available on this device.")
            }
            if unavailableCapabilities.anchor.contains(.hand) {
                fatalError("Hand tracking is not available on this device.")
            }
        }
    }
    
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
