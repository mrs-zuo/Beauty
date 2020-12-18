//
//  CustomerBasicViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CustomerBasicViewController.h"
#import "CustomerEditViewController.h"
#import "ChatViewController.h"
#import "UIPlaceHolderTextView.h"
#import "UIImageView+WebCache.h"
#import "UILabel+InitLabel.h"

#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "DEFINE.h"
#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "CusEditComplexCell.h"
#import "CusEditNormalCell.h"
#import "CusEditAddressCell.h"
#import "CustomerDoc.h"
#import "MessageDoc.h"
#import "PhoneDoc.h"
#import "EmailDoc.h"
#import "AddressDoc.h"
#import "CommodityDoc.h"
#import "UserDoc.h"
#import "noCopyTextField.h"
#import "GPNavigationController.h"

#import "SelectCustomersViewController.h"
#import "GPBHTTPClient.h"
#import "DFTableCell.h"
#import "AccountECard_ViewController.h"
#import "OrderRootViewController.h"

#define SALES_SHOW  (RMO(@"|4|"))
UIView* goBackgroundView;
@interface CustomerBasicViewController ()<SelectCustomersViewControllerDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetBasicInfoOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddOppOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getTwoDimensionalCodeOperation;
@property (strong, nonatomic) CustomerDoc *theCustomer;

@property (strong, nonatomic) NSMutableArray *titleArray;

@property (strong, nonatomic) UIImageView *headImgView;
@property (strong, nonatomic) UIImageView *sexImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong ,nonatomic) UILabel * vipCodeLable;
@property (strong ,nonatomic) UILabel * userNameLable;
@property (strong ,nonatomic) UIButton * codeButton;
@property (nonatomic) UIImageView *TwoDimensionalCodeImageView;
@property (retain, nonatomic) NSString *twoDimensionalCodeURL;
@property (nonatomic, weak) NavigationView *naviView;
@property (nonatomic, strong) NSMutableArray *slaveArray;
@property (nonatomic, strong) NSMutableString *slaveNames;
@property (nonatomic, strong) NSMutableString *slaveID;
@end

@implementation CustomerBasicViewController
@synthesize theCustomer;
@synthesize titleArray;
@synthesize headImgView, nameLabel, titleLabel,vipCodeLable;
@synthesize codeButton,sexImageView,userNameLable;
@synthesize TwoDimensionalCodeImageView;
@synthesize twoDimensionalCodeURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (NSString *)slaveNames
{
    NSMutableArray *nameArray = [NSMutableArray array];
    if (self.slaveArray.count) {
        for (UserDoc *user in self.slaveArray) {
            [nameArray addObject:user.user_Name];
        }
    }
    return [nameArray componentsJoinedByString:@"、"];
}

- (NSString *)slaveID
{
    NSMutableArray *slaveIdArray = [NSMutableArray array];
    NSMutableString *str = [NSMutableString string];
    if (self.slaveArray.count) {
        for (UserDoc *user in self.slaveArray) {
            [slaveIdArray addObject:@(user.user_Id)];
        }
        NSString *tmpIds = [slaveIdArray componentsJoinedByString:@","];
        [str appendString:[NSString stringWithFormat:@"[%@]", tmpIds]];
    } else {
        [str appendString:@""];
    }
    return str;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetBasicInfoOperation || [_requestGetBasicInfoOperation isExecuting]) {
        [_requestGetBasicInfoOperation cancel];
        _requestGetBasicInfoOperation = nil;
    }
    
    if (_requestAddOppOperation || [_requestAddOppOperation isExecuting]) {
        [_requestAddOppOperation cancel];
        _requestAddOppOperation = nil;
    }

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    titleArray = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self requesCustomertList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initNavigationViewAndTableView];
    [self requestTwoDimensionalCode];
    
}

-(void)initData
{
    self.slaveArray = [NSMutableArray array];
    self.slaveNames = [NSMutableString string];
    self.slaveID = [NSMutableString string];
}

