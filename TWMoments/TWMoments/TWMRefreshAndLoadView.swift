//
//  DZRefreshView.swift
//  AnimationDemo7
//
//  Created by duzhe on 15/9/27.
//  Copyright © 2015年 duzhe. All rights reserved.
//

import UIKit
import CoreServices
protocol TWMRefreshAndLoadViewDelegate {
    func refreshViewDidRefresh(_ refreshView: TWMRefreshAndLoadView)
    func refreshViewDidLoad(_ loadView: TWMRefreshAndLoadView)
}

class TWMRefreshAndLoadView: UIView {

    var tableView: UITableView?
    var delegate: TWMRefreshAndLoadViewDelegate?
    var isRefreshing = false
    var isLoading = false
    var refreshProgress: CGFloat = 0.0
    var loadProgress: CGFloat = 0.0
    
    var loadingImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100));
    
    init(frame:CGRect , inTableView:UITableView){
        super.init(frame: frame);
        self.tableView = inTableView
        self.setGifImages();
    }
    
    func setGifImages() {
        let path = Bundle.main.path(forResource: "loading", ofType: "gif")
        let data = NSData(contentsOfFile: path!)

        let options: NSDictionary = [kCGImageSourceShouldCache as String: NSNumber(value: true), kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF]
        
        guard let imageSource = CGImageSourceCreateWithData(data!, options) else {
            return;
        }
        
        let frameCount = CGImageSourceGetCount(imageSource)
        var images = [UIImage]()

        var gifDuration = 0.0

        for i in 0 ..< frameCount {
            // 获取对应帧的 CGImage
            guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, options) else {
                return;
            }
            if frameCount == 1 {
                // 单帧
                gifDuration = Double.infinity
            } else{
                // gif 动画
                // 获取到 gif每帧时间间隔
                guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) , let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
                    let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else
                {
                    return;
                }
                gifDuration += frameDuration.doubleValue
                // 获取帧的img
                let  image = UIImage(cgImage: imageRef , scale: UIScreen.main.scale , orientation: UIImage.Orientation.up)
                // 添加到数组
                images.append(image)
            }
        }
        loadingImageView.contentMode = .scaleToFill
        loadingImageView.animationImages = images;
        loadingImageView.animationDuration = gifDuration
        loadingImageView.animationRepeatCount = 0
        loadingImageView.startAnimating();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func beginRefreshing(){
        isRefreshing = true
        loadingImageView.center = CGPoint.init(x: 50, y: 60);
        self.tableView?.addSubview(loadingImageView);
    }
    
    func endRefreshing() {
        isRefreshing = false
        loadingImageView.removeFromSuperview();
    }
    
    func beginLoading() {
        isLoading = true;
        UIView.animate(withDuration: 0.3, animations: {
            var newInsets = self.tableView!.contentInset
            newInsets.bottom += 100
            self.tableView!.contentInset = newInsets
            self.loadingImageView.center = CGPoint.init(x: UIScreen.main.bounds.size.width / 2, y: (self.tableView?.contentSize.height ?? 1000) + 50);
            self.tableView?.addSubview(self.loadingImageView);
        })
    }
    
    func endLoading() {
        isLoading = false;
        self.loadingImageView.removeFromSuperview();
        UIView.animate(withDuration: 0.3, delay:0.0, options: .curveEaseOut ,animations: {
            var newInsets = self.tableView!.contentInset
            newInsets.bottom -= 100
            self.tableView!.contentInset = newInsets
            }, completion: {_ in
        })
    }
    
    //滚动中回调
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let refreshOffSetY = CGFloat(max(-(scrollView.contentOffset.y + scrollView.contentInset.top),0))
        self.refreshProgress = min(refreshOffSetY / 100, 1.0)
        let loadOffSetY = CGFloat(max((scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height),0))
        self.loadProgress = min(loadOffSetY / 100, 1.0)
    }
    
    //滚动停止回调
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !isRefreshing && self.refreshProgress >= 1.0 {
            delegate?.refreshViewDidRefresh(self) //执行刷新操作
            beginRefreshing()
        }
        if !isLoading && self.loadProgress >= 1.0 {
            delegate?.refreshViewDidLoad(self) //执行加载操作
            beginLoading()
        }
    }
}
