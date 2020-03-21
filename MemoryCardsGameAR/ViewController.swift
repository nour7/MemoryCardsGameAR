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
        
        loadModels { result in
            do {
                self.cards = try result.map(self.loadCards).get().shuffled().grid4x4()
                for card in self.cards {
                    acnhorEntity.addChild(card)
                }
            } catch {
                print(error)
            }
        }
        //cards = loadCards().shuffled().grid4x4()
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
    
    private func loadCards(models: [ModelEntity]) -> [ModelEntity] {
        
        var cards: [ModelEntity] = []
        let cardTemplate = try! ModelEntity.loadModel(named: "box")
        let max = 16
        for x in 0..<max {
            let card = cardTemplate.clone(recursive: true)
            card.name = "memory_card_\(x)"
            card.addChild(models[x])
            card.generateCollisionShapes(recursive: true)
            cards.append(card)
        }
        
        return cards
    }
    
    private func loadModels(completion: @escaping (Result<[ModelEntity], Error>) -> Void ) {
        
        Entity.loadModelAsync(named: "model_1")
            .append(Entity.loadModelAsync(named: "model_2"))
            .append(Entity.loadModelAsync(named: "model_3"))
            .append(Entity.loadModelAsync(named: "model_4"))
            .append(Entity.loadModelAsync(named: "model_5"))
            .append(Entity.loadModelAsync(named: "model_6"))
            .append(Entity.loadModelAsync(named: "model_7"))
            .append(Entity.loadModelAsync(named: "model_8"))
            .collect().sink(receiveCompletion: { done in
                switch done {
                case .failure(_):
                    completion(.failure(AppError.modelFailedLoading))
                case .finished:
                    break
                }
                
            }) { models in
                
                completion(.success(models.clone2()))
        }.store(in: &cancellable)
        
    }
    
    @objc func onTap(sender: UIGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        
        if let card = arView.entity(at: tapLocation) {
            flipUpController = card.flipUp()
        }
    }
    
}


