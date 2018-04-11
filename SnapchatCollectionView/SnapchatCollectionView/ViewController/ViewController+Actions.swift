//
//  ViewController+Actions.swift
//  SnapchatCollectionView
//
//  Created by Haruya Ishikawa on 2018/04/12.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

extension ViewController: FilterModeViewDelegate {
    func exitFilterMode() {
        filterModeExited()
        currentView = .main
    }
    
    func showMessage(text: String) {
        print("can not download")
    }
    
    func filterModeViewRecord(_ sender: UILongPressGestureRecognizer) {
        print("...")
    }
}

extension ViewController {
    @IBAction func filterModeButtonPressed(_ button: UIButton) {
        animate(to: .filterMode)
    }
    
    // MARK: - recordButton
    func showRecordButton(){
        self.recordButtonBottomConstraint.constant = 60
    }
    
    func hideRecordButton(){
        self.view.bringSubview(toFront: recordButton)
        self.recordButtonBottomConstraint.constant = -CGFloat(136 + self.view.safeAreaInsets.bottom)
    }
    
    func changeRecordingButtonForFilterMode() {
        self.recordButtonImage.image = #imageLiteral(resourceName: "face_mode_record_ring")
        self.recordButtonBottomConstraint.constant = 60
        self.view.bringSubview(toFront: recordButton)
    }
    
    func hideFilterModeButton() {
        self.filterModeButtonBottomConstraint.constant = -CGFloat(52 + self.view.safeAreaInsets.bottom)
    }
}
