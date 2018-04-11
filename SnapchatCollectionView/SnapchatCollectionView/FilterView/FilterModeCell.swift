//
//  FilterModeCell.swift
//  SnapchatCollectionView
//
//  Created by Haruya Ishikawa on 2018/04/11.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit

class FilterModeCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var filterImage: UIImageView!
    @IBOutlet weak var downloadImageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var animating: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
