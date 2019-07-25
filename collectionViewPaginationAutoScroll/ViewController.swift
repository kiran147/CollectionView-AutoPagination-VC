//
//  ViewController.swift
//  collectionViewPaginationAutoScroll
//
//  Created by P4D on 29/06/19.
//  Copyright © 2019 Rotomaker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arrImages = [String]()
    
    /**Used to indicate for timer to not be created.this is true when the user navigates to other page or the collection view is being scrolled back to first item from last*/
    private var stopTimerLoop = false
    
    /**Differentiates between first view laod and nagvigations back to view to resume scroll of the collection view.*/
    private var startScrollOnAppear : Bool = false
    
    /**Duration for which each premium offer should be displayed*/
    private let bannerDisplayTime : Double = 3
    
    /**Queue on which timer runs*/
    private let timerQueue : DispatchQueue = {
        let queue = DispatchQueue.init(label: "PremiumOffersTimerQueue", qos: .userInteractive, attributes: .concurrent)
        return queue
    }()
    
    private var dictScrollTimers = [IndexPath : Timer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.arrImages.append("https://homepages.cae.wisc.edu/~ece533/images/airplane.png")
        self.arrImages.append("https://homepages.cae.wisc.edu/~ece533/images/arctichare.png")
        self.arrImages.append("https://homepages.cae.wisc.edu/~ece533/images/baboon.png")
        self.arrImages.append("https://homepages.cae.wisc.edu/~ece533/images/boat.png")
        self.arrImages.append("https://homepages.cae.wisc.edu/~ece533/images/frymire.png")
        self.arrImages.append("https://homepages.cae.wisc.edu/~ece533/images/pool.png")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stopTimerLoop = true
        self.startScrollOnAppear = true
        
        //removes all the timers. as scrol should not happen when user navigates to other VC'S
        self.timerQueue.async {
            self.dictScrollTimers.forEach { $1.invalidate()}
            self.dictScrollTimers.removeAll()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //used for only when view is shown from nav stack. implemeted this because the item should not scroll before the image is fetched form the server and if not restricted will scroll item when teh view first launches when image may not be downloaded yet.
        if self.startScrollOnAppear
        {
            self.startScrollOnAppear = false
            self.stopTimerLoop = false
            
            self.startTimer(time: self.bannerDisplayTime, indexPath: self.collectionView.indexPathsForVisibleItems.first!)
        }
    }

}


extension ViewController : UICollectionViewDelegate , UICollectionViewDataSource , CollectionViewCellDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.imageLink = self.arrImages[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //Removes Timer when user scrolls between items
        self.timerQueue.async {
            
            if let timer = self.dictScrollTimers[indexPath]
            {
                timer.invalidate()
                self.dictScrollTimers.removeValue(forKey: indexPath)
            }
        }
    }
    
    func scrollToNextItem(index: IndexPath) {
        //when cllection view scrolls to first position form last tells to add timers as scroll back is complete
        if index.row == 0 , self.stopTimerLoop
        {
            self.stopTimerLoop = false
        }
        
        if !self.stopTimerLoop
        {
            self.startTimer(time: self.bannerDisplayTime, indexPath: index)
        }
    }
}


//MARK:- Timer
extension ViewController
{
    private func startTimer(time : Double , indexPath : IndexPath)
    {
        
        self.timerQueue.async {
            //if timer for the index dosent exist. a new timer instance is created
            if self.dictScrollTimers[indexPath] == nil
            {
                let timer = Timer.scheduledTimer(timeInterval: TimeInterval.init(time), target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
                self.dictScrollTimers.updateValue(timer, forKey: indexPath)
                let runLoop = RunLoop.current
                runLoop.add(timer, forMode: .default)
                runLoop.run()
            }
            
        }
        
    }
    
    @objc private func timerAction()
    {
        DispatchQueue.main.async {
            
            if let index = self.collectionView.indexPathsForVisibleItems.first, let timer = self.dictScrollTimers[index]
            {
                //Indicates to stop creating timers when scrolling back
                self.stopTimerLoop = index.row == (self.collectionView.numberOfItems(inSection: 0) - 1)
                
                //Removes timer when its exectued
                self.timerQueue.async {
                    timer.invalidate()
                    self.dictScrollTimers.removeValue(forKey: index)
                }
                
            }
            
            self.collectionView.scrollToNextItem()
        }
        
    }
    
}


extension UICollectionView
{
    func scrollToNextItem()
    {
        
        DispatchQueue.main.async {
            
            if let currentIndex = self.indexPathsForVisibleItems.first
            {
                self.scrollToItem(at: IndexPath.init(row: (self.numberOfItems(inSection: 0) - 1) == currentIndex.item ? 0 : currentIndex.row + 1, section: 0), at: .centeredHorizontally, animated: true)
            }
            else
            {
                print("No current index")
            }
        }
        
    }
}
