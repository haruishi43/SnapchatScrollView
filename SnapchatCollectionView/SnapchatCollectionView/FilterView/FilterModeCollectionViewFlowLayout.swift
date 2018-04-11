//
//  FilterModeCollectionViewFlowLayout.swift
//  SnapchatCollectionView
//
//  Created by Haruya Ishikawa on 2018/04/11.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit

/// The heights are declared as constants outside of the class so they can be easily referenced elsewhere
struct CellConstants {
    static let normalWidth: CGFloat = 54
    static let normalHeight: CGFloat = 50
    static let centeredWidth: CGFloat = 88 // originally 80
    static let centeredHeight: CGFloat = 76
}

class FilterModeCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    /// Content Offset
    var centerOffset: CGFloat {
        get {
            return (collectionView!.bounds.width - CellConstants.centeredWidth) / 2
        }
    }
    
    /// Dragging offset (used to calculate which cell is selected)
    var dragOffset: CGFloat {
        get { return CellConstants.normalWidth }
    }
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    /// Returns the width of the collection view
    var width: CGFloat {
        get { return collectionView!.bounds.width }
    }
    
    /// Returns the height of the collection view
    var height: CGFloat {
        get { return collectionView!.bounds.height }
    }
    
    /// Returns the number of items in the collection view
    var numberOfItems: Int {
        get { return collectionView!.numberOfItems(inSection: 0) }
    }
    
    /// Returns the item index of the currently featured cell (may not need)
    var featuredItemIndex: Int {
        get {
            // Use max to make sure the featureItemIndex is never < 0
            return max(0, Int(collectionView!.contentOffset.x / dragOffset))
        }
    }
    
    /// Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell (may not need)
    var nextItemPercentageOffset: CGFloat {
        get {
            return (collectionView!.contentOffset.x / dragOffset) - CGFloat(featuredItemIndex)
        }
    }
    
    // MARK: - UICollectionViewFlowLayout override
    
    /// Return the size of all the content in the collection view
    override var collectionViewContentSize: CGSize {
        let contentWidth: CGFloat = 2 * centerOffset + CellConstants.centeredWidth + CGFloat(numberOfItems - 1) * CellConstants.normalWidth
        return CGSize(width: contentWidth, height: height)
    }
    
    override func prepare() {
        // remove all of the layout initially (if needed)
        //        cache.removeAll(keepingCapacity: false)
        
        if cache.isEmpty || cache.count != numberOfItems {
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                cache.append(attributes)
            }
            updateLayout(forBounds: (collectionView?.bounds)!)
        }
        
    }
    
    /// Used to ignore bounds change when auto scrolling to certain cell
    var ignoringBoundsChange: Bool = false
    
    func updateLayout(forBounds newBounds: CGRect) {
        
        //print(">>>> Update Frame")
        
        let deltaX: CGFloat = CellConstants.centeredWidth - CellConstants.normalWidth
        let deltaY: CGFloat = CellConstants.centeredHeight - CellConstants.normalHeight
        let leftSideInset: CGFloat = (newBounds.width - CellConstants.centeredWidth) / 2
        
        for attribute: UICollectionViewLayoutAttributes in cache {
            let normalCellOffsetX: CGFloat = leftSideInset + CGFloat(attribute.indexPath.row) * CellConstants.normalWidth
            let normalCellOffsetY: CGFloat = (newBounds.height - CellConstants.normalHeight) / 2
            
            let distanceBetweenCellAndBoundCenters = normalCellOffsetX - newBounds.midX + CellConstants.centeredWidth / 2
            
            let normalizedCenterScale = distanceBetweenCellAndBoundCenters / CellConstants.normalWidth
            
            let isCenterCell: Bool = fabsf(Float(normalizedCenterScale)) < 1.0
            let isNormalCellOnRightOfCenter: Bool = (normalizedCenterScale > 0.0) && !isCenterCell
            let isNormalCellOnLeftOfCenter: Bool = (normalizedCenterScale < 0.0) && !isCenterCell
            
            if isCenterCell {
                let incrementX: CGFloat = (1.0 - CGFloat(fabs(Float(normalizedCenterScale)))) * deltaX
                let incrementY: CGFloat = (1.0 - CGFloat(fabs(Float(normalizedCenterScale)))) * deltaY
                
                let offsetX: CGFloat = normalizedCenterScale > 0 ? deltaX - incrementX : 0
                let offsetY: CGFloat = -incrementY / 2
                
                attribute.frame = CGRect(x: normalCellOffsetX + offsetX, y: normalCellOffsetY + offsetY, width: CellConstants.normalWidth + incrementX, height: CellConstants.normalHeight + incrementY)
            } else if isNormalCellOnRightOfCenter {
                attribute.frame = CGRect(x: normalCellOffsetX + deltaX, y: normalCellOffsetY, width: CellConstants.normalWidth, height: CellConstants.normalHeight)
            } else if isNormalCellOnLeftOfCenter {
                attribute.frame = CGRect(x: normalCellOffsetX, y: normalCellOffsetY, width: CellConstants.normalWidth, height: CellConstants.normalHeight)
            }
            
            //print(attribute.frame)
        }
        
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        updateLayout(forBounds: newBounds)
        return !ignoringBoundsChange
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let itemIndex = round(proposedContentOffset.x / dragOffset)
        let xOffset = itemIndex * dragOffset
        return CGPoint(x: xOffset, y: 0)
    }
}