- (void)initNavigationViewAndTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"基本信息"];
    [self.view addSubview:navigationView];
    self.naviView = navigationView;
    ((GPNavigationController*)self.navigationController).canDragBack = YES;

    if ((IOS7 || IOS8)) {
        [_tableView setFrame:CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f,
                                        kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f)];
        _tableView.separatorInset = UIEdgeInsetsZero; 
        
    } else if (IOS6) {
        [_tableView setFrame:CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f,
                                        kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f )];
    }
    _tableView.backgroundView  = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, 100.0f)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    [_tableView setTableHeaderView:headerView];
    
    UIView *cusHeadImageView = [[UIView alloc] init];
    cusHeadImageView.backgroundColor = [UIColor whiteColor];
    if ((IOS7 || IOS8)) {
        cusHeadImageView.frame = CGRectMake(0.0f, 7.0f, 320.0f, 90.0f);
    } else if (IOS6) {
        cusHeadImageView.frame = CGRectMake(10.0f, 7.0f, 300.0f, 90.0f);
    }
    [_tableView.tableHeaderView setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:cusHeadImageView];

    headImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_HeadImg80"]];
    headImgView.frame = CGRectMake(10.0f, 10.0f, 70.0f, 70.0F);
    headImgView.layer.borderColor = [kTableView_LineColor CGColor];
    headImgView.layer.shadowColor = [UIColor blackColor].CGColor;
    headImgView.layer.shadowOpacity = 0.7f;
    headImgView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    headImgView.layer.shadowRadius = 3.0f;
    headImgView.layer.masksToBounds = NO;
    headImgView.userInteractionEnabled = YES;
    [cusHeadImageView addSubview:headImgView];
    
    codeButton = [UIButton buttonWithTitle:nil target:self selector:@selector(CodeShow:) frame:CGRectMake(285.0f, 60.0f, 21.0f, 21.0f) backgroundImg:[UIImage imageNamed:@"twoCode"] highlightedImage:nil];
    [cusHeadImageView addSubview:codeButton];
    
    TwoDimensionalCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(280.0f, 60.0f, 21.0f, 21.0f)];
    [cusHeadImageView addSubview:TwoDimensionalCodeImageView];
    
    sexImageView = [[UIImageView alloc] initWithFrame:CGRectMake(95, 8, 13,18)];
    sexImageView.image = [UIImage imageNamed:@"sex_girl"];
    [cusHeadImageView addSubview:sexImageView];
    
    nameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(115.0f, 10.0f, 150.0f, 20.0f)  title:[NSString stringWithFormat:@"姓名:  --" ]];
    [nameLabel  setFont:kFont_Light_16];
    [cusHeadImageView addSubview:nameLabel];
    
    userNameLable = [UILabel initNormalLabelWithFrame:CGRectMake(95.0f, 35.0f, 200.0f, 20.0f)  title:@"称呼:  --"];
    [userNameLable setFont:kFont_Light_15];
    [cusHeadImageView addSubview:userNameLable];
    
    vipCodeLable = [UILabel initNormalLabelWithFrame:CGRectMake(95.0f, 65.0f, 150.0f, 20.0f)  title:[NSString stringWithFormat:@"会员号:  --" ]];
    [vipCodeLable setFont:kFont_Light_15];
    [cusHeadImageView addSubview:vipCodeLable];
    
//    //    订单、账户 按钮
//    UIButton *orderButton = [UIButton buttonTypeRoundedRectWithTitle:@"订单" target:self selector:@selector(pushToOrderView:) frame:CGRectMake(170.0f , 95.0f, 60.0f, 25.0f) titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:6.0f];
//    [cusHeadImageView addSubview:orderButton];
//    
//    UIButton *accountButton = [UIButton buttonTypeRoundedRectWithTitle:@"账户" target:self selector:@selector(pushToAccount:) frame:CGRectMake(240.0f , 95.0f, 60.0f, 25.0f) titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:6.0f];
//    [cusHeadImageView addSubview:accountButton];
   
    // 飞语
    UIButton *sendButton = [UIButton buttonWithTitle:@""
                                              target:self
                                            selector:@selector(sendAction:)
                                               frame:CGRectMake(250.0f + 30.0f, 10.0f, 30.0f, 30.0f)
                                       backgroundImg:[UIImage imageNamed:@"Menu0_Chat"]
                                    highlightedImage:nil];
    [cusHeadImageView addSubview:sendButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)CodeShow:(UIButton *)sender
{
    UIImageView * imageViewL = [[UIImageView alloc] init];
    [imageViewL setImageWithURL:[NSURL URLWithString:[twoDimensionalCodeURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@""]];
    
    UIImage *image = imageViewL.image;
    if (!image) return;
    window = [UIApplication sharedApplication].keyWindow;
    goBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    defaultRect = [TwoDimensionalCodeImageView convertRect:TwoDimensionalCodeImageView.bounds toView:window];//关键代码，坐标系转换
    goBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    NSLog(@"defultRect =%f",defaultRect.origin.x);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:defaultRect];
    imageView.image = image;
    imageView.tag = 1;
    UIImageView *fakeImageView = [[UIImageView alloc]initWithFrame:defaultRect];
    [goBackgroundView addSubview:fakeImageView];
    [goBackgroundView addSubview:imageView];
    [window addSubview:goBackgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [goBackgroundView addGestureRecognizer:tap];
    TwoDimensionalCodeImageView.alpha = 0;
    [UIView animateWithDuration:0.5f animations:^{
        imageView.frame=CGRectMake(20.0f,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width - 40.0f, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width - 40.0f);
        
        goBackgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
    } completion:^(BOOL finished) {
    }];
}

- (void)hideImage:(UITapGestureRecognizer*)tap{
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.5f animations:^{
        imageView.frame = defaultRect;
        goBackgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        self.view.alpha = 1;
        [goBackgroundView removeFromSuperview];
    }];
}

