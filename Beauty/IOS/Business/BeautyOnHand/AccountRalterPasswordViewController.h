//
//  AccountRalterPasswordViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-12-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountRalterPasswordViewController : BaseViewController<UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
