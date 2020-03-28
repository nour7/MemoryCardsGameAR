//
//  CardEntity.swift
//  MemoryCardsGameAR
//
//  Created by Nour on 28.3.2020.
//  Copyright © 2020 Nour Saffaf. All rights reserved.
//

import RealityKit
import Foundation


struct CardComponent: Component, Codable {
    var revealed: Bool = false
    var name: String = ""
    var attachedModelName: String = ""
}

class CardEntity: Entity, HasModel, HasCollision {
    
    public var card: CardComponent {
        get {return components[CardComponent.self] ?? CardComponent()}
        set { components[CardComponent.self] = newValue}
    }
}

extension CardEntity {
    
    func reveal(duration: TimeInterval) -> AnimationPlaybackController{
        var currentTransform = self.transform
        currentTransform.rotation = simd_quatf(angle: 0, axis: [1,0,0])
        
        let flipUpController = self.move(to: currentTransform, relativeTo: self.parent, duration: duration, timingFunction: .easeInOut)
        
        return flipUpController
    }
    
    func hide(duration: TimeInterval) -> AnimationPlaybackController{
        var currentTransform = self.transform
        currentTransform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
        
        let flipUpController = self.move(to: currentTransform, relativeTo: self.parent, duration: 0.25, timingFunction: .easeInOut)
        
        return flipUpController
    }
    
    func setCardState(revealed: Bool) {
        self.card.revealed = revealed
    }
    
    func playModelAnimation() {
        if let attachedModelAnimation = ((self.children.first)?.availableAnimations), !attachedModelAnimation.isEmpty  {
            self.children.first?.playAnimation(attachedModelAnimation.first!.repeat())
        }
    }
}
