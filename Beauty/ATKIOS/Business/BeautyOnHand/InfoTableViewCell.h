//
//  InfoTableViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OperatingOrder;

@interface InfoTableViewCell : UITableViewCell

@property (strong, nonatomic)  UIImageView *headImage;
@property (strong, nonatomic)  UILabel *customerName;
@property (strong, nonatomic)  UILabel *productName;
@property (strong, nonatomic)  UILabel *dateLabel;
@property (strong, nonatomic)  UILabel *statusLabel;
@property (strong, nonatomic)  UILabel *personLabel;
@property (nonatomic, strong) OperatingOrder *operInfo;
@end
