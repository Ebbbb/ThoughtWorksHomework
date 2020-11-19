//
//  TWMTableViewHeader.swift
//  TWMoments
//
//  Created by 蔡源 on 2020/11/17.
//  Copyright © 2020 蔡源. All rights reserved.
//

import UIKit

class TWMTableViewHeader: UIView {

    var profileImageView = UIImageView.init();
    var avatarImageView = UIImageView.init();
    var nickLabel = UILabel.init();
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.addSubview(profileImageView);
        profileImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0);
            make.top.equalToSuperview().offset(-50);
            make.right.equalToSuperview().offset(0);
            make.bottom.equalToSuperview().offset(-40);
        };
        
        avatarImageView.layer.cornerRadius = 5;
        avatarImageView.layer.masksToBounds = true;
        self.addSubview(avatarImageView);
        avatarImageView.snp.makeConstraints { (make) in
            make.width.equalTo(70);
            make.height.equalTo(70);
            make.right.equalToSuperview().offset(-20);
            make.bottom.equalToSuperview().offset(-15);
        };
        
        nickLabel.textColor = UIColor.white;
        nickLabel.textAlignment = NSTextAlignment.right;
        nickLabel.font = UIFont.boldSystemFont(ofSize: 15);
        self.addSubview(nickLabel)
        nickLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20);
            make.right.equalTo(avatarImageView.snp.left).offset(-20);
            make.bottom.equalTo(avatarImageView.snp.bottom).offset(-35);
        };
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUIWithModel(model: TWMUserInfoModel) {
        profileImageView.twm_setImageWithURLString(url: model.profileImage, placeholderImage: UIImage.init(named: "place_holder.png")!);
        
        avatarImageView.twm_setImageWithURLString(url: model.avatar, placeholderImage: UIImage.init(named: "place_holder.png")!);
        
        nickLabel.text = model.nick;
    }
}
