//
//  FirstTopViewController.m
//  BeautyPromise02
//
//  Created by ZhongHe on 13-5-22.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "FirstTopViewController.h"
#import "UILabel+InitLabel.h"
#import "GDataXMLNode.h"
#import "DEFINE.h"
#import "AppDelegate.h" 

#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "DFUITableView.h"
#import "InfoTableViewCell.h"
#import "OperatingOrder.h"
#import "SelectCustomersViewController.h"
#import "FirstPageFilter.h"
#import "UserDoc.h"
#import "MJRefresh.h"
#import "ReportMarkingViewController.h"
#import "SelectViewController.h"
#import "CusMainViewController.h"
#import "MJRefresh.h"
#import "PermissionDoc.h"
#import "DFTableAlertView.h"
#import "GPBHTTPClient.h"
#import "GPHTTPClient.h"


#define ButtonViewHeight     44.0f

#define ButtonWidte     65.0f
@interface FirstTopViewController()<UITableViewDelegate, UITableViewDataSource, SelectViewControllerDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *GetTMListByGroupNo;
@property (nonatomic, strong) DFUITableView *firstTableView;
@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic, strong) NSArray *filterArray;
@property (nonatomic, weak)   NavigationView *navigationView;
@property (nonatomic, strong) FirstPageFilter *filter;
@property (nonatomic, strong) NSArray *accountArray;
@property (nonatomic, weak)   UIButton *personButton;
@property (nonatomic, weak)   UIButton *allBut;
@property (nonatomic, weak)   UIButton *progressBut;
@property (nonatomic, weak)   UIButton *completionBut;
@end

@implementation FirstTopViewController
@synthesize imageView;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)updateButtonStatus
{
    if (self.filter.type == 1) {
        [self Order:self.completionBut];
    } else if (self.filter.type == 2) {
        [self Order:self.progressBut];
    } else {
        [self Order:self.allBut];
    }
}

- (FirstPageFilter *)filter
{
    if (_filter == nil) {
        _filter = [[FirstPageFilter alloc] init];
    }
    return _filter;
}

- (NSArray *)accountArray
{
    if (_accountArray == nil) {
        _accountArray = [self.infoArray valueForKeyPath:@"@distinctUnionOfObjects.AccountName"];
    }
    return _accountArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[PermissionDoc sharePermission] rule_FirstTop_Read]) {
        [self initView];
        [self initData];
    } else {
        [imageView setFrame:CGRectMake(0.0f, kORIGIN_Y, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 20 - 44.0f)];
        [imageView setAutoresizingMask:UIViewAutoresizingNone];
        [imageView setUserInteractionEnabled:YES];
        [imageView sendSubviewToBack:self.view];
        
        if (kSCREN_BOUNDS.size.height == 480.0f) {
            [imageView setImage:[UIImage imageNamed:@"WelcomeImg1_x416"]];
        } else if (kSCREN_BOUNDS.size.height == 568.0f) {
            [imageView setImage:[UIImage imageNamed:@"WelcomeImg1_x504"]];
        }
    }
}

static NSString *infoCell = @"Cell";

- (NavigationView *)navigationView
{
    if (!_navigationView) {
        NavigationView *nav = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0) title:@"店内动态"];
        if ([[PermissionDoc sharePermission] rule_BusinessReport_Read]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW + 5.0, 5.0, 28.0, 28.0)];
            [button setBackgroundImage:[UIImage imageNamed:@"what"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(customerOrder) forControlEvents:UIControlEventTouchUpInside];
            [nav addSubview:button];
        }
        [self.view addSubview:_navigationView = nav];
    }
    return _navigationView;
}

- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;

    _firstTableView = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, self.navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    
    _firstTableView.delegate = self;
    _firstTableView.dataSource = self;
    _firstTableView.backgroundColor = [UIColor clearColor];
    _firstTableView.backgroundView = nil;
//    _firstTableView.showsVerticalScrollIndicator = YES;
    _firstTableView.sectionHeaderHeight = 5.0;
    _firstTableView.sectionFooterHeight = 0.0;
//    _firstTableView.autoresizingMask = UIViewAutoresizingNone;
    if (IOS7 || IOS8) {
        _firstTableView.frame = CGRectMake(5.0f, CGRectGetMaxY(self.navigationView.frame), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f - ButtonViewHeight);
        _firstTableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _firstTableView.frame = CGRectMake(-5.0f, CGRectGetMaxY(self.navigationView.frame), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f - ButtonViewHeight);
    }
//
//    [_firstTableView registerNib:[UINib nibWithNibName:@"InfoTableViewCell" bundle:nil] forCellReuseIdentifier:infoCell];
    
    [self.view addSubview:_firstTableView];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.firstTableView addHeaderWithTarget:self action:@selector(requestData)];
    
    [self initButton];
}

