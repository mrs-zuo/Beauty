//
//  CustomerBasicViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CustomerBasicViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    UIWindow *window;
    CGRect defaultRect;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end
