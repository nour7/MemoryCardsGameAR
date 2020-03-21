//
//  ArrayExt.swift
//  MemoryCardsGameAR
//
//  Created by Nour on 21.3.2020.
//  Copyright © 2020 Nour Saffaf. All rights reserved.
//

import UIKit
import RealityKit

extension Array where Element: ModelEntity {
    
    func grid4x4() -> [ModelEntity] {
           
           for (index, card) in self.enumerated() {
               let x = Float(index % 4) - 1.5
               let z = Float(index / 4) - 1.5
               card.position = [x * 0.05,0, z * 0.05]
           }
           
           return self
       }
    
    func clone2() -> [ModelEntity] {
        var cloned: [ModelEntity] = []
        
        for model in self {
            cloned.append(model)
            cloned.append(model.clone(recursive: true))
        }
        
        return cloned
    }
}

