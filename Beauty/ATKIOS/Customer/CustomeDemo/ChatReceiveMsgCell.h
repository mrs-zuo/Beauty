//
//  ChatReceiveMsgCell.h
//  CustomeDemo
//
//  Created by macmini on 13-7-18.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MLEmojiLabel.h"
@class MessageDoc;
@interface ChatReceiveMsgCell : UITableViewCell
@property (strong,nonatomic) UIImageView *headImageView;
@property (strong,nonatomic) UILabel *dateLabel;
@property (strong,nonatomic) UIImageView *contentImgView;
@property (strong,nonatomic)  MLEmojiLabel *messageLabel;
@property (nonatomic) UIImageView *errorImgView;
@property (nonatomic) UIActivityIndicatorView *activityView;
@property (strong,nonatomic) NSString *message;
@property (strong,nonatomic) NSString *urlStr;
-(void) updateData:(MessageDoc *) message headImg:(NSString *)headImg;
@end
