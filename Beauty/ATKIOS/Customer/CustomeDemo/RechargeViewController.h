//
//  RechargeViewController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-20.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@protocol sendDefaultToPrevous <NSObject>
-(void)setToDefaultOrNot:(NSMutableArray*)deFaultOrNot index:(NSInteger)indexPath;
@end
@interface RechargeViewController : ZXBaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    CGRect defaultRect;
    UIWindow *window;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property ( strong , nonatomic) NSString * cardNO;
@property (strong , nonatomic) NSString * cardName;
@property (assign, nonatomic)long  double cardBalance;
@property (strong, nonatomic)NSMutableArray *cardList;
@property (strong, nonatomic)NSMutableArray *cardDefaultOrNot;
@property (assign, nonatomic)NSInteger iNdexPath;
@property (assign, nonatomic)NSInteger cardType;
@property (weak, nonatomic)id <sendDefaultToPrevous>delegate;
@end


