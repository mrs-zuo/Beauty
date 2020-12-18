//
//  RecommendTableViewCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/27.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppointmentStoreRecommendModel;
@interface RecommendTableViewCell : UITableViewCell

@property (strong, nonatomic) UIButton *detailButton;
@property (strong, nonatomic) UIButton *appointmentButton;
@property (strong, nonatomic) AppointmentStoreRecommendModel *AppointmentStoreRecommend;



@end