#pragma mark - Custom

- (void)sendAction:(id)sender
{
    if (![[PermissionDoc sharePermission] rule_Chat_Use]) {
        [SVProgressHUD showErrorWithStatus2:@"您没有发送消息的权限!" touchEventHandle:^{}];
        return;
    }
    
    ChatViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
    
    UserDoc *userDoc = [[UserDoc alloc] init];
    [userDoc setUser_Id:theCustomer.cus_ID];
    [userDoc setUser_Name:theCustomer.cus_Name];
    [userDoc setUser_Available:1];
    [userDoc setUser_HeadImage:theCustomer.cus_HeadImgURL];
    [chatViewController setUsers_Selected:[NSMutableArray arrayWithObjects:userDoc, nil]];
    
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)editAction:(id)sender
{
   [self performSegueWithIdentifier:@"goCustomerEditViewFromCustomerBasicView" sender:self];
}

-(void)pushToOrderView:(UIButton *)sender
{
    OrderRootViewController *payment = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderRootViewController"];
    [self.navigationController pushViewController:payment animated:YES];
}
-(void)pushToAccount:(UIButton *)sender
{
    if (![[PermissionDoc sharePermission] rule_ECard_Read]) {
        [SVProgressHUD showErrorWithStatus2:@"您还没有查看账户权限!" touchEventHandle:^{}];
        return;
    }else{
        AccountECard_ViewController *accountECard = [[AccountECard_ViewController alloc] init];
        [self.navigationController pushViewController:accountECard animated:YES];
    }
}

