//
//  ArView+Exts.swift
//  MemoryCardsGameAR
//
//  Created by Nour on 29.3.2020.
//  Copyright © 2020 Nour Saffaf. All rights reserved.
//

import Foundation
import RealityKit

extension ARView {
    
    func countDown(time: Int) {
        for anchor in self.scene.anchors where anchor is AnchorEntity {
            (anchor.findEntity(named: "timer") as? ModelEntity)?.model?.mesh = (anchor as! AnchorEntity).generateTextMesh(for: String(time))
        }
    }
    
    func checkTwoCardsRevelaed() -> Bool {
        var count = 0
        
        if let anchorEntity = self.scene.anchors.first as? AnchorEntity {
            for child in anchorEntity.children where child is CardEntity {
                if (child as? CardEntity)?.card.revealed ?? false {
                    count += 1
                }
            }
        }
        return (count > 0 && count % 2 == 0)
    }
    
    
    func isMatchingCardsRevelaed() -> Bool {
        
        var revealedCardNames: [String] = []
        
        for anchor in self.scene.anchors where anchor is AnchorEntity{
            for child in anchor.children where child is CardEntity {
                if (child as? CardEntity)?.card.revealed ?? false {
                    revealedCardNames.append((child as! CardEntity).card.attachedModelName)
                }
            }
        }
        return (revealedCardNames.first == revealedCardNames.last)
    }
    
    func hideAllCards() {
        
        for anchor in self.scene.anchors where anchor is AnchorEntity {
            for child in anchor.children where child is CardEntity {
                child.stopAllAnimations()
                _ = (child as? CardEntity)?.hide(duration: 0.25)
                (child as? CardEntity)?.setCardState(revealed: false)
            }
        }
    }
    
    func removeCards(with modelName: String) {
        // for some bug, this does not work. Sometiemes one child is not CardEntity but ModelEntity
        if let anchorEntity = self.scene.anchors.first as? AnchorEntity {
            for child in anchorEntity.children {
                if child is CardEntity {
                    if (child as! CardEntity).card.attachedModelName == modelName {
                        child.stopAllAnimations()
                        child.removeFromParent()
                    }
                }
            }
        }
    }
    
    func removeMatchedCards() {
        // for some bug, this does not work. Sometiemes one child is not CardEntity but ModelEntity
        for anchor in self.scene.anchors where anchor is AnchorEntity{
            for child in anchor.children {
                if (child as? CardEntity)?.card.revealed ?? false {
                    child.removeFromParent()
                }
            }
        }
    }
    
    func removeAll() {
        for anchor in self.scene.anchors where anchor is AnchorEntity {
            (anchor as? AnchorEntity)?.children.removeAll()
        }
    }
    
    func checkGameEnd() -> Bool {
        guard let anchorEntity = self.scene.anchors.first as? AnchorEntity else {
            return false
        }
        
        return anchorEntity.isEmptyBoard()
    }
    
    func gameEndWith(text: String) {
        guard let anchorEntity = self.scene.anchors.first as? AnchorEntity else {
            return
        }
        
        let textMesh = anchorEntity.generateTextMesh(for: text)
        let material = SimpleMaterial(color: .yellow, isMetallic: true)
        let textModel = ModelEntity(mesh: textMesh, materials: [material])
        textModel.setPosition(SIMD3<Float>(-0.3, 0.1, 0.1), relativeTo: anchorEntity)
        anchorEntity.addChild(textModel)
        
        var currentTransform = textModel.transform
        currentTransform.scale = simd_float3(x: 0.08, y: 0.08, z: 0.08)
        let scaleUpController = textModel.move(to: currentTransform, relativeTo: anchorEntity, duration: 1.0)
        scaleUpController.resume()
        
    }
    
}

