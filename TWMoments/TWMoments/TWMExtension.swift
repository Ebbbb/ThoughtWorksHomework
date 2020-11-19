//
//  TWMExtension.swift
//  TWMoments
//
//  Created by 蔡源 on 2020/11/17.
//  Copyright © 2020 蔡源. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

extension UIImageView {
    func twm_setImageWithURLString(url: String,placeholderImage:UIImage) {
        self.image = placeholderImage;
        TWMImageDownloader.shared.downloadImage(url: url) { (image) in
            self.image = image;
        };
    }
}

extension String {
    func cacheDir() -> String {
        var dir = NSHomeDirectory() + "/caches" ;
        let  fileManager = FileManager.default
        let result = fileManager.fileExists(atPath: dir)
        if !result {
            do{
                try fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            } catch{
                return "";
            }
        }
        dir = dir + "/" + self.sha512Hex();
        return dir;
    }
    
    func sha512Hex() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        if let data = self.data(using: String.Encoding.utf8) {
            CC_SHA512([UInt8](data), CC_LONG(data.count), &digest)
        }

        var digestHex = ""
        for index in 0..<Int(CC_SHA512_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }

        return digestHex
    }
}
