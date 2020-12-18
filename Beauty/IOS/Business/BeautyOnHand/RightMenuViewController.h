//
//  MenuViewController.h
//  BeautyPromise02
//
//  Created by ZhongHe on 13-5-22.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "MenuDoc.h"

@interface RightMenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *myListView;
@property (nonatomic, strong) NSMutableArray *menuItems;

@end
