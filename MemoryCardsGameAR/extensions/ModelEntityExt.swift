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
    
    func checkTwoCardsRevelaed() -> Bool {
        var count = 0
        for child in self.children where child is CardEntity {
            if (child as? CardEntity)?.card.revealed ?? false {
                count += 1
            }
        }
        
        return (count > 0 && count % 2 == 0)
    }
}

extension ARView {
    
    func checkTwoCardsRevelaed() -> Bool {
        var count = 0
        for anchor in self.scene.anchors {
            if anchor is AnchorEntity {
                for child in anchor.children where child is CardEntity {
                    if (child as? CardEntity)?.card.revealed ?? false {
                        count += 1
                    }
                }
            }
        }
        return (count > 0 && count % 2 == 0)
    }
    
    
    func isMatchingCardsRevelaed() -> Bool {
        
        var revealedCardNames: [String] = []
        
        for anchor in self.scene.anchors {
            if anchor is AnchorEntity {
                for child in anchor.children where child is CardEntity {
                    if (child as? CardEntity)?.card.revealed ?? false {
                        revealedCardNames.append((child as! CardEntity).card.attachedModelName)
                    }
                }
            }
        }
        return (revealedCardNames.first == revealedCardNames.last)
    }
    
    func hideAllCards() {
        
        for anchor in self.scene.anchors {
            if anchor is AnchorEntity {
                for child in anchor.children where child is CardEntity {
                     child.stopAllAnimations()
                   _ = (child as? CardEntity)?.hide(duration: 0.25)
                    (child as? CardEntity)?.setCardState(revealed: false)
                }
            }
        }
        }
    
    func removeCards(with modelName: String) {
        for anchor in self.scene.anchors {
            if anchor is AnchorEntity {
                for child in anchor.children where child is CardEntity {
                   if (child as! CardEntity).card.attachedModelName == modelName {
                    child.stopAllAnimations()
                    anchor.removeChild(child)
                }
            }
        }
    }
        }
        
}

