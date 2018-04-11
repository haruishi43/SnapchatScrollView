//
//  FilterModeDataSource.swift
//  SnapchatCollectionView
//
//  Created by Haruya Ishikawa on 2018/04/11.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit

enum NearestPointDirection: Int {
    case any
    case left
    case right
}

protocol FilterModeDataSourceDelegate: class {
    func goToRecord(_ sender: UILongPressGestureRecognizer)
}

protocol FilterModeMessageDelegate: class {
    func showMessage(_ text: String)
}

class FilterModeDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Variables:
    private var scrollVelocity: CGFloat = 0.0
    private var collectionViewCenter: CGFloat
    private let utils = Utils()
    weak var delegate: FilterModeDataSourceDelegate?
    weak var messageDelegate: FilterModeMessageDelegate?
    var selectedItem: Int = 0
    
    // MARK: - UI Items:
    private let filterModeView: FilterModeView
    private let filterModeCollectionView: UICollectionView
    private let selectionFB = UISelectionFeedbackGenerator()
    
    init(view: UIView, collectionView: UICollectionView) {
        self.filterModeView = view as! FilterModeView
        self.filterModeCollectionView = collectionView
        collectionViewCenter = filterModeCollectionView.bounds.width / 2
    }
    
    // MARK: - Delegate Functions:
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 1
        count = count + 100 // Change here
        print("[Items: " + String(count) + "]")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var filterModeCell: FilterModeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterModeCell", for: indexPath) as! FilterModeCell
        filterModeCell = refreshCell(cell: filterModeCell)
        filterModeCell = createCell(cell: filterModeCell, index: indexPath.item)
        
        return filterModeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        scrollViewWillBeginDragging(collectionView)
        selectedItem = indexPath.item
        
        let layout: FilterModeCollectionViewFlowLayout = collectionView.collectionViewLayout as! FilterModeCollectionViewFlowLayout
        let x: CGFloat = CGFloat(selectedItem) * CellConstants.normalWidth
        layout.ignoringBoundsChange = true
        collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        layout.ignoringBoundsChange = false
        
        perform(#selector(self.scrollViewDidEndDecelerating), with: collectionView, afterDelay: 0.3)
    }
    
    func goToBeginning() {
        // scroll to index 0 (not perfect since layout is messy here)
        filterModeCollectionView.reloadData()
        filterModeCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        // scroll to the exact place and select index 0
        perform(#selector(self.collectionView(_:didSelectItemAt:)), with: filterModeCollectionView, with: IndexPath(item: 0, section: 0))
    }
    
    // MARK: - Supporting Functions:
    
    /// Create the initial cell
    private func createCell(cell: FilterModeCell, index: Int) -> FilterModeCell {
        
        cell.downloadImageView.image = #imageLiteral(resourceName: "face_mode_downloading_overlay")
        cell.indicator.startAnimating()
        
        // Prepare cell here...
        
        cell.indicator.stopAnimating()
        
        //cell.downloadImageView.image = nil // remove the image
        return cell
    }
    
    /// Called when cell is selected
    private func selectedCell(cell: FilterModeCell, index: Int) {
        print("selected: " + String(selectedItem))
        
        // Cell selected delegate
        
    }
    
    /// Refresh the cell
    func refreshCell(cell: FilterModeCell) -> FilterModeCell {
        cell.filterImage.image = nil
        return cell
    }
    
    // MARK: - Animation:
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.selectedItem == Int.max { return }
        
        let previousSelectedIndex: Int = selectedItem
        // add a placeholder value for selectedItem while scrolling
        selectedItem = Int.max
        
        reloadCell(at: IndexPath(item: previousSelectedIndex, section: 0), withSelectedState: false)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollVelocity = velocity.x
        
        if scrollVelocity == 0 {
            targetContentOffset.pointee = offset(forCenterX: targetContentOffset.pointee.x + collectionViewCenter, with: .any)
        }
        if scrollVelocity < 0 {
            targetContentOffset.pointee = offset(forCenterX: targetContentOffset.pointee.x + collectionViewCenter, with: .left)
        }
        else if scrollVelocity > 0 {
            targetContentOffset.pointee = offset(forCenterX: targetContentOffset.pointee.x + collectionViewCenter, with: .right)
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        reloadCell(at: IndexPath(item: selectedItem, section: 0), withSelectedState: true)
        // Haptic feedback
        selectionFB.selectionChanged()
        
        //IMPORTANT: Perform delegate for selecting:
        if let cell: FilterModeCell = filterModeCollectionView.cellForItem(at: IndexPath(item: selectedItem, section: 0)) as? FilterModeCell {
            selectedCell(cell: cell, index: selectedItem)
        }
    }
    
    /// Reload cell so it becomes selected or unselected
    func reloadCell(at indexPath: IndexPath, withSelectedState selected: Bool) {
        let cell: UICollectionViewCell? = filterModeCollectionView.cellForItem(at: indexPath)
        cell?.isSelected = selected
    }
    
    // Calculate the offset to the center from the nearest cell
    func offset(forCenterX centerX: CGFloat, with direction: NearestPointDirection) -> CGPoint {
        let leftNearestCenters = nearestLeftCenter(forCenterX: centerX)
        let leftCenterIndex: Int = leftNearestCenters.index
        let leftCenter: CGFloat = leftNearestCenters.value
        let rightNearestCenters = nearestRightCenter(forCenterX: centerX)
        let rightCenterIndex: Int = rightNearestCenters.index
        let rightCenter: CGFloat = rightNearestCenters.value
        var nearestItemIndex: Int = Int.max
        switch direction {
        case .any:
            if leftCenter > rightCenter {
                nearestItemIndex = rightCenterIndex
            } else {
                nearestItemIndex = leftCenterIndex
            }
        case .left:
            nearestItemIndex = leftCenterIndex
        case .right:
            nearestItemIndex = rightCenterIndex
        }
        selectedItem = nearestItemIndex
        return CGPoint(x: CGFloat(nearestItemIndex) * CellConstants.normalWidth, y: 0.0)
    }
    
    /// Getting the nearest cell attributes on the left
    func nearestLeftCenter(forCenterX centerX: CGFloat) -> (index: Int, value: CGFloat) {
        let nearestLeftElementIndex: CGFloat = (centerX - collectionViewCenter - CellConstants.centeredWidth + CellConstants.normalWidth) / CellConstants.normalWidth
        let minimumLeftDistance: CGFloat = centerX - nearestLeftElementIndex * CellConstants.normalWidth - collectionViewCenter - CellConstants.centeredWidth + CellConstants.normalWidth
        return (Int(nearestLeftElementIndex), minimumLeftDistance)
    }
    
    /// Getting the nearest cell attributes on the right
    func nearestRightCenter(forCenterX centerX: CGFloat) -> (index: Int, value: CGFloat) {
        let nearestRightElementIndex: Int = Int(ceilf(Float((centerX - collectionViewCenter - CellConstants.centeredWidth + CellConstants.normalWidth) / CellConstants.normalWidth)))
        let minimumRightDistance: CGFloat = CGFloat(nearestRightElementIndex) * CellConstants.normalWidth + collectionViewCenter - centerX - CellConstants.centeredWidth + CellConstants.normalWidth
        return (nearestRightElementIndex, minimumRightDistance)
    }
    
    /// For recording
    @objc func cellLongPress(_ sender: UILongPressGestureRecognizer) {
        if selectedItem == sender.view?.tag { delegate?.goToRecord(sender) }
    }
}
