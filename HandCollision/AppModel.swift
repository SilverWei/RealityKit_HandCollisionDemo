//
//  AppModel.swift
//  HandCollision
//
//  Created by 青坂雪 on 2025/7/22.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    var createSphereAction: (() -> Void)?
}
