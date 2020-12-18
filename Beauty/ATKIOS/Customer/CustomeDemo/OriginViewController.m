//
//  OriginViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/1.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "OriginViewController.h"

@interface OriginViewController ()

@end

@implementation OriginViewController
-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
//    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
//    NSLayoutConstraint *tableViewConstraintX = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
//    NSLayoutConstraint *tableViewConstraintY = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
//    NSLayoutConstraint *tableViewConstraintWidth = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
//    NSLayoutConstraint *tableViewConstraintHeight = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
//    
//    [self.view addConstraints:@[tableViewConstraintX, tableViewConstraintY, tableViewConstraintWidth, tableViewConstraintHeight]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateData
{
    NSLog(@"%s", __FUNCTION__);
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
//        _tableView.bounds =CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 64);
        _tableView.frame =CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - (kNavigationBar_Height + 40  + 5) + 20);
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.backgroundView = nil;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.autoresizingMask = UIViewAutoresizingNone;
        
//        _tableView.sectionHeaderHeight = 0.0;
//        _tableView.sectionFooterHeight = 5.0;
        if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
        _tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    return _tableView;
}
@end
