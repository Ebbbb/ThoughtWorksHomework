//
//  TWMCommentContainerView.swift
//  TWMoments
//
//  Created by 蔡源 on 2020/11/18.
//  Copyright © 2020 蔡源. All rights reserved.
//

import UIKit

class TWMCommentContainerView: UIView {

    var currentComments = Array<TWMTweetDetailModel>();
    var commentLabels = Array<UILabel>();
    var viewWidth:CGFloat;
    
    
    override init(frame: CGRect) {
        viewWidth = frame.size.width;
        super.init(frame: frame);
        self.backgroundColor = UIColor.init(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1);
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = true;
    }
    
    func setUIWithComments(comments: Array<TWMTweetDetailModel>) {
        for label in commentLabels {
            label.removeFromSuperview();
        }
        commentLabels.removeAll();
        for i in 0..<comments.count {
            let model = comments[i];
            let label = UILabel();
            label.numberOfLines = 0;
            label.font = UIFont.systemFont(ofSize: 14);
            let attributedString = NSMutableAttributedString.init(string: model.sender.nick + " : " + model.content) ;
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 112/255.0, green: 129/255.0, blue: 154/255.0, alpha: 1), range: NSRange.init(location: 0, length: model.sender.nick.count));
            label.attributedText = attributedString;
            self.addSubview(label);
            commentLabels.append(label);
            if i == 0 {
                label.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(5);
                    make.top.equalToSuperview().offset(5);
                    make.right.equalToSuperview().offset(5);
                }
            } else {
                let isLastOne = i == comments.count - 1;
                label.snp.makeConstraints { (make) in
                    make.left.equalTo(commentLabels[i-1].snp.left);
                    make.top.equalTo(commentLabels[i-1].snp.bottom).offset(-5);
                    make.right.equalTo(commentLabels[i-1].snp.right);
                    if isLastOne {
                        make.bottom.equalToSuperview().offset(0);
                    }
                }
            }
        }
    }
    
    func cellForView() -> CGFloat {
        var height = CGFloat(0);
        for model in currentComments {
            let text = model.sender.nick + "：" + model.content;
            height = height + heightForLabel(text: text, font: UIFont.systemFont(ofSize: 14), width: viewWidth - 10);
        }
        height = height + CGFloat(currentComments.count * 5);
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
    
}
