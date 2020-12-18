//
//  CommentViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-14.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger treatmentID;

@property (assign, nonatomic) BOOL permission_Write;

@property (assign ,nonatomic) NSInteger treatMentOrGroup;//0 group  1 teatment
@property (assign ,nonatomic) double GroupNo;
@property (assign ,nonatomic) NSInteger OrderID;

@end
