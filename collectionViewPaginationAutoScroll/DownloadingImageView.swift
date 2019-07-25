
import Foundation
import UIKit

protocol DownloadingImageViewDelegate : AnyObject {
    func finishedDownloading()
}

class DownloadingImageView : UIImageView {
    
    weak var delegate : DownloadingImageViewDelegate?
    var imageUrl : String?
    private lazy var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView.init()
    private var downloadTask : URLSessionTask?
    
    func loadImageFrom(_ urlString : String)
    {
        self.imageUrl = urlString
        self.image = nil
        
        self.addActivityIndicator()
        
        if let image = CacheManager.shared.imageCache.object(forKey: NSString.init(string: urlString))
        {
            self.image = image
            self.removeActivityIndicator()
            self.delegate?.finishedDownloading()
            return
        }
        
        if let url = URL.init(string: urlString.replacingOccurrences(of: " ", with: ""))
        {
            
           self.downloadTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error
                {
                    print(error)
                    DispatchQueue.main.async {
                        self.removeActivityIndicator()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    if let data = data,let cachedImage = UIImage.init(data: data)
                    {
                        if self.imageUrl == urlString
                        {
                            self.image = cachedImage
                            self.delegate?.finishedDownloading()
                        }
                        CacheManager.shared.imageCache.setObject(cachedImage, forKey: NSString.init(string: urlString))
                        self.removeActivityIndicator()
                    }
                    
                }
                
                
                }
            self.downloadTask?.resume()
        }
        else
        {
            print("invalid url string custom imageview")
        }
        
    }
    
    private func addActivityIndicator()
    {
        let size : CGFloat = self.frame.height * 0.55
        self.activityIndicator.frame = CGRect.init(x: self.frame.width/2 - size/2, y: self.frame.height/2 - size/2, width: size, height: size)
        self.activityIndicator.autoresizingMask = [.flexibleTopMargin,.flexibleBottomMargin,.flexibleRightMargin,.flexibleLeftMargin,.flexibleWidth,.flexibleHeight]
        self.activityIndicator.center = self.center
        self.activityIndicator.color = .gray
        self.activityIndicator.hidesWhenStopped = true
        self.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    private func removeActivityIndicator()
    {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    func cancelDownload()
    {
        self.downloadTask?.cancel()
    }
    
    deinit {
        self.downloadTask?.cancel()
        self.image = nil
        self.imageUrl = nil
        print("removed Downloading image view")
    }
    
}
