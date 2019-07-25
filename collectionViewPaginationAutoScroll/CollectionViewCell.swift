//
//  CollectionViewCell.swift
//  collectionViewPaginationAutoScroll
//
//  Created by P4D on 29/06/19.
//  Copyright © 2019 Rotomaker. All rights reserved.
//

import UIKit

protocol CollectionViewCellDelegate : AnyObject {
    func scrollToNextItem(index : IndexPath)
}

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: DownloadingImageView!
    var indexPath : IndexPath!
    weak var delegate : CollectionViewCellDelegate!
    
    var imageLink = ""{
        didSet{
            self.imageView.loadImageFrom(self.imageLink)
        }
    }
    override func awakeFromNib() {
     super.awakeFromNib()
        self.imageView.delegate = self
        self.imageView.image = nil
    }
    
    
}

extension CollectionViewCell : DownloadingImageViewDelegate
{
    func finishedDownloading() {
        self.delegate.scrollToNextItem(index: self.indexPath)
    }
}
