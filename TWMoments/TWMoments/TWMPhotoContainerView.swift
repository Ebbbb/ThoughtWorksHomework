//
//  TWMPhotoContainerView.swift
//  TWMoments
//
//  Created by 蔡源 on 2020/11/17.
//  Copyright © 2020 蔡源. All rights reserved.
//

import UIKit

class TWMPhotoContainerView: UIView {
    
    var indexPath = IndexPath();
    var currentImages = Array<String>();
    var imageViews = { () -> [UIImageView] in
        var array = Array<UIImageView>();
        for i in 0..<9 {
            array.append(UIImageView());
        }
        return array;
    }();
    var viewWidth = CGFloat(0);
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        viewWidth = frame.size.width;
        let imageWH = (frame.size.width - 11) / 3
        for i in 0..<imageViews.count {
            let imageView = imageViews[i];
            self.addSubview(imageView);
            imageView.frame = CGRect.init(x: CGFloat(i%3) * (imageWH + 5), y: CGFloat(i/3) * (imageWH + 5), width: imageWH, height: imageWH);
            self.addSubview(imageView);
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUIWithImages(images: Array<String>) {
        currentImages = images;
        //设置前先清理图片
        for imageView in imageViews {
            imageView.image = nil;
        }

        if images.count == 0 {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(0);
            };
        } else if images.count == 1 {
            let cacheImage = TWMImageDownloader.shared.getCacheImage(url: images[0]);
            if cacheImage != nil {
                imageViews[0].image = cacheImage;
                let imageSize = self.singlePhotoSize(image: cacheImage!);
                self.imageViews[0].frame = CGRect.init(x: 0, y: 0, width: imageSize.width, height: imageSize.height);
                self.snp.updateConstraints { (make) in
                    make.height.equalTo(imageSize.height);
                };
            } else {
                imageViews[0].image = UIImage.init(named: "place_holder.png");
                imageViews[0].bounds = CGRect.init(x: 0, y: 0, width: imageViews[1].bounds.size.width, height: imageViews[1].bounds.size.height)
                self.snp.updateConstraints { (make) in
                    make.height.equalTo(self.imageViews[1].bounds.size.height);
                };
                TWMImageDownloader.shared.downloadImage(url: images[0]) { (image) in
                    //图片下载完成通知刷新
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableIndexPath"), object: self.indexPath);
                    }
                };
            }
        } else {
            let imageCount = images.count > imageViews.count ? 9 : images.count;
            imageViews[0].frame = CGRect.init(x: 0, y: 0, width: imageViews[1].bounds.size.width, height: imageViews[1].bounds.size.height)
            for i in 0..<imageCount {
                imageViews[i].twm_setImageWithURLString(url: images[i], placeholderImage: UIImage.init(named: "place_holder.png")!);
            }

            self.snp.updateConstraints { (make) in
                make.height.equalTo(CGFloat((imageCount-1)/3 + 1)*self.imageViews[1].bounds.size.height + CGFloat((imageCount-1)/3)*5);
            };
        }
    }
    
    func singlePhotoSize(image: UIImage) -> CGSize {
        var imageW:CGFloat;
        var imageH:CGFloat;
        if image.size.height > self.viewWidth / 2 {
            imageH = self.viewWidth/2;
            imageW = (imageH/image.size.width)*image.size.height;
        } else if image.size.width < self.viewWidth / 3 {
            imageH = self.viewWidth/3;
            imageW = (imageH/image.size.width)*image.size.height;
        } else {
            imageW = image.size.width;
            imageH = image.size.height;
        }
        return CGSize.init(width: imageH, height: imageW);
    }
    
    func heightForView() -> CGFloat {
        var height:CGFloat;
        if currentImages.count == 0 {
            height = CGFloat(0);
        } else if currentImages.count == 1 {
            let image = TWMImageDownloader.shared.getCacheImage(url: self.currentImages[0]);
            if image != nil {
                let imageSize = singlePhotoSize(image: image!);
                height = imageSize.height;
            }
            else {
                height = imageViews[1].bounds.size.height;
            }
        } else {
            let imageCount = currentImages.count > imageViews.count ? 9 : currentImages.count;
            height = CGFloat((imageCount-1)/3 + 1)*imageViews[1].bounds.size.height + CGFloat((imageCount-1)/3)*5;
        }
        return height;
    }
}
