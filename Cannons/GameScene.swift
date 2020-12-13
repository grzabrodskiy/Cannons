//
//  GameScene.swift
//  Cannons
//
//  Created by Tatyana kudryavtseva on 28/08/16.
//  Copyright (c) 2016 Organized Chaos. All rights reserved.
//

import SpriteKit

// MARK: swipe constants

let kMinDistance  : CGFloat =  50
let kMinDuration  =  0.1
let kMinSpeed : Double =     100
let kMaxSpeed : Double =     500

// MARK: extensions

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}


#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    func distance (other : CGPoint)-> Double {
        return sqrt(Double((self.x - other.x)*(self.x - other.x) + (self.y - other.y)*(self.y - other.y)))
        
    }
    
}

// MARK: physics constants

struct PhysicsCategory {
    static let None      : UInt32 = 0
    
    static let UFO   : UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
    static let CannonL: UInt32 = 0b100
    static let CannonR: UInt32 = 0b1000
    static let ground: UInt32 = 0b10000
    
    static let All : UInt32 = UInt32.max
    
}


// MARK: class GameScene

class GameScene: SKScene , SKPhysicsContactDelegate{
    
    // MARK: major sprites
    let player = SKSpriteNode(imageNamed: "player")
    let cannonL = SKSpriteNode(imageNamed: "cannonL")
    let cannonR = SKSpriteNode(imageNamed: "cannonR")
    
    var cannonLPosition : CGPoint!
    var cannonRPosition : CGPoint!
    
    // MARK: gesture detection
    var gestStart : CGPoint!
    var gestStartTime : NSTimeInterval!
    
