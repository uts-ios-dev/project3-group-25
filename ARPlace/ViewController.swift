

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var placeObjectCollectionView: UICollectionView!
    
    let config = ARWorldTrackingConfiguration()
    
    var selectedObject : String?
    let placeObjectArray : [String] = ["box","sphere","cylinder","pyramid","ship","reset"]
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints
        ]
        placeObjectCollectionView.dataSource = self
        placeObjectCollectionView.delegate = self
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        sceneView.autoenablesDefaultLighting = true
        registerGestureRecognizers()
        sceneView.session.run(config)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func registerGestureRecognizers() {
        let tapGesutreReconizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        let pinchGestureReconizer = UIPinchGestureRecognizer(target: self, action: #selector(onPinch))
        sceneView.addGestureRecognizer(tapGesutreReconizer)
        sceneView.addGestureRecognizer(pinchGestureReconizer)
    }
    
    @objc func onPinch(sender:UIPinchGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        
        if !hitTest.isEmpty{
            let result = hitTest.first!
            let node = result.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @objc func onTap(sender: UITapGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            placeObjectOnSurface(hitTestResult: hitTest.first!)
        }
        
    }
    
    func placeObjectOnSurface(hitTestResult : ARHitTestResult)
    {
        if let selectedObject = self.selectedObject {
            let node = SCNNode()
            if selectedObject == "box" {
                node.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.orange;
                node.geometry?.firstMaterial?.specular.contents = UIColor.green;
            }else if selectedObject == "sphere"{
                node.geometry = SCNSphere(radius: 0.05)
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.gray;
                node.geometry?.firstMaterial?.specular.contents = UIColor.white;
            }else if selectedObject == "cylinder"{
                node.geometry = SCNCylinder(radius: 0.05, height: 0.1)
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue;
                node.geometry?.firstMaterial?.specular.contents = UIColor.white;
            }else if selectedObject == "pyramid"{
                node.geometry = SCNPyramid(width: 0.05, height: 0.1, length: 0.1)
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.red;
                node.geometry?.firstMaterial?.specular.contents = UIColor.brown;
            }else if selectedObject == "ship"{
                let scene = SCNScene(named: "Objects/ship.scn")
                let node = scene?.rootNode.childNode(withName: "ship", recursively: false)
                let transform = hitTestResult.worldTransform
                let pos = transform.columns.3   //vector
                node?.position = SCNVector3(pos.x,pos.y,pos.z)
                sceneView.scene.rootNode.addChildNode(node!)
                return
            }
            
            
            let transform = hitTestResult.worldTransform;
            let pos = transform.columns.3
            node.position = SCNVector3(pos.x,pos.y,pos.z)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeObjectArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placeable", for: indexPath) as! placeObjectCell
        cell.placeObjectLabel.text = self.placeObjectArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        selectedObject = placeObjectArray[indexPath.row]
        if selectedObject == "reset" {
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
        }
        else{
            cell?.backgroundColor = UIColor.red
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray
    }
}

