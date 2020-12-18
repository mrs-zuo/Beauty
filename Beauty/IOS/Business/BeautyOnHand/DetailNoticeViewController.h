//
//  DetailNoticeViewController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-7.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailNoticeViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong,nonatomic) NSString *recieveNoticeTitle;
@property (strong,nonatomic) NSString *recieveNoticeTime;
@property (strong,nonatomic) NSString *recievenoticeContent;
@end