    // MARK: init
    override func didMoveToView(view: SKView) {
        
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.whiteColor()        // 3
        
        
        cannonLPosition = CGPoint(x: 50, y: 50)
        cannonRPosition = CGPoint(x: size.width - 50, y: 50)
        
        
        cannonL.size = CGSize(width: 50, height: 50)
        cannonR.size = CGSize(width: 50, height: 50)
    
        
        cannonL.position = cannonLPosition
        cannonR.position = cannonRPosition
        
        
        
        var initRotate = SKAction.rotateToAngle(CGFloat(M_PI/3), duration: 0)
        cannonL.runAction(initRotate)
        initRotate = SKAction.rotateToAngle(-CGFloat(M_PI/3), duration: 0)
        cannonR.runAction(initRotate)
        
        
        cannonL.physicsBody = SKPhysicsBody(circleOfRadius: cannonL.size.width/2)
        cannonL.physicsBody?.dynamic = true
        cannonL.physicsBody?.categoryBitMask = PhysicsCategory.CannonL
        cannonL.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        cannonL.physicsBody?.collisionBitMask = PhysicsCategory.None
        cannonL.physicsBody?.usesPreciseCollisionDetection = true
        
        cannonR.physicsBody = SKPhysicsBody(circleOfRadius: cannonR.size.width/2)
        cannonR.physicsBody?.dynamic = true
        cannonR.physicsBody?.categoryBitMask = PhysicsCategory.CannonR
        cannonR.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        cannonR.physicsBody?.collisionBitMask = PhysicsCategory.None
        cannonR.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(cannonL)
        addChild(cannonR)
        
        let ground = SKShapeNode()
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint (pathToDraw, nil, 40, 30);
        CGPathAddLineToPoint(pathToDraw, nil, size.width - 40, 30);
        ground.path = pathToDraw
        ground.strokeColor = SKColor.brownColor()
        ground.lineWidth = 5
        
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 5, height: ground.lineLength))// 1
        ground.physicsBody?.dynamic = true // 2
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground // 3
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.All
        ground.physicsBody?.collisionBitMask = PhysicsCategory.UFO // 5
        
        
        addChild(ground)

        
        
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMeteor),
                SKAction.waitForDuration(1.0)
                ])
            ))
    }
    
    

    //MARK: meteors
    
    func addMeteor(){
        
 
        
        let meteorType = arc4random_uniform(4)
        
        let meteor = SKSpriteNode(imageNamed: "met\(meteorType)")
        
        meteor.size = CGSize(width: 50,height: 50)
        
        meteor.physicsBody = SKPhysicsBody(rectangleOfSize: meteor.size) // 1
        meteor.physicsBody?.dynamic = true // 2
        meteor.physicsBody?.categoryBitMask = PhysicsCategory.UFO // 3
        meteor.physicsBody?.contactTestBitMask = PhysicsCategory.All
        meteor.physicsBody?.collisionBitMask = PhysicsCategory.UFO | PhysicsCategory.ground // 5
        

        let actualX = random(min: meteor.size.width/2, max: size.width - meteor.size.width/2)
        let actualY = size.height
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        let endX = random(min: meteor.size.width/2, max: size.width - meteor.size.width/2)
        let endY = CGFloat(0)
        
        
        meteor.position = CGPoint(x: actualX , y: actualY + meteor.size.width/2)
        
        addChild(meteor)
        
        
        let actionMove = SKAction.moveTo(CGPoint(x: endX, y: endY - meteor.size.width/2), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        meteor.runAction(SKAction.sequence([actionMove, actionMoveDone]))

        
        
    }
    
    
    
    // MARK: touches
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
        // 1 - Choose one of the touch es to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
 
        var dt = touch.timestamp - gestStartTime
        let magnitude = CGFloat(gestStart.distance(touchLocation))
        var speed = Double(magnitude) / dt;
        
        if !(magnitude >= kMinDistance && dt > kMinDuration || (speed >= kMinSpeed && speed <= kMaxSpeed)) {
            NSLog("not a swipe")
            return
            
        }
        
        // it was a swipe, let's manage it
        var dx = touchLocation.x - gestStart.x;
        var dy = touchLocation.y - gestStart.y;
        //dx = dx / magnitude;
        //dy = dy / magnitude;
        var angle = atan(dy/dx)
        
        NSLog("Swipe detected with speed = %g and direction (%g, %g)",speed, dx, dy);
        
        
        var actionRotate : SKAction
        
        if (gestStart.distance(cannonL.frame.origin) < 200){
            NSLog("left cannon")
            angle = angle - CGFloat(M_PI/6)
            gestStart = cannonL.position
            actionRotate = SKAction.rotateToAngle(angle, duration: 0.2)

            cannonL.runAction(actionRotate)
            
        }
        else if (gestStart.distance(cannonR.frame.origin) < 200){
            NSLog("right cannon")
            angle = angle + CGFloat(M_PI/6)
            
            gestStart = cannonR.position
            actionRotate = SKAction.rotateToAngle(angle, duration: 0.2)
            cannonR.runAction(actionRotate)

        }
        else {
            NSLog("no cannon")
            return
        }
        
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "cannonball")
        
        projectile.size = CGSize(width: 30, height: 30)
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.UFO
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        projectile.position = gestStart //cannonL.position
        
        addChild(projectile)
        
        let impulse = CGVector(dx: dx/10, dy: dy/10)
        
        let actionMove = SKAction.applyImpulse(impulse, atPoint: projectile.position, duration: 5.0)
        
        
        // 6 - Get the direction of where to shoot
        //let direction = CGPoint(x: dx, y: dy)
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        //let shootAmount = direction * 1000 * speed
        
        // 8 - Add the shoot amount to the current position
        //let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        //let actionMove = SKAction.moveTo(realDest, duration: 4.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.UFO != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithUFO(firstBody.node as! SKSpriteNode, UFO: secondBody.node as! SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Projectile != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.CannonL != 0)) {
            projectileDidCollideWithCannon(firstBody.node as! SKSpriteNode, projectile: secondBody.node as! SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Projectile != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.CannonR != 0)) {
            projectileDidCollideWithCannon(firstBody.node as! SKSpriteNode, projectile: secondBody.node as! SKSpriteNode)
        }
        
        
    }
    
    
    func projectileDidCollideWithUFO(projectile:SKSpriteNode, UFO:SKSpriteNode) {
        print("Hit")
        
        var burstPath = NSBundle.mainBundle().pathForResource("explosion", ofType: "sks")!
        
        NSLog(burstPath)
        
        var burstNode = NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath) as! SKEmitterNode
       
        
        
        burstNode.position = projectile.position
        
        burstNode.hidden = false
        
        print(self.children.count)
        self.addChild(burstNode)
        print(self.children.count)
        
        projectile.removeFromParent()
        UFO.removeFromParent()
        
        if (1 > 20) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    
    func projectileDidCollideWithCannon(cannon: SKSpriteNode, projectile: SKSpriteNode) {
        return
        print("Hit cannon")
        projectile.removeFromParent()
        cannon.removeFromParent()
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    /* Avoid multi-touch gestures (optional) */
        if (touches.count > 1) {
            return;
        }
        let touch = touches.first!
        let location = touch.locationInNode(self)
    // Save start location and time
        gestStart = location;
        gestStartTime = touch.timestamp;
    }
    
    
    
    

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    
}
