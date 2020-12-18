//
//  ChatSendMesgCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-12.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MLEmojiLabel.h"

@class MessageDoc;
@interface ChatSendMesgCell : UITableViewCell
@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UILabel *stateLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIImageView *contentImgView;
//@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) MLEmojiLabel *messageLabel;

@property (strong,nonatomic) NSString *message;
@property (strong,nonatomic) NSString *urlStr;

- (void)updateData:(MessageDoc *)message;
@end
