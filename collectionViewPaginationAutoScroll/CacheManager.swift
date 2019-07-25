

import Foundation
import UIKit

class CacheManager {
    static let shared = CacheManager()
    
    private init()
    {
        
    }
    
    let imageCache : NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 20
        return cache
    }()
}
