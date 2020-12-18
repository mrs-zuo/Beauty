//
//  AccountSelectListCell.h
//  CustomeDemo
//
//  Created by macmini on 13-7-18.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLEmojiLabel.h"
@protocol AccountListCellDelete <NSObject>
- (void) chickSelectBtnWithCell:(UITableViewCell *)cell;
@end

@class MessageDoc;
@interface AccountSelectListCell : UITableViewCell
@property (strong, nonatomic) UIImageView *headImageView;
@property (strong,nonatomic) UILabel *nameLabel;
@property (strong,nonatomic) UILabel *dateLabel;
@property (strong,nonatomic) MLEmojiLabel *mesgLabel;
@property (strong,nonatomic) UILabel *newsCountLabel;
@property (assign,nonatomic) id<AccountListCellDelete> delegate;

-(void) updateData:(MessageDoc *)message;
@end
