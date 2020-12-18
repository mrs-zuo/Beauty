//
//  ECardRechargeViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-10-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCustomersViewController.h"

@interface ECardRechargeViewController : BaseViewController<UITextFieldDelegate,UITextViewDelegate, UITableViewDataSource,SelectCustomersViewControllerDelegate, UIScrollViewDelegate, UITableViewDelegate>
@property (assign, nonatomic) double eCardBalance;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,assign)NSString * cardId;
@property (nonatomic,assign)NSString * intergralNO;
@property (nonatomic,assign)NSString *cashCouponNO;
@end
