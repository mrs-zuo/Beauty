//
//  DetailNoticeViewController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-7.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@interface DetailNoticeViewController : ZXBaseViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) NSString *recieveNoticeTitle;
@property (strong,nonatomic) NSString *recieveNoticeTime;
@property (strong,nonatomic) NSString *recievenoticeContent;
@end
