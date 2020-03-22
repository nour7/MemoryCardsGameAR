//
//  ModelEntityExt.swift
//  MemoryCardsGameAR
//
//  Created by Nour on 21.3.2020.
//  Copyright © 2020 Nour Saffaf. All rights reserved.
//

import Foundation
import RealityKit

extension Entity {
    func flipUp() -> AnimationPlaybackController{
        var currentTransform = self.transform
        currentTransform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
    
        let flipUpController = self.move(to: currentTransform, relativeTo: self.parent, duration: 0.25, timingFunction: .easeInOut)
        
       return flipUpController
    }
    
    func flipDown() -> AnimationPlaybackController{
           var currentTransform = self.transform
           currentTransform.rotation = simd_quatf(angle: 0, axis: [1,0,0])
       
           let flipUpController = self.move(to: currentTransform, relativeTo: self.parent, duration: 0.25, timingFunction: .easeInOut)
           
          return flipUpController
       }
}

extension AnchorEntity {
    func add(board: [ModelEntity]) {
        for card in board {
            self.addChild(card)
        }
    }
}
