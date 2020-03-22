//
//  ViewController.swift
//  MemoryCardsGameAR
//
//  Created by Nour on 21.3.2020.
//  Copyright © 2020 Nour Saffaf. All rights reserved.
//

import UIKit
import RealityKit
import Combine

enum AppError: Error {
    case modelFailedLoading
}


class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    private var cards: [ModelEntity] = []
    private var flipUpController: AnimationPlaybackController? = nil
    private var flipDownContrller: AnimationPlaybackController? = nil
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let acnhorEntity = AnchorEntity(plane: .horizontal)
        arView.scene.anchors.append(acnhorEntity)
        
        self.loadCardsBoard().combineLatest(self.loadModels()).sink(receiveCompletion: { complete in
            print(complete)
        }, receiveValue: { value in
            let board = self.attachModelsToCards(models: value.1, cards: value.0, combined: []).shuffled().grid4x4()
            print("added \(board.count)")
            acnhorEntity.add(board: board)
            
        }).store(in: &cancellable)
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
    
    private func loadModels() -> AnyPublisher<[Entity], Error> {
        
        return Entity.loadModelAsync(named: "model_1")
            .append(Entity.loadModelAsync(named: "model_2"))
            .append(Entity.loadModelAsync(named: "model_3"))
            .append(Entity.loadModelAsync(named: "model_4"))
            .append(Entity.loadModelAsync(named: "model_5"))
            .append(Entity.loadModelAsync(named: "model_6"))
            .append(Entity.loadModelAsync(named: "model_7"))
            .append(Entity.loadModelAsync(named: "model_8"))
            .collect().map{ models -> [ModelEntity] in
                models.clone2()
        }.eraseToAnyPublisher()
        
    }
    
    private func loadCardsBoard() -> AnyPublisher<[ModelEntity], Error> {
        return Entity.loadModelAsync(named: "box").map(self.cloneCard16).eraseToAnyPublisher()
    }
    
    private func cloneCard16(cardTemplate: ModelEntity) -> [ModelEntity] {
        var cards: [ModelEntity] = []
        let max = 16
        for x in 0..<max {
            let card = cardTemplate.clone(recursive: true)
            card.name = "memory_card_\(x)"
            card.generateCollisionShapes(recursive: true)
            cards.append(card)
        }
        
        return cards
    }
    
    private func attachModelsToCards(models: [Entity], cards: [ModelEntity], combined:  [ModelEntity]) -> [ModelEntity] {
        
        var cardsWithModels: [ModelEntity] = combined
        
        if cards.isEmpty || models.isEmpty {
            return cardsWithModels
        }
        
        let card = cards.first!
        let model = models.first!
        card.addChild(model)
        cardsWithModels.append(card)
        
        return attachModelsToCards(models: Array(models.dropFirst()), cards: Array(cards.dropFirst()), combined: cardsWithModels)
    }
    
    
    
    @objc func onTap(sender: UIGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        
        if let card = arView.entity(at: tapLocation) {
            flipUpController = card.flipUp()
        }
    }
    
}


