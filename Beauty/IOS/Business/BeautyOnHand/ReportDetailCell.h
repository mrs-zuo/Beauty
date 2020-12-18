//
//  ReportCustomerDetailCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15-3-25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReportDetailDoc;

@interface ReportDetailCell : UITableViewCell
@property (strong, nonatomic) UILabel *headerTitle;
@property (strong, nonatomic) UILabel *tailTitle;
@property (strong, nonatomic) UILabel *headerValue;
@property (strong, nonatomic) UILabel *tailValue;
@property (strong, nonatomic) UIView *ratioView;

- (void)updateData:(ReportDetailDoc *)doc andProductType:(NSInteger)productType andItemType:(NSInteger)itemType;
@end