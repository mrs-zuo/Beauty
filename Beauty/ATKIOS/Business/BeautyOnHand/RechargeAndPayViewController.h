//
//  RechargeAndPayViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class PayAndRechargeDoc;
@interface RechargeAndPayViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign ,nonatomic) NSString * userCardId;
@property (assign ,nonatomic) int accountType;

@end
