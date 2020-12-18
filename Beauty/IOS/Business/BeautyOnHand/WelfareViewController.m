//
//  WelfareViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/2/23.
//  Copyright © 2016年 ace-009. All rights reserved.
//
//#define TableViewBorder     5.0
//#define ButtonFieldHeight   32.0



#import "WelfareViewController.h"
#import "NavigationView.h"
#import "MJRefresh.h"
#import "WelfareDetailsViewController.h"
#import "WelfareRes.h"
#import "GPBHTTPClient.h"
#import "AppDelegate.h"

CGFloat  const kBottom_height = 49;

@interface WelfareViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UIView *bottomView ;
}
@property (weak, nonatomic) AFHTTPRequestOperation *getCustomerBenefitListOperation;
@property (nonatomic,strong) UITableView *welfareTableView;
@property (nonatomic,strong) NSMutableArray *welfareDatas;

@property (nonatomic, strong) UIView *buttonField;
@property (nonatomic, assign) NSInteger currentButton;


@end

@implementation WelfareViewController
- (void)selectButton:(UIButton *)button
{
    UIButton *lastButton = (UIButton *)[ bottomView viewWithTag:self.currentButton];
    if (button.tag == self.currentButton) {
        return;
    }
    lastButton.selected = NO;
    button.selected = !button.selected;
    self.currentButton = button.tag;
    [self requestGetCustomerBenefitList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}
-(void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"福利包"];
    [self.view addSubview:navigationView];

    if ((IOS7 || IOS8)) {
        _welfareTableView.separatorInset = UIEdgeInsetsZero;
    }
    _welfareTableView = [[UITableView alloc]initWithFrame:CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 5,  kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - 64 - (navigationView.frame.origin.y + navigationView.frame.size.height) - kBottom_height) style:UITableViewStyleGrouped];
    _welfareTableView.allowsSelection = YES;
    _welfareTableView.showsHorizontalScrollIndicator = NO;
    _welfareTableView.showsVerticalScrollIndicator = NO;
    _welfareTableView.delegate =self;
    _welfareTableView.dataSource =self;
    _welfareTableView.autoresizingMask = UIViewAutoresizingNone;
    _welfareTableView.separatorColor = kTableView_LineColor;
    [self.view addSubview:_welfareTableView];
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_welfareTableView setTableFooterView:view];
    [_welfareTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    
    bottomView =[[UIView alloc]initWithFrame:CGRectMake(0, _welfareTableView.frame.size.height + _welfareTableView.frame.origin.y, kSCREN_BOUNDS.size.width, kBottom_height)];
    bottomView.backgroundColor =  RGBA(45, 156, 255, 1);
    
    NSArray *titleArrs = @[@"未使用",@"已过期",@"已使用"];
    CGFloat button_width = bottomView.frame.size.width / 3;
    for (int i = 0; i < titleArrs.count ; i ++) {
        NSString *title = titleArrs[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateSelected];
        button.titleLabel.font = kFont_Light_16;
        [button setTitleColor:kColor_White forState:UIControlStateNormal];
        [button setTitleColor:RGBA(0, 17, 130, 1) forState:UIControlStateSelected];
        button.tag = 100 + i;
        if (i == 0) {
            self.currentButton = button.tag;
            button.selected = YES;
        }
        button.frame = CGRectMake( button_width * i, 0, button_width, kBottom_height);
        [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
    }
    
    [self.view addSubview:bottomView];
}
- (void)initData
{
    _welfareDatas = [NSMutableArray array];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestGetCustomerBenefitList];
}
-(void)headerRefresh
{
    [self requestGetCustomerBenefitList];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_welfareDatas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //福利包
    static NSString * str = @"cell";
    UITableViewCell * cell = [_welfareTableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
        UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, cell.frame.size.width - 20, 30)];
        nameLab.tag = 1;
        nameLab.font = kFont_Medium_18 ;
       nameLab.textColor = kColor_White;
        [cell.contentView addSubview:nameLab];
        UILabel *nameDetailsLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, cell.frame.size.width - 20, 30)];
        nameDetailsLab.tag = 2;
        nameDetailsLab.font = kFont_Medium_16;
        nameDetailsLab.textColor = kColor_White;
        [cell.contentView addSubview:nameDetailsLab];
    }
    cell.layer.cornerRadius = 8 ;
    UILabel *nameLab = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *nameDetailsLab = (UILabel *)[cell.contentView viewWithTag:2];
    WelfareRes *welfare = [_welfareDatas objectAtIndex:indexPath.section];
    nameLab.text = welfare.PolicyName;
    nameDetailsLab.text = welfare.PolicyDescription;
    
    if (self.currentButton == 100) {
        cell.backgroundColor = [UIColor colorWithRed:176/255.0f green:35/255.0f blue:42/255.0f alpha:1.0f];
    }else{
        cell.backgroundColor = [UIColor colorWithRed:155/255.0f green:155/255.0f blue:155/255.0f alpha:1.0f];
    }

    
    UIImageView * imageNext = [[UIImageView alloc] initWithFrame:CGRectMake(_welfareTableView.frame.size.width-23, 30, 15, 18)];
    imageNext.image = [UIImage imageNamed:@"whiteArrows"];
    [cell.contentView addSubview:imageNext];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     WelfareRes *welfare = [_welfareDatas objectAtIndex:indexPath.section];
    WelfareDetailsViewController *welfareDetailsVC = [[WelfareDetailsViewController alloc]init];
    welfareDetailsVC.benefitID = welfare.BenefitID;
    [self.navigationController  pushViewController:welfareDetailsVC animated:YES];
}
#pragma mark - 接口

- (void)requestGetCustomerBenefitList{
    
//    /ECard/GetCustomerBenefitList 我的福利包
//    所需参数
//    {"Type":1,"CustomerID":2569}
    //    Type=1 未使用
    //    Type=2 已经过期
    //    Type=3 已经使用
         [SVProgressHUD showWithStatus:@"Loading"];
    NSInteger type = self.currentButton - 99;
    NSString *par = [NSString stringWithFormat:@"{\"Type\":%ld,\"CustomerID\":%ld}",type, (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID];
    
    _getCustomerBenefitListOperation= [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCustomerBenefitList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            [_welfareDatas removeAllObjects];
            if ([data isKindOfClass:[NSArray class]]) {
                NSArray *dataArrs = (NSArray *)data;
                if (dataArrs.count > 0) {
                    for (int i =0 ; i <dataArrs.count ; i ++) {
                        NSDictionary *dic = dataArrs[i];
                        WelfareRes *welfareRes = [[WelfareRes alloc]init];
//                        welfareRes.PolicyID = [dic objectForKey:@"PolicyID"];
                        welfareRes.PolicyName = [dic objectForKey:@"PolicyName"];
                        welfareRes.BenefitID = [dic objectForKey:@"BenefitID"];
                        welfareRes.PolicyDescription = [dic objectForKey:@"PolicyDescription"];
                        welfareRes.PRCode = [dic objectForKey:@"PRCode"];
                        welfareRes.PRValue1 = [dic objectForKey:@"PRValue1"];
                        welfareRes.PRValue2 = [dic objectForKey:@"PRValue2"];
                        welfareRes.PRValue3 = [dic objectForKey:@"PRValue3"];
                        welfareRes.PRValue4 = [dic objectForKey:@"PRValue4"];
                        [_welfareDatas addObject:welfareRes];
                    }
                }
            }
            [_welfareTableView headerEndRefreshing];
            [_welfareTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
}
@end
