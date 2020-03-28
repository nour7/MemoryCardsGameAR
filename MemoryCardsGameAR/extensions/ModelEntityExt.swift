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
        currentTransform.rotation = simd_quatf(angle: 0, axis: [1,0,0])
    
        let flipUpController = self.move(to: currentTransform, relativeTo: self.parent, duration: 0.25, timingFunction: .easeInOut)
        
       return flipUpController
    }
    
    func flipDown() -> AnimationPlaybackController{
           var currentTransform = self.transform
        currentTransform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
       
           let flipUpController = self.move(to: currentTransform, relativeTo: self.parent, duration: 0.25, timingFunction: .easeInOut)
           
          return flipUpController
       }
    
    func scaleUpRelativeTo(_ card: Entity?) -> Entity {
        var scaleRatio = self.scale(relativeTo: card)
        scaleRatio.addProduct(scaleRatio, scaleRatio)
        let scaledUpModel = self.clone(recursive: true)
        scaledUpModel.setScale(scaleRatio, relativeTo: card)
        return scaledUpModel
    }
}

extension AnchorEntity {
    func add(board: [ModelEntity]) {
        for card in board {
            self.addChild(card)
        }
    }
    
    func addOcclusionBox() {
        let boxSize: Float = 0.2
        let boxMesh = MeshResource.generateBox(size: boxSize)
        let occlusionMaterial = OcclusionMaterial()
        let occlusionBox = ModelEntity(mesh: boxMesh, materials: [occlusionMaterial])
        occlusionBox.position.y = -boxSize / 2
        addChild(occlusionBox)
    }
}

