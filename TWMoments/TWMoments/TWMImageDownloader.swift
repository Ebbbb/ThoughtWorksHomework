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
    var imageCallbacks = [String:Array<(_ image:UIImage) -> Void>]();
    var queue:OperationQueue = {
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 3
        return queue
    }();
    
    func getCacheImage(url:String) -> UIImage? {
        // 从内存缓存中取图片
        let cacheImage = cacheImages[url] as! UIImage?
        if cacheImage != nil {
            return cacheImage!;
        }
        
        // 从沙盒cache中获取图片
        let cachePath = url.cacheDir()
        
        let sandboxData = NSData.init(contentsOfFile: cachePath)
        
        if (sandboxData != nil) {
            let sandboxImage = UIImage.init(data: sandboxData! as Data)
            
            // 保存到内存缓存
            cacheImages[url] = sandboxImage
            return sandboxImage!;
        }
        
        return nil;
    }
    
    func downloadImage(url:String,completion:@escaping (_ image:UIImage)->Void) {
        //如果缓存已经存在直接返回
        let cacheImage = getCacheImage(url: url);
        if cacheImage != nil {
            completion(cacheImage!);
            return;
        }
        
        
        if imageCallbacks[url] == nil {
            imageCallbacks[url] = [];
        }
        
        imageCallbacks[url]?.append(completion);
        
        if imageCallbacks[url]!.count > 0 {
            //如果当前图片已经在下载了,保存回调等待下载完成。
            imageCallbacks[url]?.append(completion);
            
        }
        
        //缓存路径
        let cachePath = url.cacheDir()
        
        // 内存和沙盒中均没有图片，开始下载
        queue.addOperation {
            let downloadData = NSData.init(contentsOf: URL.init(string: url)!)
            let downloadImage = UIImage.init(data: downloadData! as Data)
            
            // 回主线程
            OperationQueue.main.addOperation {
                // 回调
                if self.imageCallbacks[url]!.count > 0 {
                    let callbackArr = self.imageCallbacks[url]!;
                    for callback in callbackArr {
                        callback(downloadImage!);
                    }
                    self.imageCallbacks[url]!.removeAll();
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
