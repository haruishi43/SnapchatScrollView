//
//  ViewController+Animation.swift
//  SnapchatCollectionView
//
//  Created by Haruya Ishikawa on 2018/04/12.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

extension ViewController {
    
    // MARK: - Manager for animation
    func animate(to targetView: CurrentViews) {
        print("[\(currentView.rawValue)]")
        
        switch currentView {
        case .main:
            switch targetView {
            case .filterMode:
                mainToFilterMode()
            default:
                break
            }
        case .filterMode:
            switch targetView {
            case .main:
                filterModeToMain()
            default:
                break
            }
        default:
            break
        }
        
        currentView = targetView
        print("-> [\(currentView.rawValue)]")
    }
    
    // MARK: - Animation Functions
    private func animateToMain() {
        self.filterModeButtonBottomConstraint.constant = 12
        self.filterModeView?.hide()
        self.showRecordButton()
    }
    
    private func mainToFilterMode() {
        filterModeView?.show()
        recordButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.hideFilterModeButton()
            self.changeRecordingButtonForFilterMode()
            self.view.layoutIfNeeded()
        })
        
    }
    
    private func fromFilterMode() {
        filterModeView?.hide(false)
        recordButtonImage.image = #imageLiteral(resourceName: "record")
        recordButton.isUserInteractionEnabled = true
    }
    
    func filterModeExited() {
        fromFilterMode()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.animateToMain()
            self.view.layoutIfNeeded()
        })
    }
    
    private func filterModeToMain() {
        filterModeView?.hide()
        recordButtonImage.image = #imageLiteral(resourceName: "record")
        recordButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.animateToMain()
            self.view.layoutIfNeeded()
        })
    }
    
}
