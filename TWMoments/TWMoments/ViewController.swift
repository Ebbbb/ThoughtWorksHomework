//
//  ViewController.swift
//  TWMoments
//
//  Created by 蔡源 on 2020/11/17.
//  Copyright © 2020 蔡源. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userInfo = TWMUserInfoModel();
    var tweetList = Array<TWMTweetDetailModel>();
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.dataSource = self;
        self.requetData();
        // Do any additional setup after loading the view.
    }
    
    func requetData() {
        //请求用户信息
        self.requestWithUrlString(url: "https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith") { (data) in
            let dataDict = data as? Dictionary<String, Any> ?? Dictionary();
            self.userInfo = TWMUserInfoModel.init(infoDict: dataDict);
        };
        //请求消息列表
        self.requestWithUrlString(url: "https://thoughtworks-mobile-2018.herokuapp.com/user/jsmith/tweets") { (data) in
            self.tweetList = [];
            let dataArr = data as? Array<Dictionary<String, Any>> ?? [];
            for tweetDetailDict in dataArr {
                let tweetDetailModel = TWMTweetDetailModel.init(tweetDetail: tweetDetailDict);
                if (tweetDetailModel.content.count > 0) {
                    self.tweetList.append(tweetDetailModel);
                }
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

    //Mark: tableview delegate and datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell.init();
    }
}

