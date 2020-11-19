//
//  ViewController.swift
//  TWMoments
//
//  Created by 蔡源 on 2020/11/17.
//  Copyright © 2020 蔡源. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TWMRefreshAndLoadViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userInfo = TWMUserInfoModel();
    var tweetList = Array<TWMTweetDetailModel>(); //所有列表数据
    var tweetArr = Array<TWMTweetDetailModel>(); //模拟分页数据
    
    var tableHeader = TWMTableViewHeader.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 260));
    var tableCell = TWMTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell");
    var refreshView:TWMRefreshAndLoadView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableHeaderView = tableHeader;
        tableView.tableFooterView = UIView();
        tableView.register(TWMTableViewCell.self, forCellReuseIdentifier: "cell");
        tableView.estimatedRowHeight = 0;
        refreshView = TWMRefreshAndLoadView.init(frame: CGRect.zero, inTableView: tableView)
        refreshView.delegate = self;
        self.requetData();
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableIndexPath), name: NSNotification.Name(rawValue: "reloadTableIndexPath"), object: nil);
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    @objc func reloadTableIndexPath(notification: Notification) {
        let indexPath = notification.object as! IndexPath;
        self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none);
    }
    
    func requetData() {
        //请求用户信息
        self.requestWithUrlString(url: "https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith") { (data) in
            let dataDict = data as? Dictionary<String, Any> ?? Dictionary();
            self.userInfo = TWMUserInfoModel.init(infoDict: dataDict);
            OperationQueue.main.addOperation {
                self.tableHeader.setUIWithModel(model: self.userInfo);
            }
            
        };
        //请求消息列表
        self.requestWithUrlString(url: "https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith/tweets") { (data) in
            self.tweetList = [];
            let dataArr = data as? Array<Dictionary<String, Any>> ?? [];
            for tweetDetailDict in dataArr {
                let tweetDetailModel = TWMTweetDetailModel.init(tweetDetail: tweetDetailDict);
                if (tweetDetailModel.content.count > 0 || tweetDetailModel.images.count > 0) {
                    self.tweetList.append(tweetDetailModel);
                }
            }
            if self.tweetList.count > 5 {
                self.tweetArr.append(contentsOf: self.tweetList.prefix(upTo: 5));
            } else {
                self.tweetArr.append(contentsOf: self.tweetList);
            }
            OperationQueue.main.addOperation {
                self.tableView.reloadData();
            }
        }
    }
    
    func requestWithUrlString(url: String, completion:@escaping (_ data: Any)->Void){
        let url = URL(string: url);
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let configuration:URLSessionConfiguration = URLSessionConfiguration.default
        let session:URLSession = URLSession(configuration: configuration)
        let task:URLSessionDataTask = session.dataTask(with: request) { (data, response, error)->Void in
                if error == nil{
                    do {
                       let responseData:Any = try JSONSerialization.jsonObject(with: data!, options:   JSONSerialization.ReadingOptions.allowFragments)
                        print("response:\(String(describing: responseData))")
                        completion(responseData);
                    } catch {
                        print("serialization error")
                    }
                }else{
                    print("error:\(String(describing: error))")
                }
        }
        task.resume()
        
    }
    
    //Mark: TWMRefreshAndLoadViewDelegate
    func refreshViewDidRefresh(_ refreshView: TWMRefreshAndLoadView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tweetArr.removeAll();
            if self.tweetList.count > 5 {
                self.tweetArr.append(contentsOf: self.tweetList.prefix(upTo: 5));
            } else {
                self.tweetArr.append(contentsOf: self.tweetList);
            }
            self.tableView.reloadData();
            self.refreshView.endRefreshing()
        };
    }

    func refreshViewDidLoad(_ loadView: TWMRefreshAndLoadView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.tweetList.count > self.tweetArr.count {
                var indexPathArray = Array<IndexPath>();
                for i in self.tweetArr.count..<self.tweetArr.count + 5 {
                    if i > self.tweetList.count {
                        break;
                    }
                    self.tweetArr.append(self.tweetList[i]);
                    indexPathArray.append(IndexPath.init(row: i, section: 0));
                }
    
                self.tableView.insertRows(at: indexPathArray, with: UITableView.RowAnimation.none);
            }
            self.refreshView.endLoading()
        };
    }
    //Mark: tableview delegate and datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TWMTableViewCell;
        cell.setUIWithModel(model: tweetArr[indexPath.row]);
        cell.photosView.indexPath = indexPath;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tableCell.setDataWithModel(model: tweetArr[indexPath.row]);
        return self.tableCell.heightForCell();
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.refreshView.scrollViewDidScroll(scrollView);
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset);
    }
}