- (void)initButton
{
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - ButtonViewHeight - 64, kSCREN_BOUNDS.size.width, ButtonViewHeight)];
    buttonView.backgroundColor = kColor_ButtonBlue;
    
    UIButton *completionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [completionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completionButton setTitleColor:kColor_BackgroudBlue forState:UIControlStateSelected];
    [completionButton setTitle:@"进行中" forState:UIControlStateNormal];
    [completionButton addTarget:self action:@selector(Order:) forControlEvents:UIControlEventTouchUpInside];
    completionButton.frame = CGRectMake(0, 0, ButtonWidte, ButtonViewHeight);
    completionButton.tag = 1;
    completionButton.titleLabel.font = kFont_Light_14;
    completionButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    
    
    UIButton *progressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [progressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [progressButton setTitleColor:kColor_BackgroudBlue forState:UIControlStateSelected];
    [progressButton setTitle:@"已完成" forState:UIControlStateNormal];
    [progressButton addTarget:self action:@selector(Order:) forControlEvents:UIControlEventTouchUpInside];
    progressButton.frame = CGRectMake(CGRectGetMaxX(completionButton.frame), 0, ButtonWidte, ButtonViewHeight);
    progressButton.tag = 2;
    progressButton.titleLabel.font = kFont_Light_14;
    progressButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);

    
    UIButton *allsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [allsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [allsButton setTitleColor:kColor_BackgroudBlue forState:UIControlStateSelected];
    [allsButton setTitle:@"全部" forState:UIControlStateNormal];
    [allsButton addTarget:self action:@selector(Order:) forControlEvents:UIControlEventTouchUpInside];
    allsButton.frame = CGRectMake(CGRectGetMaxX(progressButton.frame), 0, ButtonWidte, ButtonViewHeight);
    allsButton.tag = 3;
    allsButton.titleLabel.font = kFont_Light_14;
    allsButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);

    
    UIButton *serviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [serviceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [serviceButton setTitleColor:kColor_BackgroudBlue forState:UIControlStateSelected];
    [serviceButton setTitle:@"服务顾问" forState:UIControlStateNormal];
    serviceButton.titleEdgeInsets = UIEdgeInsetsMake(0, 26, 0, 0);
    CALayer *layer = [CALayer layer];
    layer.contents = (id)[UIImage imageNamed:@"person"].CGImage;
    layer.frame = CGRectMake(23, 12, 16.5, 18.5);
    [serviceButton.layer addSublayer:layer];
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(2, 4, 1, 36);
    lineLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [serviceButton.layer addSublayer:lineLayer];
    [serviceButton addTarget:self action:@selector(serverButton) forControlEvents:UIControlEventTouchUpInside];
    serviceButton.frame = CGRectMake(CGRectGetMaxX(allsButton.frame), 0, kSCREN_BOUNDS.size.width - CGRectGetMaxX(allsButton.frame),  ButtonViewHeight);
    serviceButton.titleLabel.font = kFont_Light_14;

    //person

    self.completionBut = completionButton;
    self.allBut = allsButton;
    self.progressBut = progressButton;
    
    [buttonView addSubview:completionButton];
    [buttonView addSubview:progressButton];
    [buttonView addSubview:allsButton];
    [buttonView addSubview:serviceButton];
    [self.view addSubview:buttonView];
    
    [self updateButtonStatus];
}

- (void)customerOrder
{
    ReportMarkingViewController *reportMarkVC = [[ReportMarkingViewController alloc] init];
    [self.navigationController pushViewController:reportMarkVC animated:YES];
}

- (void)Order:(UIButton *)button
{
    if (button.selected) {
        return;
    }
    self.allBut.selected = NO;
    self.completionBut.selected = NO;
    self.progressBut.selected = NO;
    
    self.filter.type = button.tag;
    button.selected = YES;
    
    [self filterOrderList];
}


- (void)serverButton
{
    if (self.infoArray.count == 0) {
        return;
    }

    SelectViewController *selectVC = [[SelectViewController alloc] init];
    selectVC.selectName = self.filter.accountName;
    selectVC.dataArray = self.accountArray;
    selectVC.selectTitle = @"选择服务顾问";
    selectVC.delegate = self;
    [self.navigationController pushViewController:selectVC animated:YES];
}

- (void)selectNameOfFilterNameObject:(NSString *)nameObject titleName:(NSString *)title
{
    self.filter.accountName = nameObject;
//    [self.personButton setTitle:self.filter.displayName forState:UIControlStateNormal];
    [self filterOrderList];
}

- (void)filterOrderList
{
    [self updateButtonStatus];
    self.filterArray = [self.infoArray filteredArrayUsingPredicate:self.filter.filterPred];
    [self.firstTableView reloadData];
}

- (void)initData {
    
    [self.firstTableView headerBeginRefreshing];
}

