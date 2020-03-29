//
//  ModelEntityExt.swift
//  MemoryCardsGameAR
//
//  Created by Nour on 21.3.2020.
//  Copyright © 2020 Nour Saffaf. All rights reserved.
//

import Foundation
import RealityKit
import CoreGraphics

extension Entity {
    func scaleUpRelativeTo(_ card: Entity?) -> Entity {
        var scaleRatio = self.scale(relativeTo: card)
        scaleRatio.addProduct(scaleRatio, scaleRatio)
        let scaledUpModel = self.clone(recursive: true)
        scaledUpModel.setScale(scaleRatio, relativeTo: card)
        return scaledUpModel
    }
}

extension AnchorEntity {
    
    func add(board: [CardEntity]) {
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
    
    func addTimerEntity(maxTime: String) {
        let textMesh = generateTextMesh(for: maxTime)
        
        let material = SimpleMaterial(color: .green, isMetallic: true)
        let textModel = ModelEntity(mesh: textMesh, materials: [material])
        textModel.scale = SIMD3<Float>(0.02, 0.02, 0.1)
        textModel.name = "timer"
        textModel.setPosition(SIMD3<Float>(0.10, 0.05, 0), relativeTo: self)
        addChild(textModel)
        
    }
    
    func generateTextMesh(for text: String) -> MeshResource {
        return  MeshResource.generateText(
               text,
               extrusionDepth: 0.1,
               font: .systemFont(ofSize: 2),
               containerFrame: .zero,
               alignment: .left,
               lineBreakMode: .byWordWrapping)
    }
    
    func checkTwoCardsRevelaed() -> Bool {
        var count = 0
        for child in self.children where child is CardEntity {
            if (child as? CardEntity)?.card.revealed ?? false {
                count += 1
            }
        }
        
        return (count > 0 && count % 2 == 0)
    }
    
    func isEmptyBoard() -> Bool {
        //only timer is left
        return self.children.count == 2
    }
    
}
