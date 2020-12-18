//
//  SelectViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/17.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "SelectViewController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "UIButton+InitButton.h"
#import "ColorImage.h"

@interface SelectViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) DFUITableView *tableView;
@property (nonatomic, weak) NavigationView *navigaView;
@end

@implementation SelectViewController

//static NSString *cellIdentifier = @"selectCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    self.tableView.frame = CGRectMake(5.0f, self.navigaView.frame.origin.y + self.navigaView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f - 36.0f);
    UIButton *sub = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(confirmAction) frame:CGRectMake(5.0f,CGRectGetMaxY(self.tableView.frame), 310.0f , 36.0f) backgroundImg:ButtonStyleBlue];
    [self.view addSubview:sub];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}
- (void)confirmAction
{
    if ([self.delegate respondsToSelector:@selector(selectNameOfFilterNameObject:titleName:)]) {
        [self.delegate selectNameOfFilterNameObject:self.selectName titleName:self.selectTitle];
    }

    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -  tableViewDataSoure && tableViweDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"SelectCell%@",indexPath];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1010];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(275, 4, 30, 30)];
        imageView.image = [UIImage imageNamed:@"icon_Checked"];
        imageView.tag = 1010;
        [cell.contentView addSubview:imageView];
    }
    UILabel * titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 200, kTableView_HeightOfRow)];
    titlelabel.tag = 2000+indexPath.row;
    titlelabel.font = kFont_Light_14;
    [cell.contentView addSubview:titlelabel];
    
    UILabel * title = (UILabel *)[cell.contentView viewWithTag:2000+indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *name = self.dataArray[indexPath.row];
    title.text = name;
    
    if ([self.selectName isEqualToString:name]) {
        imageView.image = [UIImage imageNamed:@"icon_Checked"];
    } else {
        imageView.image = [UIImage imageNamed:@"icon_unChecked"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *name = self.dataArray[indexPath.row];
    if ([self.selectName isEqualToString:name]) {
        self.selectName = nil;
    } else {
        self.selectName = name;
    }
    [tableView reloadData];
}

- (NavigationView *)navigaView
{
    if (_navigaView == nil) {
        NavigationView *nav = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:self.selectTitle];
        
        [self.view addSubview:_navigaView = nav];
    }
    return _navigaView;
}

- (DFUITableView *)tableView
{
    if (_tableView == nil) {
        DFUITableView *tab = [[DFUITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tab.delegate = self;
        tab.dataSource = self;
        tab.separatorColor = kTableView_LineColor;
        tab.showsVerticalScrollIndicator = YES;
//        [tab registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        [self.view addSubview:_tableView = tab];
    }
    return _tableView;
}

@end
