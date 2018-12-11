//
//  GameScene.swift
//  FlappyBirdZ
//
//  Created by Zaen on 11/17/18.
//  Copyright © 2018 Zaen. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isGameStarted = Bool(false)
    var isDied = Bool(false)
    let coinSound = SKAction.playSoundFileNamed("CoinSound.mp3", waitForCompletion: false)
    
    var score = Int(0)
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    //CREATE THE BIRD ATLAS FOR ANIMATION
    let birdAtlas = SKTextureAtlas(named:"bird")
    var birdSprites = Array<Any>()
    var bird = SKSpriteNode()
    var repeatActionBird = SKAction()
    
    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isGameStarted == false {
            
            isGameStarted = true
            bird.physicsBody?.affectedByGravity = true
            createPauseBtn()
            
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            
            self.bird.run(repeatActionBird)
            
            // This run an action that creates and add pillar pairs to the scene.
            let spawn = SKAction.run({
                () in
                self.wallPair = self.createWalls()
                self.addChild(self.wallPair)
            })
            // Here you wait for 1.5 seconds for the next set of pillars to be generated. A sequence of actions will run the spawn and delay actions forever.
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            //This will move and remove the pillars. You set the distance that the pillars have to move which is the sum of the screen and the pillar width. Another sequence of action will run in order to move and remove the pillars. Pillars start moving to the left of the screen as they are created and are deallocated when they go off the screen
            //Intinya membuat pillar berjalan dan setelah pillar melewati sisi kiri layar, maka akan dihapus
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePillars = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePillars = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePillars, removePillars])
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40)) //biar pas touch naik
        } else {
            
            if isDied == false { // setelah touch pertama, ini yang digunakan jika tidak mati
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            }
        }
        
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if isDied == true {
                //jika mati
                if restartBtn.contains(location){
                    //jika lokasi touch sama dengan lokasi restartBtn
                    if UserDefaults.standard.object(forKey: "highestScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                        //jika hscore sebelumnya kurang dari hscore yg sekarang maka set highestscore = scoreLbl.text yg sekarang
                        if hscore < Int(scoreLbl.text!)!{
                            UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "highestScore")
                    }
                    
                    restartScene()
                }
                
            } else {
                
                //jika lokasi touch sama dengan lokasi pauseBtn
                if pauseBtn.contains(location){
                    if self.isPaused == false {
                        self.isPaused = true
                        pauseBtn.texture = SKTexture(imageNamed: "play")
                    } else {
                        self.isPaused = false
                        pauseBtn.texture = SKTexture(imageNamed: "pause")
                    }
                }
                
            }
            
            
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if isGameStarted == true {
            if isDied == false {
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y) //background berjalan
                    if bg.position.x <= -bg.size.width { //jika bgPertama sudah melewati frame hp sepenuhnya maka, posisi bgPertama akan berada di belakang bgKedua
                        bg.position = CGPoint(x: bg.position.x + (bg.size.width * 2), y: bg.position.y)
                    }
                }))
            }
        }
        //The background only moves after the isGameStarted and isDied boolean flags test are fulfilled
        
        
    }
    
    
    func createScene() {
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        //The method above will create a physics body around the entire screen using the edgeLoopFrom initializer. Then, you just used the CollisionBitMask struct constants you defined earlier, the categoryBitMask property is set to the groundCategory while the collisionBitMask and contactTestBitMask are set to the birdCategory constant because we want to detect collisions and contacts with the bird.
        //Setting the affectedByGravity to false will prevent the player from falling off the screen.
        //The purpose is that the Game object (the bird) will collide with the walls around the screen
        //Intinya yang diatas untuk setiap edge khususnya edge atas dan bawah akan bersentuhan dan tidak membiarkan flapBird tidak jatuh dan tidak keatas.
        
        for i in 0..<2 {
            
            let background = SKSpriteNode(imageNamed: "bg")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
            //untuk background yang terus berjalan
        }
        
        birdSprites.append(birdAtlas.textureNamed("bird-01"))
        birdSprites.append(birdAtlas.textureNamed("bird-02"))
        birdSprites.append(birdAtlas.textureNamed("bird-03"))
        birdSprites.append(birdAtlas.textureNamed("bird-04"))
        
        self.bird = createBird()
        self.addChild(bird)
        
        //PREPARE TO ANIMATE THE BIRD AND REPEAT THE ANIMATION FOREVER
        let animateBird = SKAction.animate(with: self.birdSprites as! [SKTexture], timePerFrame: 0.1)
        self.repeatActionBird = SKAction.repeatForever(animateBird)
        
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        //apabila dinyatakan ADA bird dengan pillar atau sebaliknya pada bodyA dan bodyB, dan juga bird dengan ground atau sebaliknya, maka dieksekusi
        if firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.pillarCategory || firstBody.categoryBitMask == CollisionBitMask.pillarCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory || firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory {
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            
            if isDied == false {
                isDied = true
                createRestartBtn()
                pauseBtn.removeFromParent()
                self.bird.removeAllActions()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.flowerCategory {
            //untuk nambah score saat mengenai flower
            run(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.flowerCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory {
            //untuk nambah score saat mengenai flower
            run(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
    }
    
    
    func restartScene() {
        
        self.removeAllChildren()
        self.removeAllActions()
        isDied = false
        isGameStarted = false
        score = 0
        createScene()
    }
    
}
