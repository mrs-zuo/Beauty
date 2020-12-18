
//
//  ReportDetailCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-21.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReportDetailDoc;
@interface ReportCustomerDetailCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *amountLabel;
@property (strong, nonatomic) UIView *ratioView;

- (void)updateData:(ReportDetailDoc *)doc andProductType:(NSInteger)productType;
@end
