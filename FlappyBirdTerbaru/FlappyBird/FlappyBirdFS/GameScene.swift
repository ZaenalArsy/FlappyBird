//
//  GameScene.swift
//  FlappyBirdFS
//
//  Created by apple on 2018/11/13.
//  Copyright © 2018 Zaen. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    lazy var stopOrder : Int = 0
    lazy var score : Int = 0
    
    let CollisionCategoryBird : UInt32 = 0x1 << 1
    let CollisionCategoryLand : UInt32 = 0x1 << 2
    let CollisionCategoryPipe : UInt32 = 0x1 << 3
    let CollisionCategoryCoin : UInt32 = 0x1 << 4
    
    lazy var landNode1 : SKSpriteNode = {
        
        let landNode1 = SKSpriteNode(imageNamed: "land")
        
        landNode1.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: landNode1.size.width, height: landNode1.size.height))
        landNode1.physicsBody?.isDynamic = false
        landNode1.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        landNode1.position = CGPoint(x: 0.0, y: 0.0)
        
        landNode1.physicsBody?.categoryBitMask = CollisionCategoryLand
        landNode1.physicsBody?.collisionBitMask = CollisionCategoryBird
        
        landNode1.name = "LAND"
        
        return landNode1
    }()
    
    lazy var landNode2 : SKSpriteNode = {
        
        let landNode2 = SKSpriteNode(imageNamed: "land")
        
        landNode2.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: landNode2.size.width, height: landNode2.size.height))
        landNode2.physicsBody?.isDynamic = false
        landNode2.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        landNode2.position = CGPoint(x: landNode1.size.width, y: 0.0)
        
        landNode2.physicsBody?.categoryBitMask = CollisionCategoryLand
        landNode2.physicsBody?.collisionBitMask = CollisionCategoryBird
        
        landNode2.name = "LAND"
        
        return landNode2
    }()
    
    lazy var birdNode : SKSpriteNode = {
        
        let birdNode = SKSpriteNode(imageNamed: "bird-01")
        
        birdNode.physicsBody = SKPhysicsBody(circleOfRadius: birdNode.size.width / 2)
        birdNode.physicsBody?.isDynamic = true
        birdNode.position = CGPoint(x: self.size.width / 2.0, y: self.size.height / 2.0)
        birdNode.physicsBody?.linearDamping = 1.0
        birdNode.physicsBody?.allowsRotation = false
        
        birdNode.physicsBody?.categoryBitMask = CollisionCategoryBird
        birdNode.physicsBody?.contactTestBitMask = CollisionCategoryLand | CollisionCategoryPipe | CollisionCategoryCoin
        birdNode.physicsBody?.collisionBitMask = CollisionCategoryLand | CollisionCategoryPipe | CollisionCategoryCoin
        
        birdNode.name = "BIRD"
        
        return birdNode
    }()
    
    lazy var gameOverLabel : SKLabelNode = {
        
        var gameOverLabel = SKLabelNode(fontNamed: "Copperplate")
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: size.width/2, y: frame.height/2 + gameOverLabel.frame.height)
        return gameOverLabel
        
    }()
    
    lazy var scoreLabel : SKLabelNode = {
        var scoreLabel = SKLabelNode(fontNamed: "Copperplate")
        scoreLabel.text = "Score : \(score)"
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPoint(x: self.size.width - (scoreLabel.frame.width/2) - 20, y: self.size.height - scoreLabel.frame.height)
        return scoreLabel
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    
    }
    
    override init(size: CGSize) {
    
        super.init(size: size)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy:  -2.0);
        
        isUserInteractionEnabled = true
        
        backgroundColor = SKColor(red: 80/255, green: 190/255, blue: 200/255, alpha: 1.0)
        
        
        addChild(landNode1)
        addChild(landNode2)
        addChild(birdNode)
        addChild(scoreLabel)
        
        
        makeBirdFly()
        
        repeatlyCreatePipes()
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            birdNode.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 10.0))
        
    }
    
    func makeBirdFly() {
        
        let textureAtlas = SKTextureAtlas(named: "bird.atlas")
        let bird1 = textureAtlas.textureNamed("bird-01")
        let bird2 = textureAtlas.textureNamed("bird-02")
        let bird3 = textureAtlas.textureNamed("bird-03")
        let bird4 = textureAtlas.textureNamed("bird-04")
        
        let birdTextures = [bird1, bird2, bird3, bird4]
        
        let animateAction = SKAction.animate(with: birdTextures, timePerFrame: 0.2)
        
        birdNode.run(SKAction.repeatForever(animateAction), withKey: "birdFly")
        
    }
    
    func makeCoinSpinning(_ goldNode : SKSpriteNode) {
        
        let textureAtlas = SKTextureAtlas(named: "coin.atlas")
        let coin1 = textureAtlas.textureNamed("goldCoin1")
        let coin2 = textureAtlas.textureNamed("goldCoin2")
        let coin3 = textureAtlas.textureNamed("goldCoin3")
        let coin4 = textureAtlas.textureNamed("goldCoin4")
        let coin5 = textureAtlas.textureNamed("goldCoin5")
        let coin6 = textureAtlas.textureNamed("goldCoin6")
        let coin7 = textureAtlas.textureNamed("goldCoin7")
        let coin8 = textureAtlas.textureNamed("goldCoin8")
        let coin9 = textureAtlas.textureNamed("goldCoin9")
        
        let coinTextures = [coin1, coin2, coin3, coin4, coin5, coin6, coin7, coin8, coin9]
        
        let animateAction = SKAction.animate(with: coinTextures, timePerFrame: 0.2)
        
        goldNode.run(SKAction.repeatForever(animateAction), withKey: "coinSpin")
        
    }
    
    func stopBirdFly() {
        birdNode.removeAction(forKey: "birdFly")
    }
    
    func moveScene() {
        
        landNode1.position = CGPoint(x: landNode1.position.x - 1, y: landNode1.position.y)
        landNode2.position = CGPoint(x: landNode2.position.x - 1, y: landNode2.position.y)
        
        if landNode1.position.x <= -(landNode1.size.width * 0.5) {
            landNode2.position = CGPoint(x: 0, y: landNode1.position.y)
            landNode1.position = CGPoint(x: landNode2.position.x + landNode2.size.width, y: landNode2.position.y)
        }
        
        if landNode2.position.x <= -(landNode2.size.width * 0.5) {
            landNode1.position = CGPoint(x: 0, y: landNode2.position.y)
            landNode2.position = CGPoint(x: landNode1.position.x + landNode1.size.width, y: landNode1.position.y)
        }
        
        //move pipes
        for pipeNode in self.children where pipeNode.name == "PIPE" {
            
            if let pipeSpriteNode = pipeNode as? SKSpriteNode{
                pipeSpriteNode.position = CGPoint(x: pipeNode.position.x - 1, y: pipeNode.position.y)
                //remove the pipe out of the screen
                if pipeSpriteNode.position.x <= -(pipeSpriteNode.size.width * 0.5){
                    pipeSpriteNode.removeFromParent()
                }
            }
            
        }
        
        for coinNode in self.children where coinNode.name == "COIN" {
            
            if let coinSpriteNode = coinNode as? SKSpriteNode{
                coinSpriteNode.position = CGPoint(x: coinNode.position.x - 1, y: coinNode.position.y)
                //remove the pipe out of the screen
                if coinSpriteNode.position.x <= -(coinSpriteNode.size.width * 0.5){
                    coinSpriteNode.removeFromParent()
                }
            }
            
        }
    
    }
    
    
    func addPipes(upSize: CGSize, downSize: CGSize, coinPositionY : CGFloat){
        
        let pipeDownTexture = SKTexture(imageNamed: "PipeDown")
        let pipeUpTexture = SKTexture(imageNamed: "PipeUp")
        
        let pipeDownNode = SKSpriteNode(texture: pipeDownTexture, size: downSize)
        let pipeUpNode = SKSpriteNode(texture: pipeUpTexture, size: upSize)
        let coinNode = SKSpriteNode(imageNamed: "goldCoin1")
        
        pipeDownNode.position = CGPoint(x: self.size.width + 50, y: frame.size.height - (pipeDownNode.size.height / 2))
        pipeDownNode.physicsBody = SKPhysicsBody(rectangleOf: pipeDownNode.size)
        pipeDownNode.physicsBody?.isDynamic = false
        pipeDownNode.physicsBody?.categoryBitMask = CollisionCategoryPipe
        pipeDownNode.physicsBody?.collisionBitMask = CollisionCategoryBird
        pipeDownNode.name = "PIPE"
        
        pipeUpNode.position = CGPoint(x: self.size.width + 50, y: landNode1.size.height + (pipeUpNode.size.height*0.5))
        pipeUpNode.physicsBody = SKPhysicsBody(rectangleOf: pipeUpNode.size)
        pipeUpNode.physicsBody?.isDynamic = false
        pipeUpNode.physicsBody?.categoryBitMask = CollisionCategoryPipe
        pipeUpNode.physicsBody?.collisionBitMask = CollisionCategoryBird
        pipeUpNode.name = "PIPE"
        
        coinNode.position = CGPoint(x: pipeUpNode.position.x, y: coinPositionY)
        coinNode.physicsBody = SKPhysicsBody(circleOfRadius: coinNode.size.width / 2)
        coinNode.physicsBody?.isDynamic = false
        coinNode.physicsBody?.categoryBitMask = CollisionCategoryCoin
        coinNode.physicsBody?.contactTestBitMask = CollisionCategoryBird
        coinNode.name = "COIN"
        
        addChild(pipeDownNode)
        addChild(pipeUpNode)
        addChild(coinNode)
        
        makeCoinSpinning(coinNode)
    }
    
    func createRandomPipes() {
        
        let gapHeight = birdNode.size.height * 4
        let randomFloat = CGFloat.random(in: -150...150)
        
        let upPipeHeight = (frame.size.height - landNode1.size.height - gapHeight)/2 + randomFloat
        let downPipeHeight = frame.size.height - landNode1.size.height - gapHeight - upPipeHeight
        let coinPosY = landNode1.size.height + upPipeHeight + (gapHeight/2)
        let pipeWidth: CGFloat = 40
        
        addPipes(upSize: CGSize(width: pipeWidth, height: upPipeHeight), downSize: CGSize(width: pipeWidth, height: downPipeHeight), coinPositionY: coinPosY)
    }
    
    func repeatlyCreatePipes() {
        
        let waitAction = SKAction.wait(forDuration: 4)
        let createAction = SKAction.run{
            self.createRandomPipes()
        }
        let actionSequence = SKAction.sequence([waitAction, createAction])
        let repeatCreateAction = SKAction.repeatForever(actionSequence)
        
        run(repeatCreateAction, withKey: "createPipe")
    }
    
    func gameOver(){
        isUserInteractionEnabled = false
        print("gameover!")
        if stopOrder == 1 {
            addChild(gameOverLabel)
        }
        
    }

    
    override func update(_ currentTime: TimeInterval) {
        
        if stopOrder == 0 {
            moveScene()
            
        }
       
    }
    
}

extension GameScene : SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionCategoryBird && secondBody.categoryBitMask == CollisionCategoryPipe || firstBody.categoryBitMask == CollisionCategoryPipe && secondBody.categoryBitMask == CollisionCategoryBird || firstBody.categoryBitMask == CollisionCategoryBird && secondBody.categoryBitMask == CollisionCategoryLand || firstBody.categoryBitMask == CollisionCategoryLand && secondBody.categoryBitMask == CollisionCategoryBird {
            
            gameOver()
            
            birdNode.removeAllActions()
            landNode1.removeAllActions()
            landNode2.removeAllActions()
            
            enumerateChildNodes(withName: "PIPE", using: ({
                (node, error) in
                node.removeAllActions()
            }))
            
            stopOrder += 1
            
        } else if firstBody.categoryBitMask == CollisionCategoryBird && secondBody.categoryBitMask == CollisionCategoryCoin || firstBody.categoryBitMask == CollisionCategoryCoin && secondBody.categoryBitMask == CollisionCategoryBird {
            
            score += 1
            scoreLabel.text = "Score : \(score)"
            print(score)
            
            enumerateChildNodes(withName: "COIN", using: ({
                (node, error) in
                node.removeFromParent()
            }))
            
        }
        
    }
    
}
