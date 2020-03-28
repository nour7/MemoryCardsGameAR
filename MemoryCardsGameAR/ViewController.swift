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
    private var isTwoCardsRevelead = true
    private var canSelectAnotherCard = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CardComponent.registerComponent()
        
        let acnhorEntity = AnchorEntity(plane: .horizontal)
        acnhorEntity.name = "plane_anchor"
        
        arView.scene.anchors.append(acnhorEntity)
        
        acnhorEntity.addOcclusionBox()
        
        self.loadCardsBoard().combineLatest(self.loadModels()).sink(receiveCompletion: { complete in
            print(complete)
        }, receiveValue: { value in
            let (cards, models) = value
            //optional if the models are smaller than cards
            let scaledUpModelsRelativeToCards = models.map{$0.scaleUpRelativeTo(cards.first)}
            let board = self.attachModelsToCards(models: scaledUpModelsRelativeToCards, cards: cards, combined: []).shuffled().grid4x4().cardFlippedDownOnStart()
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
            .collect().map{ models -> [Entity] in
                models.clone2()
        }.eraseToAnyPublisher()
        
    }
    
    private func loadCardsBoard() -> AnyPublisher<[CardEntity], Error> {
        //Entity.loadAsync(named: "box", in: nil).map(self.cloneCard16).eraseToAnyPublisher()
        return Entity.loadModelAsync(named: "box").map(self.cloneCard16).eraseToAnyPublisher()
    }
    
    private func cloneCard16(cardTemplate: ModelEntity) -> [CardEntity] {
        var cards: [CardEntity] = []
        let max = 16
        for x in 0..<max {
            let cardEntity = CardEntity()
            cardEntity.model = cardTemplate.model
            cardEntity.transform = cardTemplate.transform
            cardEntity.name = "memory_card_\(x)"
            cardEntity.card.revealed = false
            cardEntity.card.name = "memory_card_\(x)"
            cardEntity.generateCollisionShapes(recursive: true)
            cards.append(cardEntity)
        }
        
        return cards
    }
    
    private func attachModelsToCards(models: [Entity], cards: [CardEntity], combined:  [CardEntity]) -> [CardEntity] {
        
        var cardsWithModels: [CardEntity] = combined
        
        if cards.isEmpty || models.isEmpty {
            return cardsWithModels
        }
        
        let card = cards.first!
        let model = models.first!
        print(model.debugDescription)
        card.card.attachedModelName = model.name
        print(model.name)
        card.addChild(model)
        cardsWithModels.append(card)
        
        return attachModelsToCards(models: Array(models.dropFirst()), cards: Array(cards.dropFirst()), combined: cardsWithModels)
    }
    
    
    
    @objc func onTap(sender: UIGestureRecognizer) {
        
        if canSelectAnotherCard {
            let tapLocation = sender.location(in: arView)
            if let card = arView.entity(at: tapLocation) as? CardEntity {
                if !card.card.revealed {
                    isTwoCardsRevelead = !isTwoCardsRevelead
                    flipUpController = card.reveal(duration: 0.25)
                    card.setCardState(revealed: true)
                    
                    Timer.scheduledTimer(withTimeInterval: 0.26, repeats: true) { timer in
                        guard let controller = self.flipUpController else {
                            timer.invalidate()
                            return
                        }
                        
                        if controller.isComplete {
                            timer.invalidate()
                            card.playModelAnimation()
                            self.gameLogic(cardModelName: card.card.attachedModelName)
                        }
                    }
                }
            }
        }
    }
    
    func gameLogic(cardModelName: String) {
        
        var similarCardsFound = false
        if self.arView.checkTwoCardsRevelaed() {
            canSelectAnotherCard = false
            if self.arView.isMatchingCardsRevelaed() {
                similarCardsFound = true
            } else {
                similarCardsFound = false
            }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            if !similarCardsFound {
                self.arView.hideAllCards()
            } else {
                self.arView.removeCards(with: cardModelName)
            }
            self.canSelectAnotherCard = true
        }
            }
    }
    
}


