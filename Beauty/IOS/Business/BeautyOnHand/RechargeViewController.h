//
//  RechargeViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-14.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface RechargeViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, copy)NSString * userCardNo;
@property(nonatomic,assign)int  type;  //1.储值卡 2.积分 3.现金券
@property(nonatomic)BOOL defaultCard;
@property (nonatomic,assign)NSString * intergralNO;
@property (nonatomic,assign)NSString *cashCouponNO;
@end
