//
//  BusinessInfoCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/6.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessInfoCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * detailLabel;
@end
