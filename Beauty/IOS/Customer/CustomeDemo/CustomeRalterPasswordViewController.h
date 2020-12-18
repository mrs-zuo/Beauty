//
//  CustomeRalterPasswordViewController.h
//  CustomeDemo
//
//  Created by macmini on 13-9-9.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ZXBaseViewController.h"

@interface CustomeRalterPasswordViewController : ZXBaseViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