- (void)requestData
{
    self.filter = [[FirstPageFilter alloc] init];
    [OperatingOrder requestGetUnfinishListCompletionBlock:^(NSArray *array, NSString *mesg, NSInteger code) {
        if (array) {
            self.infoArray = [[NSArray alloc] initWithArray:array];
            self.filterArray = [[NSArray alloc] initWithArray:[self.infoArray copy]];
            [self.firstTableView headerEndRefreshing];
            [self filterOrderList];
            [self.firstTableView reloadData];
        } else {
            
            [self.firstTableView headerEndRefreshing];
            [self initData];
        }
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filterArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentify = [NSString stringWithFormat:@"cell_%@",indexPath];
    InfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[InfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
    }
    
    cell.operInfo = [self.filterArray objectAtIndex:indexPath.row];
    OperatingOrder * operating = [self.filterArray objectAtIndex:indexPath.row];
    CGSize titleSize = [operating.designateAccountName  sizeWithFont:kFont_Light_14 constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
    float with = titleSize.width;
    if (with > 110) {
        with = 110;
    }
    
    UIButton * designButton = (UIButton *)[cell.contentView viewWithTag:1000+ indexPath.row];
    
    if (!designButton) {
        designButton = [[UIButton alloc] initWithFrame:CGRectMake(310-(10 + 15 +with), 7, 15, 15)];
        [designButton setImage:[UIImage imageNamed:@"DesignatedForTop"] forState:UIControlStateNormal];
        designButton.tag = 1000 + indexPath.row;
        designButton.hidden = YES;
        [designButton addTarget:self action:@selector(checkDesignated:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:designButton];
    }
    if (operating.IsDesignated) {
        designButton.hidden = NO;
        
        UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellLongPress:)];
        longPressGesture.minimumPressDuration = 1.0;
        longPressGesture.delegate = self;
        [cell addGestureRecognizer:longPressGesture];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  69;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OperatingOrder *oper = self.filterArray[indexPath.row];
    CustomerDoc *customer = [[CustomerDoc alloc] init];
    customer.cus_ID = oper.CustomerID;

    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected = customer;
    CusMainViewController *cusMain = [[CusMainViewController alloc] init];
    cusMain.viewOrigin = CusMainViewOriginFirstPage;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController pushViewController:cusMain animated:YES];
}


- (void)cellLongPress:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:_firstTableView];
        NSIndexPath * indexPath = [_firstTableView indexPathForRowAtPoint:point];
        OperatingOrder * operating = [self.filterArray objectAtIndex:indexPath.row];
        [self GetTMListByGroupNo:operating.GroupNo];
    }
    
}

#pragma mark choosePaymenAndChooseCard

-(void)checkDesignated:(UIButton *)sender
{
    OperatingOrder * operating = [self.filterArray objectAtIndex:(sender.tag-1000)];
    [self GetTMListByGroupNo:operating.GroupNo];
}

-(void)checkDesignatedList:(NSArray *)operatingArr
{
    DFTableAlertView *alert = [DFTableAlertView tableAlertTitle:@"指定状态" NumberOfRows:^NSInteger(NSInteger section) {
        return operatingArr.count;
        
    } CellOfIndexPath:^UITableViewCell *(DFTableAlertView *alert, NSIndexPath *indexPath) {
        NSString *ecardCell = [NSString stringWithFormat:@"ecardCell %@",indexPath];
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:ecardCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ecardCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            if (IOS8) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
            NSDictionary * treatmentDic = [operatingArr objectAtIndex:indexPath.row];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 130.0f, 40.0f)];
            label.tag = 100;
            label.textColor = kColor_DarkBlue;
            label.font = kFont_Light_16;
            label.text = [[treatmentDic objectForKey:@"SubServiceName"] length] ==0?@"服务操作":[treatmentDic objectForKey:@"SubServiceName"];
            [cell.contentView addSubview:label];
            
            NSString * str = [[treatmentDic objectForKey:@"IsDesignated"]integerValue] ==0?@"":@"指定:";
            UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(140.0f, 0.0f, 130.0f, 40.0f)];
            nameLable.tag = 101;
            nameLable.textAlignment = NSTextAlignmentRight;
            nameLable.textColor = [UIColor blackColor];
            nameLable.font = kFont_Light_16;
            nameLable.text = [NSString stringWithFormat:@"%@%@",str,[treatmentDic objectForKey:@"ExecutorName"]];
            [cell.contentView addSubview:nameLable];
        }
        return cell;
    }];

    [alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
        
    } Completion:^{
        
    }];
    
    [alert show];
    
}

-(void)GetTMListByGroupNo:(double)groupNO;
{

    NSDictionary * par = @{
                            @"GroupNo":@(groupNO)
                           };
    
    _GetTMListByGroupNo = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetTMListByGroupNo" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            
            [self checkDesignatedList:data];
            
        } failure:^(NSInteger code, NSString *error) {
            
            [SVProgressHUD showSuccessWithStatus2:error duration:3 touchEventHandle:^{
                
                [SVProgressHUD dismiss];
            }];
        }];
    } failure:^(NSError *error) {
        
        [SVProgressHUD dismiss];
    }];
    
}

@end

