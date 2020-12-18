//
//  ServiceViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/8/2.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ServiceCellLayout) {
    ServiceCellLayoutNormol,
    ServiceCellLayoutSecond
};
@interface ServiceViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *desigImage;
@property (nonatomic, strong) UIImageView *quanImage;
@property (nonatomic, strong) UIImageView *tailImage;
@property (nonatomic, assign) ServiceCellLayout imageLayout;
@end