- (void)reloadData
{
    [_tableView reloadData];
    
    DLOG(@"+++++%@",theCustomer.cus_HeadImgURL );
    [headImgView setImageWithURL:[NSURL URLWithString:theCustomer.cus_HeadImgURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg80"]];
    nameLabel.text = [NSString stringWithFormat:@"%@",theCustomer.cus_Name.length ==0 ?@" ":theCustomer.cus_Name];
    vipCodeLable.text = theCustomer.cus_LoginStarMob;
    userNameLable.text = [NSString stringWithFormat:@"%@", theCustomer.cus_Title.length ==0 ?@"":theCustomer.cus_Title];
    titleLabel.text = theCustomer.cus_Title;
    if (theCustomer.cus_gender) {
        sexImageView.image = [UIImage imageNamed:@"sex_boy"];//男
    }else
    {
        sexImageView.image = [UIImage imageNamed:@"sex_girl"];//女
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goCustomerEditViewFromCustomerBasicView"]) {
        CustomerEditViewController *customerEditController = segue.destinationViewController;
        customerEditController.customerDoc = theCustomer;
    }
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *titleStr = [titleArray objectAtIndex:section];
    if ([titleStr isEqualToString:@"电话"])
    {
        return [theCustomer.cus_PhoneArray count];
    }
    else if ([titleStr isEqualToString:@"电子邮件"])
    {
        return [theCustomer.cus_EmailArray count];
    }
    else if ([titleStr isEqualToString:@"地址"])
    {
        return [theCustomer.cus_AdrsArray count] + 1;
    }
    else if ([titleStr isEqualToString:@"专属顾问"])
    {
        return SALES_SHOW ? 2: 1;
    }
    else if ([titleStr isEqualToString:@"注册方式"])
    {
        return 1;
    }
    else if([titleStr isEqualToString:@"顾客来源"]){
        return 1;
    }
    else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int index = 3;
    if ([theCustomer.cus_PhoneArray count] > 0 && (theCustomer.editStatus & CustomerEditStatusContacts)) {
        index ++;
    }
    if ([theCustomer.cus_EmailArray count] > 0 && (theCustomer.editStatus & CustomerEditStatusContacts)) {
        index ++;
    }
    if ([theCustomer.cus_AdrsArray count] > 0 && (theCustomer.editStatus & CustomerEditStatusContacts)) {
        index ++;
    }
    
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"电话"])
    {
        CusEditComplexCell *cell = [self configCusEditComplexCell:tableView indexPath:indexPath];
        return cell;
    }
    else if ([titleStr isEqualToString:@"电子邮件"])
    {
        CusEditComplexCell *cell = [self configCusEditComplexCell:tableView indexPath:indexPath];
        return cell;
    }
    else if ([titleStr isEqualToString:@"地址"])
    {
        if (indexPath.row == 0) {
            CusEditNormalCell *cell = [self configCusEditNormalCell:tableView indexPath:indexPath];
            return cell;
        } else {
            CusEditAddressCell *cell = [self configCusEditAddressCell:tableView indexPath:indexPath];
            return cell;
        }
    }
    else if ([titleStr isEqualToString:@"专属顾问"])
    {
        if (indexPath.row == 0) {
            CusEditNormalCell *cell = [self configCusEditNormalCell:tableView indexPath:indexPath];
            return cell;
        }
        if (indexPath.row == 1) {
            static NSString  *sysCell = @"sysCell";
            DFTableCell *secCell = [tableView dequeueReusableCellWithIdentifier:sysCell];
            if (!secCell) {
                secCell = [[DFTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sysCell];
                secCell.textLabel.font = kFont_Light_16;
                secCell.textLabel.textColor = kColor_DarkBlue;
                secCell.selectionStyle = UITableViewCellSelectionStyleNone;
                secCell.detailTextLabel.font = kFont_Light_16;
            }
            secCell.tag = 202;
            secCell.textLabel.text = @"销售顾问";
            secCell.detailTextLabel.textColor = kColor_Black;
            secCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",([self.slaveID isEqualToString:@""] ? @"请选择销售顾问": self.slaveNames)];
            if ([self.slaveID isEqualToString:@""]) {
                [secCell.detailTextLabel setTextColor:kColor_Editable];
            }
            return secCell;
        }
    }
    else if ([titleStr isEqualToString:@"注册方式"]) {
        static NSString *choseString = @"choseString";
        DFTableCell *chooseCell = [tableView dequeueReusableCellWithIdentifier:choseString];
        if (!chooseCell) {
            chooseCell = [[DFTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:choseString];
            chooseCell.textLabel.font = kFont_Light_16;
            chooseCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        chooseCell.textLabel.text = @"注册方式";
        chooseCell.detailTextLabel.text = [self CustomerDoc:theCustomer];
        chooseCell.detailTextLabel.textColor = kColor_Black;
//        chooseCell.imageView.image = (theCustomer.isImport ? [UIImage imageNamed:@"zixun_Permit"]:[UIImage imageNamed:@"zixun_NoPermit"]);
        __weak DFTableCell *weakCell = chooseCell;
        chooseCell.layoutBlock = ^{
//            weakCell.textLabel.frame = CGRectMake(15.0f, 9.0f, 100.0f, 20.0f);
            weakCell.imageView.frame = CGRectMake(277.0f, 9.0f, 21.0f, 21.0f);
        };
        return chooseCell;
    }
    else if ([titleStr isEqualToString:@"顾客来源"]) {
        static NSString *sourceString = @"sourceString";
        DFTableCell *sourceCell = [tableView dequeueReusableCellWithIdentifier:sourceString];
        if (!sourceCell) {
            sourceCell = [[DFTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sourceString];
            sourceCell.textLabel.font = kFont_Light_16;
            sourceCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        sourceCell.textLabel.text = @"顾客来源";
        sourceCell.detailTextLabel.text = theCustomer.cus_sourceTypeName;
        sourceCell.detailTextLabel.textColor = kColor_Black;
        __weak DFTableCell *weakCell = sourceCell;
        sourceCell.layoutBlock = ^{
            weakCell.imageView.frame = CGRectMake(277.0f, 9.0f, 21.0f, 21.0f);
        };
        return sourceCell;
    }
    else
    {
        return nil;
    }
    return nil;
}
- (NSString *)CustomerDoc:(CustomerDoc *)customerDoc
{
    NSString *title= @"";
    if ([customerDoc.cus_RegistFrom isEqualToString:@"0"]) {
        title = @"商家注册";
    }else if([customerDoc.cus_RegistFrom isEqualToString:@"1"]){
        title = @"顾客导入";
    }else if([customerDoc.cus_RegistFrom isEqualToString:@"2"]){
        title = @"自助注册(T站)";
    }
    return title;
}


// 配置CusEditAddressCell
- (CusEditAddressCell *)configCusEditAddressCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentify = @"CusEditAddressCell";
    CusEditAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[CusEditAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        [cell canEdit:NO];
    }
    
    AddressDoc *addressDoc = [theCustomer.cus_AdrsArray objectAtIndex:indexPath.row - 1];
    [cell updateData:addressDoc];
    [cell.adrsText setTextColor:[UIColor blackColor]];
    [cell.zipText setTextColor:[UIColor blackColor]];
    [cell.adrsText setUserInteractionEnabled:NO];
    [cell.zipText  setUserInteractionEnabled:NO];
    return cell;
}

// 配置CusEditComplexCell
- (CusEditComplexCell *)configCusEditComplexCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentify = @"CusEditComplexCell";
    CusEditComplexCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[CusEditComplexCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        [cell canEdit:NO];
    }
    
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"电话"])
    {
        cell.titleLabel.text = @"电话";
        PhoneDoc *thePhone = [theCustomer.cus_PhoneArray objectAtIndex:indexPath.row];
        cell.typeText.text = thePhone.phoneType;
        cell.contentText.text = thePhone.ph_PhoneNum;
    }
    else if ([titleStr isEqualToString:@"电子邮件"])
    {
        cell.titleLabel.text = @"邮件";
        EmailDoc *theEmail = [theCustomer.cus_EmailArray objectAtIndex:indexPath.row];
        cell.typeText.text = theEmail.emailType;
        cell.contentText.text = theEmail.email_Email;
    }
    
    if (indexPath.row == 0) {
        [cell.titleLabel setHidden:NO];
    } else {
        [cell.titleLabel setHidden:YES];
    }
    [cell.contentText setTextColor:[UIColor blackColor]];
    return cell;
}

// 配置CusEditNormalCell
- (CusEditNormalCell *)configCusEditNormalCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentify = @"CusEditNormalCell";
    CusEditNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[CusEditNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.tag = 0;
    
    [cell.contentText setEnabled:NO];
    [cell.contentText setTextColor:[UIColor blackColor]];

    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"地址"]) {
        cell.titleNameLabel.text = @"地址";
        [cell.contentText setHidden:YES];
    } else if ([titleStr isEqualToString:@"会员登录手机号"]) {
        cell.titleNameLabel.text = @"会员登录手机号";
        [cell.contentText setHidden:NO];
        if ([theCustomer.cus_LoginMobileDoc.ph_PhoneNum length] > 0) {
            [cell.contentText setText:theCustomer.cus_LoginMobileDoc.ph_PhoneNum];
        } else {
            [cell.contentText setText:@"无"];
        }
    } else if ([titleStr isEqualToString:@"专属顾问"]) {
        cell.titleNameLabel.text = @"专属顾问";
        [cell.contentText setHidden:NO];

        if (theCustomer.cus_ResponsiblePersonName != nil && ![theCustomer.cus_ResponsiblePersonName isEqualToString:@""]) {
            [cell.contentText setText:theCustomer.cus_ResponsiblePersonName];
        } else {
            if (theCustomer.editStatus & CustomerEditStatusBasic) {
                [cell.contentText setTextColor:kColor_Editable];
                cell.tag = 201;
            }
            [cell.contentText setText:@"无"];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"地址"])
    {
        if (indexPath.row != 0 && indexPath.row <= [theCustomer.cus_AdrsArray count]) {
            AddressDoc *addressDoc = [theCustomer.cus_AdrsArray objectAtIndex:indexPath.row - 1];
            return addressDoc.cell_Address_Height + 20.0f;
        }
    }
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 201 && [[PermissionDoc sharePermission] rule_CustomerInfo_Write]) {
        
        SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
        selectCustomer.prevView = 8;
        selectCustomer.customerId = theCustomer.cus_ID;
        [selectCustomer setSelectModel:0 userType:1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:nil];
        [selectCustomer setNavigationTitle:@"设置专属顾问"];
        [selectCustomer setPersonType:CustomePersonGroup];

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navigationController animated:YES completion:^{}];
        
    }else if (cell.tag == 202  && [self.slaveID isEqualToString:@""]) {
        
        [self chooseSalesPerson];
        
    }
}

