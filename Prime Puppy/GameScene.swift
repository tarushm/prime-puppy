//
//  GameScene.swift
//  Prime Puppy
//
//  Created by Tarush Mohanti on 11/12/16.
//  Copyright © 2016 tarush. All rights reserved.
//


//
// This controls the game.
// User receives one point for not hitting the poles. The prime score uses the Sieve of Eratosthenes to count how many prime points the user receives.
//
// The underlying game mechanics are adapted from Flappy Bird

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Declare all sprite nodes and lables
    
    var dog = SKSpriteNode()
    
    var bg = SKSpriteNode()
    
    var coin = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    
    var highScoreLabel = SKLabelNode()
    
    var levelLabel = SKLabelNode()
    
    var score = 0
    
    var gameOverLabel = SKLabelNode()
    
    var timer = Timer()
    
    // To know when and what object has been hit
    
    enum ColliderType: UInt32 {
        
        case Dog = 1
        case Object = 2
        case Gap = 4
        case Coin = 8
        
    }
    
    var gameOver = false
    
    
    // The blocks that aren't supposed to be hit are the bones
    func makeBones() {
        
        
        // This is to insure that the bones keep coming at a regular time interval
        let moveBones = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        
        let removeBones = SKAction.removeFromParent()
        
        let moveAndRemoveBones = SKAction.sequence([moveBones, removeBones])
        
        // The gap height can influence the difficulty of the game
        let gapHeight = dog.size.height * 3
        
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        
        let boneOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        let boneTexture = SKTexture(imageNamed: "bone1.png")
        
        let bone1 = SKSpriteNode(texture: boneTexture)
        
        // One of these is the upper bone and the other is the lower bone
        
        bone1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + boneTexture.size().height / 2 + gapHeight / 2 + boneOffset)
        
        bone1.run(moveAndRemoveBones)
        
        bone1.physicsBody = SKPhysicsBody(rectangleOf: boneTexture.size())
        bone1.physicsBody!.isDynamic = false
        
        //Determining collisions
        bone1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bone1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        bone1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        bone1.zPosition = -1
        
        self.addChild(bone1)
        
        let bone2Texture = SKTexture(imageNamed: "bone2.png")
        
        let bone2 = SKSpriteNode(texture: bone2Texture)
        
        bone2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - bone2Texture.size().height / 2 - gapHeight / 2 + boneOffset)
        
        bone2.run(moveAndRemoveBones)
        
        bone2.physicsBody = SKPhysicsBody(rectangleOf: boneTexture.size())
        bone2.physicsBody!.isDynamic = false
        
        bone2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bone2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        bone2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        bone2.zPosition = -1
        
        self.addChild(bone2)
        
        // The gap acts almost identically to a bone, but does not cause a death when hit. This is how the scoring of the game works
        
        let gap = SKNode()
        
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + boneOffset)
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: boneTexture.size().width, height: gapHeight))
        
        gap.physicsBody!.isDynamic = false
        
        gap.run(moveAndRemoveBones)
        
        gap.physicsBody!.contactTestBitMask = ColliderType.Dog.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        self.addChild(gap)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false {
            
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                
                score += 1
                
                scoreLabel.text = String(score)
                
                // Accessing permanent data storage, so that we can retain the scores
                
                let highScoreObject = UserDefaults.standard.object(forKey: "highScore")
                
                
                if let highScore = highScoreObject as? Int {
                    
                    highScoreLabel.text = String(highScore)
                    
                    // This logic is the use of the Sieve of Eratosthenes as a count of how many prime points the User has received
                    
                    levelLabel.text = String(numPrimes(arr: sieve(count: highScore)))

                    
                    print(highScore)
                    
                    if (score > highScore) {
                        
                        UserDefaults.standard.set(score, forKey: "highScore")
                        print(highScore)
                        print(score)
                        
                    }
                    
                    
                }
                
                else {
                    
                    UserDefaults.standard.set(score, forKey: "highScore")
                }

                
            } else {
                
                self.speed = 0
                
                gameOver = true
                
                timer.invalidate()
                
                gameOverLabel.fontName = "Helvetica"
                
                gameOverLabel.fontSize = 30
                
                gameOverLabel.text = "Game Over! Tap to play again."
                
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                
                self.addChild(gameOverLabel)
                
            }
            
        }
        
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupGame()
        
    }
    
    func setupGame() {
        
        // Sets up the background, making sure it loops continuosly with no gaps or breaks.
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makeBones), userInfo: nil, repeats: true)
        
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        var i: CGFloat = 0
        
        while i < 3 {
            
            bg = SKSpriteNode(texture: bgTexture)
            
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            
            bg.size.height = self.frame.height
            
            bg.run(moveBGForever)
            
            bg.zPosition = -2
            
            self.addChild(bg)
            
            i += 1
            
        }
        
        
        let dogTexture = SKTexture(imageNamed: "puppy1.png")
        let dogTexture2 = SKTexture(imageNamed: "puppy2.png")
        
        
        
        let animation = SKAction.animate(with: [dogTexture, dogTexture2], timePerFrame: 0.1)
        let makeDogWalk = SKAction.repeatForever(animation)
        
        dog = SKSpriteNode(texture: dogTexture)
        
        dog.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        dog.run(makeDogWalk)
        
        // The dog is treated roughly as a circle
        
        dog.physicsBody = SKPhysicsBody(circleOfRadius: dogTexture.size().height / 2)
        
        dog.physicsBody!.isDynamic = false
        
        dog.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        dog.physicsBody!.categoryBitMask = ColliderType.Dog.rawValue
        dog.physicsBody!.collisionBitMask = ColliderType.Dog.rawValue
        
        self.addChild(dog)
        
        let ground = SKNode()
        
        //This is to make sure the game ends when the dog hits the floor
        
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        
        ground.physicsBody!.isDynamic = false
        
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        
        // Where the various scoring methods are displayed
        
        scoreLabel.fontName = "Helvetica"
        
        scoreLabel.fontSize = 60
        
        scoreLabel.text = "0"
        
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        
        self.addChild(scoreLabel)
        
        highScoreLabel.fontName = "Helvetica"
        
        highScoreLabel.fontSize = 30
        
        highScoreLabel.text = "HIGH SCORE"
        
        highScoreLabel.position = CGPoint(x: self.frame.midX - 250, y: self.frame.height / 2 - 70)
        
        self.addChild(highScoreLabel)
        
        levelLabel.fontName = "Helvetica"
        
        levelLabel.fontSize = 30
        
        levelLabel.text = "PRIME SCORE"
        
        levelLabel.position = CGPoint(x: self.frame.midX + 250, y: self.frame.height / 2 - 70)
        
        self.addChild(levelLabel)
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // The dog will only start moving and the game will start when touched
        
        if gameOver == false {
            
            dog.physicsBody!.isDynamic = true
            
            dog.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            
            dog.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 150))
            
            let highScoreObject = UserDefaults.standard.object(forKey: "highScore")
            
            if let highScore = highScoreObject as? Int {
                
                highScoreLabel.text = String(highScore)
                print(highScore)
            }
            
            
        } else {
            
            gameOver = false
            
            score = 0
            
            self.speed = 1
            
            self.removeAllChildren()
            
            setupGame()
            
            
        }
        
        
    }
    
    // Implementation of the sieve algorithm, taking a certain count and returning a Boolean array O(n log log n)
    
    func sieve (count:Int) -> [Bool] {
        
        assert(count > 0, "Value must be a positive integer")
        
        var A = [Bool!](repeating: true, count: count)
        
        var i = 2
        while (i <= Int(sqrt(Double(count)))){
            
            if A[i]! {
                
                var j = (i*i)
                while (j < count){
                    
                    A[j] = false
                    j += i
                    
                }
                
            }
            
            i += 1
            
        }
        
        return(A)
        
    }
    
    // A way to numerate the specific primes. O(n)
    
    func numPrimes ( arr:[Bool]) -> Int {
        var i = 0
        for (index,element) in arr.enumerated(){
            if element {
                i += 1
            }
        }
        return i
    }

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
}
