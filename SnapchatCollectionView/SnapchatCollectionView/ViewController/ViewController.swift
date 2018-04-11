//
//  ViewController.swift
//  SnapchatCollectionView
//
//  Created by Haruya Ishikawa on 2018/04/11.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum CurrentViews: String {
    case main = "camera_main"
    case filterMode = "camera_filter_mode"
}

class ViewController: UIViewController, ARSessionDelegate {

    let session = ARSession()
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        return configuration
    }()
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var recordButton: UIView!
    @IBOutlet weak var recordButtonImage: UIImageView!
    @IBOutlet weak var filterModeButton: UIButton!
    
    // MARK: - Constraints
    @IBOutlet weak var recordButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterModeButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - SubViews
    var filterModeView: FilterModeView?
    
    let myBoundSize: CGSize = UIScreen.main.bounds.size
    
    // state
    var currentView: CurrentViews = .main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the scene view
        setupScene()
        
        // Setup Views
        setFilterModeView()
        
        session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    // MARK: - Setup functions
    
    func setupScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.session = session
        sceneView.session.delegate = self
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        // Note: - About "showStatistics" option:
        // link: https://stackoverflow.com/questions/31214326/what-does-the-scenekit-statistics-window-tell-us
        // Rendering in Mt = Metal
        // what does "waitDrawable" mean?
    }
    
    func setFilterModeView() {
        filterModeView = FilterModeView.instantiateNibView()
        filterModeView?.delegate = self
        view.addSubview(filterModeView!)
    }
}
