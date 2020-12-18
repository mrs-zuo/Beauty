//
//  EffectDisplayViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-8.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureDisplayView.h"
#import "ZXBaseViewController.h"

@interface EffectDisplayViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate, PictureDisplayViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger treat_ID;
@property (assign ,nonatomic) NSInteger treatMentOrGroup;//1 TG  0 teatment
@property (assign, nonatomic) long long GroupNo;
@property (assign ,nonatomic) NSInteger OrderID;

@end
