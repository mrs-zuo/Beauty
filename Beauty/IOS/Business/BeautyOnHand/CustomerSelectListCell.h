//
//  CustomerListCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-12.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLEmojiLabel.h"

//@protocol CustomerListCellDelete <NSObject>
//- (void)chickSelectBtnWithCell:(UITableViewCell *)cell;
//@end

@class MessageDoc;
@interface CustomerSelectListCell : UITableViewCell
@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
//@property (strong, nonatomic) UILabel *mesgLabel;
@property (strong, nonatomic) MLEmojiLabel *mesgLabel;
@property (strong, nonatomic) UILabel *newsCountLabel;
//@property (assign, nonatomic) id<CustomerListCellDelete> delegate;

- (void)updateData:(MessageDoc *)message;
@end
