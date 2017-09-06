import UIKit
import SceneKit

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > spawnTime {
            spawnShape()
            cleanScene()
            spawnTime = time + TimeInterval(randomBetweenNumbers(firstNum: 0.2, secondNum: 2.5))
        }
    }
}

class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var spawnTime: TimeInterval = 0
    var count = 0
    
    var hitLabel: SCNText!
    var missLabel: SCNText!
    var accuracyLabel: SCNText!
    
    var hitLabelNode: SCNNode!
    var missLabelNode: SCNNode!
    var accuracyLabelNode: SCNNode!
    
    var itemCount = 0 {
        didSet {
            
        }
    }
    var hit = 0
    var missed = 0
    var accuracy = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupHUD()
        setupCamera()
        //spawnShape()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        scnView.scene = scnScene
        scnView.backgroundColor = UIColor.black
        scnView.showsStatistics = true
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        
        scnView.delegate = self
        scnView.isPlaying = true
    }
    func setupHUD() {
        
        hitLabelNode = SCNNode()
        hitLabelNode.name = "hitLabelNode"
        hitLabel = SCNText()
        hitLabel.string = ("hit: \(hit)")
        hitLabel.font.withSize(3.2)
        hitLabel.materials.first?.diffuse.contents = UIColor.blue
        hitLabel.name = "hitLabel"
        hitLabelNode.geometry = hitLabel
        
        missLabelNode = SCNNode()
        missLabelNode.name = "missLabelNode"
        missLabel = SCNText()
        missLabel.string = ("MISS: \(missed)")
        missLabel.font.withSize(2.0)
        missLabel.materials.first?.diffuse.contents = UIColor.yellow
        missLabel.name = "missLabel"
        missLabelNode.geometry = missLabel
        
        accuracyLabelNode = SCNNode()
        accuracyLabel = SCNText()
        accuracyLabel.string = ("0%")
        accuracyLabel.font.withSize(-1.0)
        accuracyLabel.materials.first?.diffuse.contents = UIColor.white
        accuracyLabelNode.geometry = accuracyLabel
        
        let maxX = scnView.frame.width / 2
        let maxY = scnView.frame.height / 2
    
        hitLabelNode.position = SCNVector3(-3,10,0)
        missLabelNode.position = SCNVector3(1.5,10,0)
        accuracyLabelNode.position = SCNVector3(1,10,0)
        
        hitLabelNode.scale = SCNVector3(0.03,0.03,1)
        missLabelNode.scale = SCNVector3(0.03,0.03,1)
        accuracyLabelNode.scale = SCNVector3(0.03,0.03,1)
        
        scnScene.rootNode.addChildNode(hitLabelNode)
        scnScene.rootNode.addChildNode(missLabelNode)
        //scnScene.rootNode.addChildNode(accuracyLabelNode)
        
    }
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
    }
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x:0,y:5,z:10)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    func spawnShape() {
        var geometry:SCNGeometry
        switch ShapeType.random() {
        case ShapeType.capsule:
            geometry = SCNCapsule()
        case ShapeType.cone:
            geometry = SCNCone()
        case ShapeType.cylinder:
            geometry = SCNCylinder()
        case ShapeType.pyramid:
            geometry = SCNPyramid()
        case ShapeType.sphere:
            geometry = SCNSphere()
        case ShapeType.torus:
            geometry = SCNTorus()
        case ShapeType.tube:
            geometry = SCNTube()
        default:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        }
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        let randomX = randomBetweenNumbers(firstNum: -2, secondNum: 2)
        let randomY = randomBetweenNumbers(firstNum: 10, secondNum: 18)
        let force = SCNVector3(x: Float(randomX), y:Float(randomY), z: 0)
        let position = SCNVector3(x: 0.05, y:0.05, z:0.05)
        geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true)
        geometry.materials.first?.diffuse.contents = generateRandomColor()
        let emissionColor = generateRandomColor().withAlphaComponent(0.1)
        
        /*if count % 3 == 0 {
            let trailEmitter = createTrail(color: emissionColor, geometry: geometry)
            geometryNode.addParticleSystem(trailEmitter)
            print(count)
            //is far too memory intensive for the simulator to handle the mixing of coloured smoke clouds.
            //even with this counter
        }*/
        //count += 1
        
        geometry.materials.first?.emission.contents = emissionColor
        //UIColor.red.withAlphaComponent(0.8)
        scnScene.rootNode.addChildNode(geometryNode)
        
        itemCount += 1
    }
    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -1 {
                node.removeFromParentNode()
                itemCount -= 1
                missed += 1
                
                let mod = scnScene.rootNode.childNode(withName: "missLabelNode", recursively: true)
                missLabel.string = ("MISS: \(missed)")
                mod?.geometry = missLabel
            }
        }
    }
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let trail = SCNParticleSystem(named: "SmokeTrail.scnp", inDirectory: nil)!
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs (firstNum - secondNum) + min(firstNum, secondNum);
    }
    func generateRandomColor()->UIColor{
        let r = randomBetweenNumbers(firstNum: 0.0, secondNum: 1.0)
        let g = randomBetweenNumbers(firstNum: 0.0, secondNum: 1.0)
        let b = randomBetweenNumbers(firstNum: 0.0, secondNum: 1.0)
        return UIColor(red: r, green: g, blue: b, alpha: 0.8)
    }
    //MARK: User Interaction Logic.
    func handleTouchFor(node: SCNNode) {
        if node != missLabelNode && node != hitLabelNode && node != accuracyLabelNode {
        createSmokeOut(geometry: node.geometry!, position: node.presentation.position, rotation: node.presentation.rotation)
        node.removeFromParentNode()
        
        itemCount -= 1
        hit += 1
            
            let mod = scnScene.rootNode.childNode(withName: "hitLabelNode", recursively: true)
            hitLabel.string = ("HIT: \(hit)")
            mod?.geometry = hitLabel
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        if let result = hitResults.first {
            handleTouchFor(node: result.node)
        }
    }
    //MARK: User Interaction effects.
    func createSmokeOut(geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4){
        let smoked = SCNParticleSystem(named: "SmokeTrail.scnp", inDirectory: nil)!
        smoked.emitterShape = geometry
        smoked.birthLocation = .surface
        smoked.particleColor = geometry.materials.first?.diffuse.contents as! UIColor
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z)
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scnScene.addParticleSystem(smoked, transform: transformMatrix)
    }
}
