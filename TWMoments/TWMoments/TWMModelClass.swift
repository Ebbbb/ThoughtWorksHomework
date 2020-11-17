//
//  TWMModelClass.swift
//  TWMoments
//
//  Created by 蔡源 on 2020/11/17.
//  Copyright © 2020 蔡源. All rights reserved.
//

import UIKit

public class TWMUserInfoModel: NSObject {
    var profileImage = String();
    var avatar = String();
    var nick = String();
    var username = String();
    
    
    public override init() {
        self.profileImage = "";
        self.avatar = "";
        self.nick = "";
        self.username = "";
    }
    
    public init(infoDict: Dictionary<String, Any>) {
        self.profileImage = infoDict["profile-image"] as? String ?? "";
        self.avatar = infoDict["avatar"] as? String ?? "";
        self.nick = infoDict["nick"] as? String ?? "";
        self.username = infoDict["username"] as? String ?? "";
    }
}

public class TWMTweetDetailModel: NSObject {
    var content = String();
    var images = Array<Any>();
    var sender = TWMUserInfoModel();
    var comments = Array<TWMTweetDetailModel>();
    
    public override init() {
        self.content = "";
        self.images = [];
        self.sender = TWMUserInfoModel.init();
        self.comments = [];
    }
    
    public init(tweetDetail: Dictionary<String, Any>) {
        self.content = tweetDetail["content"] as? String ?? "";
        self.images = [];
        let images_0 = tweetDetail["images"] as? Array<Dictionary<String, String>> ?? [];
        for imageDict in images_0 {
            let imageUrl = imageDict["url"] ?? "";
            self.images.append(imageUrl);
        }
        self.sender = TWMUserInfoModel.init(infoDict: tweetDetail["sender"] as? Dictionary<String, Any> ?? Dictionary())
        self.comments = [];
        let comments_0 = tweetDetail["comments"] as? Array<Dictionary<String, Any>> ?? [];
        for commentDetial in comments_0 {
            self.comments.append(TWMTweetDetailModel.init(tweetDetail: commentDetial));
        }
    }
}
