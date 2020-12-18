//
//  EffectDisplayViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-8.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureDisplayView.h"

@interface EffectDisplayViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, PictureDisplayViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger treat_ID;
@property (assign, nonatomic) NSInteger customerID;

@property (assign ,nonatomic) NSInteger treatMentOrGroup;//0 group  1 teatment
@property (assign ,nonatomic) double  GroupNo;
@property (assign ,nonatomic) NSInteger OrderID;

@property (assign, nonatomic) BOOL permission_Write;
@end
