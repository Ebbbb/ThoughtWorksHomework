//
//  TWMTableViewCell.swift
//  TWMoments
//
//  Created by 蔡源 on 2020/11/17.
//  Copyright © 2020 蔡源. All rights reserved.
//

import UIKit

class TWMTableViewCell: UITableViewCell {
    
    var currentModel = TWMTweetDetailModel();
    
    var avatarImageView = UIImageView();
    var nickLabel = UILabel();
    var contentLabel = UILabel();
    var photosView = TWMPhotoContainerView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 80, height: 0));
    var commentView = TWMCommentContainerView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 80, height: 0));
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.addSubview(avatarImageView);
        avatarImageView.snp.makeConstraints { (make) in
            make.width.equalTo(40);
            make.height.equalTo(40);
            make.left.equalToSuperview().offset(10);
            make.top.equalToSuperview().offset(10);
        };
        
        self.addSubview(nickLabel);
        nickLabel.textColor = UIColor.init(red: 112/255.0, green: 129/255.0, blue: 154/255.0, alpha: 1);
        nickLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp.right).offset(10);
            make.top.equalToSuperview().offset(10);
            make.right.equalToSuperview().offset(-20);
            make.height.equalTo(20);
        };
        
        self.addSubview(contentLabel);
        contentLabel.font = UIFont.systemFont(ofSize: 16);
        contentLabel.numberOfLines = 0;
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nickLabel.snp.left);
            make.top.equalTo(nickLabel.snp.bottom).offset(5);
            make.right.equalToSuperview().offset(-20);
        }
        
        self.addSubview(photosView);
        photosView.snp.makeConstraints { (make) in
            make.left.equalTo(nickLabel.snp.left);
            make.top.equalTo(contentLabel.snp.bottom).offset(10);
            make.right.equalToSuperview().offset(-20);
            make.height.equalTo(100);
        };
        
        self.addSubview(commentView);
        commentView.snp.makeConstraints { (make) in
            make.left.equalTo(nickLabel.snp.left);
            make.top.equalTo(photosView.snp.bottom).offset(10);
            make.right.equalToSuperview().offset(-20);
            make.bottom.equalToSuperview().offset(-5);
        }
        
    }
    
    func setUIWithModel(model: TWMTweetDetailModel) {
        currentModel = model;
        avatarImageView.twm_setImageWithURLString(url: model.sender.avatar, placeholderImage: UIImage.init(named: "place_holder.png")!);
        nickLabel.text = model.sender.nick;
        contentLabel.text = model.content;
        photosView.setUIWithImages(images: model.images);
        commentView.setUIWithComments(comments: model.comments);
    }
    
    func setDataWithModel(model:TWMTweetDetailModel) {
        currentModel = model;
        photosView.currentImages = model.images;
        commentView.currentComments = model.comments;
    }
    
    func heightForCell() -> CGFloat {
        var height = CGFloat(0);
        height = height + 35;
        height = height + heightForLabel(text: currentModel.content, font: contentLabel.font, width: UIScreen.main.bounds.size.width - 80);
        height = height + 15;
        if currentModel.images.count > 0 {
            height = height + photosView.heightForView();
            height = height + 10;
        }
        if currentModel.comments.count > 0 {
            height = height + commentView.cellForView();
            height = height + 10;
        }
        return height;
    }
    
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
