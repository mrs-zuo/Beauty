//
//  ZXServiceEffectViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/1/25.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "ZXBaseViewController.h"
#import "PictureDisplayView.h"

@interface ZXServiceEffectViewController : ZXBaseViewController <UITableViewDataSource, UITableViewDelegate, PictureDisplayViewDelegate>

@property (strong, nonatomic)  UITableView *tableView;
@property (assign, nonatomic) NSInteger treat_ID;
@property (assign, nonatomic) long long GroupNo;
@property (assign ,nonatomic) NSInteger OrderID;
@property (assign ,nonatomic) NSInteger treatMentOrGroup;//1 TG  0 teatment

@end

