//
//  CardSignViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/30.
//  Copyright © 2016年 ace-009. All rights reserved.
//



#import "CardSignViewController.h"
#import "ScanQRCodeViewController.h"
#import "ClockCodeViewController.h"
#import "NavigationView.h"
#import "Masonry.h"
#import "UIButton+InitButton.h"
#import "PermissionDoc.h"
#import "ColorImage.h"
#import "NormalEditCell.h"
#import "ScanQRCodeViewController.h"

const NSInteger kBtnWidth = 110;

@interface CardSignViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) UITableView * myTableView;

@property (nonatomic,strong) NavigationView *navigationView;
@end

@implementation CardSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
       if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"考勤"];
    [self.view addSubview:self.navigationView];
    
    [self initTableView];
}

-(void)initTableView
{
   
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW + 5), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f )style:UITableViewStyleGrouped];
    _myTableView.showsHorizontalScrollIndicator = NO;
    _myTableView.showsVerticalScrollIndicator = NO;
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.separatorColor = kTableView_LineColor;
    _myTableView.autoresizingMask = UIViewAutoresizingNone;
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        _myTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
    }
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_myTableView setTableFooterView:view];
    [self.view addSubview:_myTableView];
    
    if ((IOS7 || IOS8)) {
        _myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }    
}
#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        [self initBtnWith:cell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)initBtnWith:(UITableViewCell *)cell
{
        if ([[PermissionDoc sharePermission] rule_attendance_code]) { //权限控制 |47|
//    if (YES) {
        CGFloat width  =  cell.contentView.frame.size.width / 2;
        CGFloat padding = (width - kBtnWidth) / 2 - 5;
        UIButton *cardBtn = [UIButton buttonWithTitle:nil target:self selector:@selector(chooseAction:) frame:CGRectMake(padding, 25, kBtnWidth, kBtnWidth) backgroundImg:[UIImage imageNamed:@"signCard"] highlightedImage:nil];
        cardBtn.tag = 101;
        [cell.contentView addSubview:cardBtn];
        UIButton *codeBtn = [UIButton buttonWithTitle:nil target:self selector:@selector(chooseAction:) frame:CGRectMake(CGRectGetMaxX(cardBtn.frame) + (padding *2), 25, kBtnWidth, kBtnWidth) backgroundImg:[UIImage imageNamed:@"signCode"] highlightedImage:nil];
        codeBtn.tag = 102;
        [cell.contentView  addSubview:codeBtn];
    }else{
        CGFloat padding = (cell.contentView.frame.size.width - kBtnWidth) / 2 - 5;
        UIButton *cardBtn = [UIButton buttonWithTitle:nil target:self selector:@selector(chooseAction:) frame:CGRectMake(padding, 25, kBtnWidth, kBtnWidth) backgroundImg:[UIImage imageNamed:@"signCard"] highlightedImage:nil];
        cardBtn.tag = 101;
        [cell.contentView  addSubview:cardBtn];
    }

}
-(void)chooseAction:(UIButton *)sender
{
    if (sender.tag == 101) {
            ScanQRCodeViewController *sc = [[ScanQRCodeViewController alloc] init];
            sc.viewFor = 2;
            [self.navigationController pushViewController:sc animated:YES];
    }else
    {
            ClockCodeViewController *clo = [[ClockCodeViewController alloc] init];
            [self.navigationController pushViewController:clo animated:YES];
    }
}


@end
