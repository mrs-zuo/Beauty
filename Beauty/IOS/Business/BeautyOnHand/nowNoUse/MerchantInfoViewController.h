//
//  ViewController.h
//  merNew
//
//  Created by MAC_Lion on 13-7-23.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MerchantDoc;
@interface MerchantInfoViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) MerchantDoc *merchantDoc;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