- (void)chooseSalesPerson {
    
    SelectCustomersViewController *selectCustomer =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    selectCustomer.prevView = 10;
    selectCustomer.customerId = theCustomer.cus_ID;
    [selectCustomer setSelectModel:1 userType:2 customerRange:CUSTOMEROFMINE defaultSelectedUsers:self.slaveArray];
    
    [selectCustomer setDelegate:self];
    [selectCustomer setNavigationTitle:@"设置销售顾问"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}


- (void)dismissViewControllerWithSelectedSales:(NSArray *)userArray
{
    self.slaveArray = [NSMutableArray arrayWithArray:userArray];
    [_tableView reloadData];
}


- (void)showMessage:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}
#pragma mark - 接口
//
-(void)requestTwoDimensionalCode
{
    [SVProgressHUD showWithStatus:@"Loading"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger UserId = appDelegate.customer_Selected.cus_ID;
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyCode\":\"%@\",\"Code\":\"%ld\",\"Type\":\"%d\",\"QRCodeSize\":\"%d\"}", ACC_COMPANTCODE, (long)UserId, 0, 9];
    
    _getTwoDimensionalCodeOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/WebUtility/GetQRCode" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            twoDimensionalCodeURL = data;
            
        } failure:^(NSInteger code, NSString *error) {
            [self showMessage:@"获取二维码失败！"];
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)requesCustomertList
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;

    
    if (customerId == 0 && kMenu_Type == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择顾客" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)customerId];

    _requestGetBasicInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/getCustomerBasic" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (theCustomer == nil){
                theCustomer = [[CustomerDoc alloc] init];
            }
            [theCustomer setCus_ID:[[data objectForKey:@"CustomerID"] integerValue]];
            [theCustomer setCus_Name:[data objectForKey:@"CustomerName"]];
            [theCustomer setCus_Title:[data objectForKey:@"Title"]];
