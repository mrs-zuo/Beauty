//
//  MenuViewController.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-2.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "MenuDoc.h"
#import "AppDelegate.h"
#import "AccountDoc.h"
//四舍六入
// - (NSString *)notRounding:(double)price afterPoint:(NSInteger)position { NSLog(@"price1 =%f",price);
//     NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
//     NSDecimalNumber *ouncesDecimal;
//     NSDecimalNumber *roundedOunces;
//     ouncesDecimal = [[NSDecimalNumber alloc] initWithDouble:price]; NSLog(@"NSDecimalNumber =%@",ouncesDecimal);
//     roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
//     return [NSString stringWithFormat:@"%@",roundedOunces];
// }
@interface MenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myListView;
@property (nonatomic, strong) NSMutableArray *menu_Top;
@property (nonatomic, strong) NSMutableArray *menu_Info;
@property (nonatomic, strong) NSMutableArray *menu_Business;
@property (nonatomic, strong) NSMutableArray *menu_Buy;
@property (nonatomic, strong) NSMutableArray *menu_Set;

@end
