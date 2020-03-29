//
//  ArrayExt.swift
//  MemoryCardsGameAR
//
//  Created by Nour on 21.3.2020.
//  Copyright © 2020 Nour Saffaf. All rights reserved.
//

import UIKit
import RealityKit

extension Array where Element: Entity {
    
    func clone2() -> [Entity] {
          var cloned: [Entity] = []
          var count = 1
          for model in self {
            model.name = "model_\(count)"
            cloned.append(model)
            cloned.append(model.clone(recursive: true))
            count += 1 
          }
          
          return cloned
      }
}

extension Array where Element: CardEntity {
    
    func grid4x4() -> [CardEntity] {
        
        for (index, card) in self.enumerated() {
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5
            card.position = [x * 0.05,0, z * 0.05]
        }
        
        return self
    }
    
    func cardFlippedDownOnStart() -> [CardEntity]  {
        
        var flippedDownCards: [CardEntity] = []
        
        for model in self {
            let flippedModel = model.clone(recursive: true)
            flippedModel.transform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
            flippedDownCards.append(flippedModel)
        }
        return flippedDownCards
    }

}

