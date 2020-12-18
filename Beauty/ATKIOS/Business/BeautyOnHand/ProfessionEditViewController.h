//
//  ProfessionEditViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-11-26.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomerDoc;
@interface ProfessionEditViewController : BaseViewController<UIGestureRecognizerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CustomerDoc *customer;
@end
