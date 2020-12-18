//
//  OriginViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "OriginViewController.h"
#import "DFUITableView.h"
#import "ColorImage.h"
#import "PermissionDoc.h"
@interface OriginViewController ()
@property (nonatomic, weak) NSLayoutConstraint *firstButtonConstraintX1;
@property (nonatomic, weak) NSLayoutConstraint *firstButtonConstraintX2;

@property (nonatomic, weak) NSLayoutConstraint *firstButtonConstraintWidth;

@end

@implementation OriginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    DFUITableView *dfView = [[DFUITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    dfView.backgroundColor = [UIColor whiteColor];
    
#pragma mark 权限 No.6 管理我的订单 控制服务信息页开单 结单 等按钮
    if ([[PermissionDoc sharePermission] rule_MyOrder_Write]) {
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button1 setBackgroundImage:[ColorImage blueBackgroudImage] forState:UIControlStateNormal];
        [button2 setBackgroundImage:[ColorImage blueBackgroudImage] forState:UIControlStateNormal];
        
        button1.layer.masksToBounds = YES;
        button1.layer.cornerRadius = 6.0;
        button2.layer.masksToBounds = YES;
        button2.layer.cornerRadius = 6.0;
        
        [self.view addSubview:self.tableView = dfView];
        [self.view addSubview:self.firstButton = button1];
        [self.view addSubview:self.secondButton = button2];
        
        
        
        
        /*   设置约束如下
         |----tableView----|
         |----tableView----|
         |----tableView----|
         |----tableView----|
         |--butto1-butto2--|
         */
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.firstButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.secondButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *tableViewConstraintX = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *tableViewConstraintY = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *tableViewConstraintWidth = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        NSLayoutConstraint *tableViewConstraintHeight = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-49];
        
        tableViewConstraintX.identifier = @"tableView--X";
        tableViewConstraintY.identifier = @"tableView--Y";
        tableViewConstraintWidth.identifier = @"tableView--Width";
        tableViewConstraintHeight.identifier = @"tableView--Height";
        
        NSLayoutConstraint *firstButtonConstraintX1 = [NSLayoutConstraint constraintWithItem:self.firstButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:0.5 constant:0];
        NSLayoutConstraint *firstButtonConstraintX2 = [NSLayoutConstraint constraintWithItem:self.firstButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        
        NSLayoutConstraint *firstButtonConstraintY = [NSLayoutConstraint constraintWithItem:self.firstButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5];
        NSLayoutConstraint *firstButtonConstraintWidth = [NSLayoutConstraint constraintWithItem:self.firstButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:152.5];
        NSLayoutConstraint *firstButtonConstraintHeight = [NSLayoutConstraint constraintWithItem:self.firstButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:39];
        
        firstButtonConstraintX1.identifier = @"firstButton--X1";
        firstButtonConstraintX2.identifier = @"firstButton--X2";
        firstButtonConstraintY.identifier = @"firstButton--Y";
        firstButtonConstraintWidth.identifier = @"firstButton--Width";
        firstButtonConstraintHeight.identifier = @"firstButton--Height";
        
        firstButtonConstraintX1.priority = UILayoutPriorityDefaultHigh;
        firstButtonConstraintX2.priority = UILayoutPriorityDefaultLow;
        self.firstButtonConstraintX1 = firstButtonConstraintX1;
        self.firstButtonConstraintX2 = firstButtonConstraintX2;
        
        self.firstButtonConstraintWidth = firstButtonConstraintWidth;
        
        NSLayoutConstraint *secondButtonConstraintX = [NSLayoutConstraint constraintWithItem:self.secondButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.5 constant:0];
        NSLayoutConstraint *secondButtonConstraintY = [NSLayoutConstraint constraintWithItem:self.secondButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.firstButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *secondButtonConstraintWidth = [NSLayoutConstraint constraintWithItem:self.secondButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:152.5];
        NSLayoutConstraint *secondButtonConstraintHeight = [NSLayoutConstraint constraintWithItem:self.secondButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:39];
        
        secondButtonConstraintX.identifier = @"secondButton--X";
        secondButtonConstraintY.identifier = @"secondButton--Y";
        secondButtonConstraintWidth.identifier = @"secondButton--Width";
        secondButtonConstraintHeight.identifier = @"secondButton--Height";
        
        [self.view addConstraints:@[tableViewConstraintX, tableViewConstraintY, tableViewConstraintWidth, tableViewConstraintHeight]];
        
        
        [self.view addConstraints:@[firstButtonConstraintX1, firstButtonConstraintX2, firstButtonConstraintY, firstButtonConstraintWidth, firstButtonConstraintHeight]];
        
        [self.view addConstraints:@[secondButtonConstraintX, secondButtonConstraintY, secondButtonConstraintWidth, secondButtonConstraintHeight]];

    } else {
        
        [self.view addSubview:self.tableView = dfView];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *tableViewConstraintX = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *tableViewConstraintY = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *tableViewConstraintWidth = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        NSLayoutConstraint *tableViewConstraintHeight = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        [self.view addConstraints:@[tableViewConstraintX, tableViewConstraintY, tableViewConstraintWidth, tableViewConstraintHeight]];
    }
}

- (void)hideSecondButton
{
    self.firstButtonConstraintX1.priority = UILayoutPriorityDefaultLow;
    self.firstButtonConstraintX2.priority = UILayoutPriorityDefaultHigh;
    self.firstButtonConstraintWidth.constant = 310;
    self.secondButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateData
{
    NSLog(@"%s", __FUNCTION__);
}

@end
