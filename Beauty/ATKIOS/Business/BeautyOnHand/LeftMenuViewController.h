//
//  LeftMenuViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-11-21.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface LeftMenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITableView *myListView;
@property (nonatomic, strong) NSMutableArray *menuItems;
@end
