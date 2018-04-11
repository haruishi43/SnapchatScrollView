//
//  FilterModeView.swift
//  SnapchatCollectionView
//
//  Created by Haruya Ishikawa on 2018/04/11.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit

protocol FilterModeViewInput: class {
    func show()
    func hide(_ record: Bool)
}

protocol FilterModeViewDelegate: class {
    func exitFilterMode()
    func showMessage(text: String)
    func filterModeViewRecord(_ sender: UILongPressGestureRecognizer)
}

class FilterModeView: UIView {
    static let screenSize: CGRect = UIScreen.main.bounds
    static let height: CGFloat = 136
    
    lazy var bottomSafeAreaInset: CGFloat = {
        // different for iphoneX
        return 0
    }()
    
    static func instantiateNibView() -> FilterModeView {
        let nibName = String(describing: FilterModeView.self)
        let view = UINib(nibName: nibName, bundle: Bundle(for: self))
            .instantiate(withOwner: self, options: nil)[0] as! FilterModeView
        view.frame = CGRect(x: screenSize.width, y: screenSize.height - height, width: screenSize.width, height: height)
        return view
    }
    
    // MARK: - UI Items:
    @IBOutlet weak var filterModeCollectionView: UICollectionView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var exitButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Variables:
    private let utils = Utils()
    var filterModeDataSource: FilterModeDataSource?
    weak var delegate: FilterModeViewDelegate?
    
    //var currentObject: ARObject?
    var currentIndex: Int = 0
    
    override func awakeFromNib() {
        // setup
        backgroundColor = .clear
        
        setupCollectionView()
    }
    
    @IBAction func tapExitButton(_ sender: UIButton) {
        delegate?.exitFilterMode()
    }
    
    // MARK: - Setup Functions:
    private func setupCollectionView() {
        
        let layout = FilterModeCollectionViewFlowLayout()
        
        let nibName = String(describing: FilterModeCell.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        
        filterModeDataSource = FilterModeDataSource(view: self, collectionView: filterModeCollectionView)
        filterModeDataSource?.messageDelegate = self
        filterModeDataSource?.delegate = self
        
        filterModeCollectionView.backgroundColor = .clear
        filterModeCollectionView.showsHorizontalScrollIndicator = false
        filterModeCollectionView.register(nib, forCellWithReuseIdentifier: "FilterModeCell")
        filterModeCollectionView.collectionViewLayout = layout
        filterModeCollectionView.tag = 0
        filterModeCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        filterModeCollectionView.delegate = self.filterModeDataSource
        filterModeCollectionView.dataSource = self.filterModeDataSource
    }
}

extension FilterModeView: FilterModeViewInput {
    func show() {
        let w: CGFloat = FilterModeView.screenSize.width
        let h: CGFloat = FilterModeView.screenSize.height
        self.exitButton.isHidden = true
        
        filterModeDataSource?.goToBeginning()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 0,
                                y: h - FilterModeView.height - self.bottomSafeAreaInset,
                                width: w,
                                height: FilterModeView.height)
        }, completion: { finished in
            self.exitButton.isHidden = false
            UIView.animate(withDuration:0.2, animations: {
                self.exitButtonBottomConstraint.constant = 20
            })
            
        })
        filterModeCollectionView.reloadData()
    }
    
    func hide(_ record: Bool = true) {
        let w: CGFloat = FilterModeView.screenSize.width
        let h: CGFloat = FilterModeView.screenSize.height
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: w,
                                y: h - FilterModeView.height - self.bottomSafeAreaInset,
                                width: w,
                                height: FilterModeView.height)
        }, completion: { finished in
            UIView.animate(withDuration:0.2, animations: {
                self.exitButtonBottomConstraint.constant = 86
                self.exitButton.isHidden = true
            })
        })
    }
}

extension FilterModeView: FilterModeMessageDelegate {
    func showMessage(_ text: String) {
        delegate?.showMessage(text: text)
    }
}

extension FilterModeView: FilterModeDataSourceDelegate {
    func goToRecord(_ sender: UILongPressGestureRecognizer) {
        delegate?.filterModeViewRecord(sender)
    }
    
}