//            [theCustomer setIsImport:[[data objectForKey:@"IsPast"] boolValue]];
            [theCustomer setCus_RegistFrom:[[data objectForKey:@"RegistFrom"] stringValue]];
            [theCustomer setCus_gender:[[data objectForKey:@"Gender"] integerValue]];
            [theCustomer setCus_LoginMobile:[data objectForKey:@"LoginMobile"]];
            [theCustomer setCus_sourceType:[[data objectForKey:@"SourceTypeID"] integerValue]];
            [theCustomer setCus_sourceTypeName:[data objectForKey:@"SourceTypeName"]];
            NSString *mobile = [data objectForKey:@"LoginMobile"];
            if (mobile) {
                PhoneDoc *pho = [[PhoneDoc alloc] init];
                pho.ph_PhoneNum = mobile;
                pho.ph_Type = 0;
                theCustomer.cus_LoginMobileDoc = pho;
            } else {
                theCustomer.cus_LoginMobileDoc = nil;
            }

            [theCustomer setCus_HeadImgURL:[data objectForKey:@"HeadImageURL"]];
            [theCustomer setCus_ResponsiblePersonName:[data objectForKey:@"ResponsiblePersonName"]];
            [theCustomer setCus_ResponsiblePersonID:[[data objectForKey:@"ResponsiblePersonID"] integerValue]];
            
            [theCustomer setCus_IsMyCustomer:appDelegate.customer_Selected.cus_IsMyCustomer];
            [theCustomer setCus_checkoutCount:appDelegate.customer_Selected.cus_checkoutCount];
            [theCustomer setCus_appointCount:appDelegate.customer_Selected.cus_appointCount];
            appDelegate.customer_Selected = theCustomer;
            
            NSArray *pArray = [data objectForKey:@"PhoneList"];
            NSArray *eArray = [data objectForKey:@"EmailList"];
            NSArray *adrsArray = [data objectForKey:@"AddressList"];

            if ([theCustomer.cus_PhoneArray count] > 0) {
                [theCustomer.cus_PhoneArray removeAllObjects];
            }
            if (pArray.count > 0) {
                [pArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    PhoneDoc *phoneDoc = [[PhoneDoc alloc] init];
                    [phoneDoc setPh_ID:[[obj objectForKey:@"PhoneID"] integerValue]];
                    [phoneDoc setPh_Type:[[obj objectForKey:@"PhoneType"] integerValue]];
                    [phoneDoc setPh_PhoneNum:[obj objectForKey:@"PhoneContent"]];
                    [theCustomer.cus_PhoneArray addObject:phoneDoc];
                }];
            }
            
            if ([theCustomer.cus_EmailArray count] > 0) {
                [theCustomer.cus_EmailArray removeAllObjects];
            }
            
            if (eArray.count > 0) {
                [eArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    EmailDoc *emailDoc = [[EmailDoc alloc] init];
                    [emailDoc setEmail_ID:[[obj objectForKey:@"EmailID"] integerValue]];
                    [emailDoc setEmail_Type:[[obj objectForKey:@"EmailType"]  integerValue]];
                    [emailDoc setEmail_Email:[obj objectForKey:@"EmailContent"]];
                    [theCustomer.cus_EmailArray addObject:emailDoc];
                }];
            }
          
            
            if ([theCustomer.cus_AdrsArray count] > 0) {
                [theCustomer.cus_AdrsArray removeAllObjects];
            }
            if (adrsArray.count > 0) {
                [adrsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    AddressDoc *adrsDoc = [[AddressDoc alloc] init];
                    [adrsDoc setAdrs_Id:[[obj objectForKey:@"AddressID"] integerValue]];
                    [adrsDoc setAdrs_Type:[[obj objectForKey:@"AddressType"] integerValue]];
                    [adrsDoc setAdrs_Address:[obj objectForKey:@"AddressContent"]];
                    [adrsDoc setAdrs_ZipCode:[obj objectForKey:@"ZipCode"]];
                    [theCustomer.cus_AdrsArray addObject:adrsDoc];
                }];
            }
            
            titleArray = [NSMutableArray arrayWithObjects:@"专属顾问",@"顾客来源",@"注册方式", @"电话",@"电子邮件", @"地址", nil];
            NSMutableArray *deleteArray = [NSMutableArray array];
            if ([theCustomer.cus_PhoneArray count] == 0 || !(theCustomer.editStatus & CustomerEditStatusContacts)) {
                [deleteArray addObject:[titleArray objectAtIndex:3]];
            }
            if ([theCustomer.cus_EmailArray count] == 0 || !(theCustomer.editStatus & CustomerEditStatusContacts)) {
                [deleteArray addObject:[titleArray objectAtIndex:4]];
            }
            if ([theCustomer.cus_AdrsArray count] == 0 || !(theCustomer.editStatus & CustomerEditStatusContacts)) {
                [deleteArray addObject:[titleArray objectAtIndex:5]];
            }
            
            [titleArray removeObjectsInArray:deleteArray];
            
            if (theCustomer.editStatus & CustomerEditStatusBasic)  {
                [self.naviView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Edit"] selector:@selector(editAction:)];
            }
            
            [self.slaveArray removeAllObjects];
            
            NSArray *tempArr = [data objectForKey:@"SalesList"];
            if (![tempArr isKindOfClass:[NSNull class]] && tempArr.count > 0) {
                    for (NSDictionary * dic in [data objectForKey:@"SalesList"]) {
                        UserDoc * user = [[UserDoc alloc] init];
                        
                        user.user_Name = [dic objectForKey:@"SalesName"];
                        user.user_Id = [[dic objectForKey:@"SalesPersonID"] integerValue];
                        [self.slaveArray addObject:user];
                }
            }
            [self reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

@end
