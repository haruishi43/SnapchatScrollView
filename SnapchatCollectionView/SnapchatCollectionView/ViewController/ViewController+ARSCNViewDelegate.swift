//
//  ViewController+ARSCNViewDelegate.swift
//  SnapchatCollectionView
//
//  Created by Haruya Ishikawa on 2018/04/12.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

extension ViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("error launching ARSession: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("session was interrupted ended")
    }
}
