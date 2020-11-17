//
//  TWMImageDownloader.swift
//  TWMoments
//
//  Created by 蔡源 on 2020/11/17.
//  Copyright © 2020 蔡源. All rights reserved.
//

import UIKit

class TWMImageDownloader: NSObject {
    static let shared = TWMImageDownloader();
    var cacheImages:Dictionary<String, Any> = [:];
    var imageCallbacks = [String:(image:UIImage) -> Void]();
    var queue:OperationQueue = {
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 3
        return queue
    }();
    
    func downloadImage(url:String,completion:@escaping (_ image:UIImage)->Void) {
        
        imageCallbacks[url] = completion

        // 从内存缓存中取图片
        let cacheImage = cacheImages[url] as! UIImage?
        if cacheImage != nil {
            if imageCallbacks[url] != nil {
                imageCallbacks[url]!(cacheImage!);
            }
            return
        }
        
        // 从沙盒cache中获取图片
        let cachePath = url.cacheDir()
        print(cachePath)
        
        let sanboxData = NSData.init(contentsOfFile: cachePath)
        
        if (sanboxData != nil) {
            let sandboxImage = UIImage.init(data: sanboxData! as Data)
            
            // 保存到内存缓存
            cacheImages[url] = sandboxImage
            // 回调
            if imageCallbacks[url] != nil {
                imageCallbacks[url]!(sandboxImage!);
            }
            return;
        }
        
        // 内存和沙盒中均没有图片，开始下载
        queue.addOperation {
            let downloadData = NSData.init(contentsOf: URL.init(string: url)!)
            let downloadImage = UIImage.init(data: downloadData! as Data)
            
            // 回主线程
            OperationQueue.main.addOperation {
                // 回调
                if self.imageCallbacks[url] != nil {
                    self.imageCallbacks[url]!(downloadImage!);
                }
                // 保存到内存
                self.cacheImages[url] = downloadImage
                // 保存到沙盒
                if cachePath.count > 0 {
                    downloadData?.write(to: URL.init(fileURLWithPath: cachePath), atomically: true)
                }
            }
        }
    }
}
