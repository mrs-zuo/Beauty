//
//  CustomerAddViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-12-29.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "CustomerAddViewController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "CusEditHeadImgView.h"
#import "CusEditComplexCell.h"
#import "PhoneDoc.h"
#import "NormalEditCell.h"
#import "CustomerDoc.h"
#import "SelectCustomersViewController.h"
#import "FooterView.h"
#import "GPHTTPClient.h"
#import "EcardInfo.h"
#import "SourceType.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "PermissionDoc.h"
#import "DFTableAlertView.h"
#import "GPBHTTPClient.h"
#import "NSData+Base64.h"
#import "DFTableCell.h"
#import "UILabel+InitLabel.h"
#import "CusMainViewController.h"
#import "GPNavigationController.h"

#define LEVEL_SET [[PermissionDoc sharePermission] rule_CustomerLevel_Write]
#define SALES_SHOW  (RMO(@"|4|"))

@interface CustomerAddViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CustomerEditDelegate, OrderAddCellDelegate, SelectCustomersViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
@property (nonatomic, weak)   AFHTTPRequestOperation *requestLevel;
@property (nonatomic, weak)   AFHTTPRequestOperation *requestSourceType;
@property (nonatomic, weak)   AFHTTPRequestOperation *addCustomerOperation;
@property (nonatomic, strong) DFUITableView *cusTableView;
@property (nonatomic, strong) CusEditHeadImgView   *cusEditImg;
@property (nonatomic, strong) NSMutableArray *phoneArray;
@property (nonatomic, strong) NSMutableArray *mobileArray;
@property (nonatomic, strong) NSArray *typeArray;
@property (nonatomic, strong) NSMutableArray *levelInfo;
@property (nonatomic, strong) NSMutableArray *sourceTypeList;
@property (nonatomic ,assign) NSInteger chooseGirl;
@property (nonatomic, strong) NSMutableArray *slaveArray;
@property (nonatomic, strong) NSMutableString *slaveNames;
@property (nonatomic, strong) NSMutableString *slaveID;
@end

@implementation CustomerAddViewController
@synthesize cusTableView;
@synthesize cusEditImg;
@synthesize phoneArray;
@synthesize newcustomer;
@synthesize mobileArray;
@synthesize typeArray;
@synthesize levelInfo;
@synthesize sourceTypeList;



- (NSString *)slaveNames
{
    NSMutableArray *nameArray = [NSMutableArray array];
    if (self.slaveArray.count) {
        for (UserDoc *user in self.slaveArray) {
            [nameArray addObject:user.user_Name];
        }
    }
    NSLog(@"the nameArray is %@", [nameArray componentsJoinedByString:@"、"]);
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
    NSLog(@"str is %@", str);
    return str;
}


- (NSMutableArray *)mobileArray
{
    if (!mobileArray) {
        mobileArray = [NSMutableArray array];
    } else {
        [mobileArray removeAllObjects];
    }
//        [mobileArray addObject:@"无"];
        NSString *regularNumString = @"[0-9]{8}"; //匹配8-13位的数字
        NSRegularExpression *regexNum = [NSRegularExpression regularExpressionWithPattern:regularNumString options:NSRegularExpressionCaseInsensitive error:nil];
        for (PhoneDoc *ph in phoneArray) {
            if (ph.ph_Type == 0 && ph.ph_PhoneNum.length > 7 && ph.ph_PhoneNum.length < 14 ) {
                if ( /*[regexChar numberOfMatchesInString:ph.ph_PhoneNum options:0 range:NSMakeRange(0, ph.ph_PhoneNum.length)] == 0 //不能匹配到数字之外的字符
                      && */[regexNum numberOfMatchesInString:ph.ph_PhoneNum options:0 range:NSMakeRange(0, ph.ph_PhoneNum.length)] > 0 //至少匹配成功1次
                    ) {
                    [mobileArray addObject:ph];
//                    [mobileArray addObject:ph.ph_PhoneNum];
                }
            }
        }
    return mobileArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[[UIApplication sharedApplication] keyWindow] bounds];
    
    self.view.backgroundColor = kColor_Background_View;

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    phoneArray = [NSMutableArray array];
    
    typeArray = @[@"手机",@"住宅",@"工作",@"其他"];
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"新增顾客"];

    cusTableView = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    if (IOS7 || IOS8) {
        cusTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    } else if (IOS6) {
        cusTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    cusTableView.delegate = self;
    cusTableView.dataSource = self;
    
    newcustomer.cus_Level = 0;
    newcustomer.cus_LevelName = @"无";
    
    levelInfo = [NSMutableArray array];
    
    [levelInfo addObject:[[EcardInfo alloc] initWithDictionary: @{@"CardID":@0,@"CardName":@"无"}]];
    
    sourceTypeList=[NSMutableArray array];
    self.chooseGirl = 0;//选择性别默认为女

    [self levelRequest];
    
    cusEditImg = [[CusEditHeadImgView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f)];
    cusEditImg.customerEditController = self;
    [cusEditImg updateData:newcustomer];
    cusTableView.tableHeaderView = cusEditImg;

    [self.view addSubview:navigationView];
    [self.view addSubview:cusTableView];
    
    [self initData];
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(submitInfo)];
    [footerView showInTableView:cusTableView];
    
}

-(void)initData
{
    self.slaveArray = [NSMutableArray array];
    self.slaveNames = [NSMutableString string];
    self.slaveID = [NSMutableString string];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //解决ios8调用相机然后裁剪图片后，状态栏消失（调用拍照页面时，会自动隐藏状态栏，所有只要页面还在拍照页及后续调用的图片裁剪页，以下代码无效，所以需要在此处调用以显示状态栏）
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)submitInfo
{
    [self.view endEditing:YES];
    newcustomer.cus_Name = cusEditImg.nameText.text;
    newcustomer.cus_Title = cusEditImg.titleText.text;
    
    if ([newcustomer.cus_Name length] == 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"姓名不允许为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [newcustomer setCus_Title:newcustomer.cus_Title ? newcustomer.cus_Title : @""];
    newcustomer.cus_LoginMobile = newcustomer.cus_LoginMobileDoc.ph_PhoneNum ? newcustomer.cus_LoginMobileDoc.ph_PhoneNum : @"";
    
    UIImage *uploadImag = [cusEditImg getLocalImage];
    NSString *imageType = [cusEditImg getImageType];
    [newcustomer setCus_HeadImg:uploadImag];
    [newcustomer setCus_ImgType:imageType];
    [self appendJson];
    [self addCustomerInfoWithJson:newcustomer flag:1];

}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return phoneArray.count + 1;
        case 4:
            return SALES_SHOW ? 2 : 1;
        
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        
        if (indexPath.row < phoneArray.count) {
            CusEditComplexCell *cell = [self configCusEditComplexCell:tableView indexPath:indexPath];
            return cell;
        } else {
            OrderAddCell *cell = [self configOrderAddCell:tableView indexPath:indexPath];
            return cell;
        }
    }
    else {
        NSString *sCell = [NSString stringWithFormat:@"systemCell_%ld_%ld",(long)indexPath.row,(long)indexPath.section];
        UITableViewCell *cell = [cusTableView dequeueReusableCellWithIdentifier:sCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sCell];
        }else
        {
            [cell removeFromSuperview];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sCell];
        }
        cell.textLabel.font = kFont_Light_16;
        cell.textLabel.textColor = kColor_DarkBlue;
        cell.detailTextLabel.font = kFont_Light_16;
        cell.detailTextLabel.textColor = kColor_Editable;

        switch (indexPath.section) {
            case 0:
            {
                cell.textLabel.text = @"性别";
                cell.detailTextLabel.text =@"";
                
                UIButton * sexBoyBt =[[UIButton alloc] initWithFrame:CGRectMake(150, 5, 30, 30)];
                [sexBoyBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
                [sexBoyBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
                [sexBoyBt addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
                
                UILabel *boylLable = [[UILabel alloc] initWithFrame:CGRectMake(180, 10, 20, 20)];
                boylLable.text = @"男";
                [cell.contentView addSubview:boylLable];
                
                UIButton * sexGirlBt =[[UIButton alloc] initWithFrame:CGRectMake(220, 5, 30, 30)];
                [sexGirlBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
                [sexGirlBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
                [sexGirlBt addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
                sexGirlBt.selected = NO;
                sexGirlBt.tag = 1;
                [cell.contentView addSubview:sexGirlBt];
                
                UILabel *girlLable = [[UILabel alloc] initWithFrame:CGRectMake(250, 10, 20, 20)];
                girlLable.text = @"女";
                [cell.contentView addSubview:girlLable];
                
                sexBoyBt.tag = 2;
                sexBoyBt.selected = NO;
                if (self.chooseGirl) {//为1选择为男
                    sexBoyBt.selected = YES;
                }else{//为0选择为女
                    sexGirlBt.selected = YES;
                }
                [cell.contentView addSubview:sexBoyBt];
                
            }
                break;
            case 2:
                cell.textLabel.text = @"会员登录手机号";
                cell.detailTextLabel.text = newcustomer.cus_LoginMobileDoc.ph_PhoneNum.length > 0 ? newcustomer.cus_LoginMobileDoc.ph_PhoneNum : @"无";
                break;

            case 3:
                cell.textLabel.text = @"e账户";
                if (!LEVEL_SET) {
                    cell.detailTextLabel.textColor = kColor_Black;
                }
                cell.detailTextLabel.text = newcustomer.cus_LevelName;
                break;
            case 4:
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"专属顾问";
                    cell.detailTextLabel.text = newcustomer.cus_ResponsiblePersonName;
                }
                if (indexPath.row == 1) {
                    cell.textLabel.text = @"销售顾问";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",([self.slaveNames isEqualToString:@""] ? @"选择销售顾问": self.slaveNames)];;
                }
                break;
            case 5:
                cell.textLabel.text = @"顾客来源";
                cell.detailTextLabel.text=newcustomer.cus_sourceTypeName;
                break;
            case 6:
            {
                static NSString *choose = @"choose";
                DFTableCell *chooseCell = [tableView dequeueReusableCellWithIdentifier:choose];
                if (!chooseCell) {
                    chooseCell = [[DFTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:choose];
                    chooseCell.textLabel.font = kFont_Light_16;
                    chooseCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                chooseCell.textLabel.text = @"顾客转入";
                chooseCell.imageView.image = (newcustomer.isImport ? [UIImage imageNamed:@"zixun_Permit"]:[UIImage imageNamed:@"zixun_NoPermit"]);
                __weak DFTableCell *weakCell = chooseCell;
                chooseCell.layoutBlock = ^{
                    weakCell.textLabel.frame = CGRectMake(15.0f, 9.0f, 100.0f, 20.0f);
                    weakCell.imageView.frame = CGRectMake(277.0f, 9.0f, 21.0f, 21.0f);
                };

                return chooseCell;
            }
            default:
                break;
        }
        return cell;
    }

}

#pragma mark Cell Add
// add cell
- (OrderAddCell *)configOrderAddCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
        NSString *cellIdentify = @"OrderAddCell";
        OrderAddCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (cell == nil) {
            cell = [[OrderAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundColor = [UIColor whiteColor];
        }
        cell.promptLabel.text = @"添加新的号码";
        if (indexPath.row == 0) {
            cell.titleLabel.hidden = NO;
            cell.titleLabel.frame = CGRectMake(15.0f ,0.0f, 40.0f, kTableView_HeightOfRow) ;
            cell.titleLabel.text = @"电话";
            cell.titleLabel.textColor = kColor_DarkBlue;
            cell.titleLabel.font = kFont_Light_16;
        } else {
            cell.titleLabel.hidden = YES;
        }
        return cell;
}


- (CusEditComplexCell *)configCusEditComplexCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentify = @"CusEditComplexCell";
    CusEditComplexCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[CusEditComplexCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.delegate = self;
    cell.contentText.delegate = self;
    cell.typeText.delegate = self;
    cell.titleLabel.frame = CGRectMake(15.0f ,0.0f, 40.0f, kTableView_HeightOfRow) ;
    cell.titleLabel.text = @"电话";
    PhoneDoc *thePhone = [phoneArray objectAtIndex:indexPath.row];
    cell.typeText.text = thePhone.phoneType;
    cell.contentText.text = thePhone.ph_PhoneNum;
    cell.contentText.placeholder = @"输入电话";
    
    if (indexPath.row == 0) {
        [cell.titleLabel setHidden:NO];
    } else {
        [cell.titleLabel setHidden:YES];
    }
    
    return cell;
}


#pragma mark - OrderAddCellDelegate
- (void)chickAddButton:(UITableViewCell *)cell
{
    [self.view endEditing:YES];
    
    NSIndexPath *indexPath = [cusTableView indexPathForRowAtPoint:cell.center];
    
    PhoneDoc *new = [[PhoneDoc alloc] init];
    [new setPh_ID:0];
    [new setPh_PhoneNum:@""];
    [new setPh_Type:0];
    [new setCtlFlag:1];
    [phoneArray addObject:new];
    
    [cusTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [cusTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark - CustomerEditDelegate
- (void)deleteCellWithCell:(UITableViewCell *)cell
{
        [self.view endEditing:YES]; // 恢复tableView高度和keyboard隐藏
        
        // 点击delete 删除的cell
        //NSIndexPath *theIndexPath = [_tableView indexPathForRowAtPoint:cell.center];
        NSIndexPath *theIndexPath = [cusTableView indexPathForCell:cell];
    
    
        if (!theIndexPath) {
            NSLog(@"the index is nil");
            return;
        }
    
    
        PhoneDoc *phone = [phoneArray objectAtIndex:theIndexPath.row];
    
        if ([newcustomer.cus_LoginMobileDoc.ph_PhoneNum isEqualToString:phone.ph_PhoneNum]) {
            newcustomer.cus_LoginMobileDoc = nil;
        }

        [phoneArray removeObjectAtIndex:theIndexPath.row];
    
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:1];
        [indexSet addIndex:2];

        [cusTableView deleteRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        double delayInSeconds = 0.2f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [cusTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3 && LEVEL_SET) {
        [self customerLevel];
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            [self chooseResponsiblePerson];
        }
        if (indexPath.row == 1) {
            [self chooseSalesPerson];
        }
    }
    if (indexPath.section == 2) {
        [self chooseMobileAcc];
    }
    if(indexPath.section==5){
         [self customerSourceType];
    }
    if (indexPath.section == 6) {
        newcustomer.isImport = !newcustomer.isImport;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

//choose sex
-(void)chooseSex:(UIButton *)sender
{
    if (sender.tag ==1) {//女
        self.chooseGirl = 0;
    }else//男
    {
        self.chooseGirl = 1;
    }
    [cusTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark 会员等级设置
- (void)customerLevel
{
    
    DFTableAlertView *alert = [DFTableAlertView tableAlertTitle:@"选择储值卡" NumberOfRows:^NSInteger(NSInteger section) {
        return levelInfo.count;
    } CellOfIndexPath:^UITableViewCell *(DFTableAlertView *alert, NSIndexPath *indexPath) {
        static NSString *ecardCell = @"ecardCell";
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:ecardCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ecardCell];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 40.0f)];
            label.tag = 100;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = kColor_SysBlue;//[UIColor blueColor];
            
            label.font = kFont_Light_18;
            
            [cell.contentView addSubview:label];
            if (IOS8) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
        }
        UILabel *lab = (UILabel *)[cell viewWithTag:100];
        lab.text = ((EcardInfo *)levelInfo[indexPath.row]).CardName;
        
        return cell;
    }];
    
    [alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
        EcardInfo *info = [levelInfo objectAtIndex:selectedIndex.row];
        newcustomer.cus_Level = info.CardID;
        newcustomer.cus_LevelName = info.CardName;
        
        [cusTableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        
    } Completion:^{
        NSLog(@"Completion");
    }];
    
    [alert show];
}
#pragma mark 顾客来源设置
- (void)customerSourceType
{
    DFTableAlertView *alert = [DFTableAlertView tableAlertTitle:@"选择顾客来源" NumberOfRows:^NSInteger(NSInteger section) {
        return sourceTypeList.count;
    } CellOfIndexPath:^UITableViewCell *(DFTableAlertView *alert, NSIndexPath *indexPath) {
        static NSString *sourceTypeCell = @"sourceTypeCell";
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:sourceTypeCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sourceTypeCell];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 40.0f)];
            label.tag = 101;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = kColor_SysBlue;//[UIColor blueColor];
            
            label.font = kFont_Light_18;
            
            [cell.contentView addSubview:label];
            if (IOS8) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
        }
        UILabel *lab = (UILabel *)[cell viewWithTag:101];
        lab.text = ((SourceType *)sourceTypeList[indexPath.row]).Name;
        
        return cell;
    }];
    
    [alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
        SourceType *info = [sourceTypeList objectAtIndex:selectedIndex.row];
        newcustomer.cus_sourceType = info.ID;
        newcustomer.cus_sourceTypeName = info.Name;
        [cusTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationNone];
        
    } Completion:^{
        NSLog(@"Completion");
    }];
    
    [alert show];
}

#pragma mark 专属顾问设置
- (void)chooseResponsiblePerson
{
    SelectCustomersViewController *selectCustomer =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    
    if (newcustomer.cus_ResponsiblePersonID == 0) {
        [selectCustomer setSelectModel:0 userType:3 customerRange:CUSTOMEROFMINE defaultSelectedUsers:nil];
    } else {
        UserDoc *userDoc = [[UserDoc alloc] init];
        [userDoc setUser_Id:newcustomer.cus_ResponsiblePersonID];
        [userDoc setUser_Name:newcustomer.cus_ResponsiblePersonName];
        [selectCustomer setSelectModel:0 userType:3 customerRange:CUSTOMEROFMINE defaultSelectedUsers:@[userDoc]];
    }
    [selectCustomer setDelegate:self];
    [selectCustomer setNavigationTitle:@"选择顾问"];
    [selectCustomer setPersonType:CustomePersonGroup];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];

}
#pragma mark - SelectCustomersViewControllerDelegate
- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    UserDoc *userDoc = [userArray firstObject];
    newcustomer.cus_ResponsiblePersonID = userDoc.user_Id;
    newcustomer.cus_ResponsiblePersonName = userDoc.user_Name;
    
    [cusTableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -销售顾问选择
- (void)chooseSalesPerson
{
    SelectCustomersViewController *selectCustomer =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    
    [selectCustomer setSelectModel:1 userType:2 customerRange:CUSTOMEROFMINE defaultSelectedUsers:self.slaveArray];
    [selectCustomer setDelegate:self];
    [selectCustomer setNavigationTitle:@"选择销售顾问"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];

}

- (void)dismissViewControllerWithSelectedSales:(NSArray *)userArray
{
    self.slaveArray = [NSMutableArray arrayWithArray:userArray];
    [cusTableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark 会员登录手机号选择
- (void)chooseMobileAcc
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"会员登录手机号选择" delegate:self cancelButtonTitle:@"无" destructiveButtonTitle:nil otherButtonTitles:nil];
    for (PhoneDoc *ph in self.mobileArray) {
        [actionSheet addButtonWithTitle:ph.ph_PhoneNum];
    }
    [actionSheet showInView:self.view];
    
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        newcustomer.cus_LoginMobileDoc = nil;

    } else {
        newcustomer.cus_LoginMobileDoc = [self.mobileArray objectAtIndex:buttonIndex - 1];
     }
    [cusTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    
}


#pragma mark TextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textField.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    }
    
    NSIndexPath *index = [cusTableView indexPathForCell:cell];
    
    if (textField.tag == 102) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"电话类型选择" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        for (NSString *type in typeArray) {
            [alert addButtonWithTitle:type];
        }
        alert.tag = index.row;
        [alert show];
        return NO;
    }
    
    textField.keyboardType = UIKeyboardTypeNumberPad;
    return YES;
    
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:textField];
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString =  textField.text;

    if (toBeString.length > 20)
        textField.text = [toBeString substringToIndex:20];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
     *   数据判断(check)
     */
    const char *ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    __block BOOL result = YES;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([substring rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
    
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:textField];
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textField.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    }
    
    NSIndexPath *index = [cusTableView indexPathForCell:cell];
    PhoneDoc *phoneDoc = [phoneArray objectAtIndex:index.row];
    phoneDoc.ph_PhoneNum = [NSString stringWithFormat:@"%@", textField.text];
    [self checkLoginMob];
}


#pragma mark uialertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"the alertView Tag is %ld ---buttonIndex %ld",(long)alertView.tag, (long)buttonIndex);
    PhoneDoc *phone = [phoneArray objectAtIndex:alertView.tag];
    [phone setPh_Type:buttonIndex];
    
    [cusTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [self checkLoginMob];
}

- (void)checkLoginMob {
    if (newcustomer.cus_LoginMobileDoc.ph_Type != 0 || !(newcustomer.cus_LoginMobileDoc.ph_PhoneNum.length > 7 && newcustomer.cus_LoginMobileDoc.ph_PhoneNum.length < 14)) {
        newcustomer.cus_LoginMobileDoc = nil;
    }
    [cusTableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark 点击收回键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
    [cusEditImg.nameText resignFirstResponder];
    [cusEditImg.titleText resignFirstResponder];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [cusEditImg.nameText resignFirstResponder];
    [cusEditImg.titleText resignFirstResponder];

}

#pragma mark 数据处理
-(void)appendJson
{
    NSMutableArray *sendPhoneArray = [[NSMutableArray alloc] init];
    for (PhoneDoc *phoneDoc in phoneArray) {
        if (![phoneDoc.ph_PhoneNum isEqual: @""] && phoneDoc.ph_PhoneNum != nil) {
            [sendPhoneArray addObject:phoneDoc];
        }
    }
    [newcustomer.cus_PhoneArray removeAllObjects];
    [newcustomer.cus_PhoneArray addObjectsFromArray:sendPhoneArray];
    
    
    NSMutableString *sendPhone_SendJson0 = [NSMutableString string];
    [sendPhone_SendJson0 appendString:@"["];
    for (PhoneDoc *phoneDoc in newcustomer.cus_PhoneArray) {
            [sendPhone_SendJson0 appendFormat:@"{\"PhoneType\":%ld,",(long)phoneDoc.ph_Type];
            [sendPhone_SendJson0 appendFormat:@"\"PhoneContent\":\"%@\"},",phoneDoc.ph_PhoneNum];
    }
    
    if([[sendPhone_SendJson0 substringFromIndex:sendPhone_SendJson0.length -1] isEqual:@","])
        [sendPhone_SendJson0 deleteCharactersInRange:NSMakeRange(sendPhone_SendJson0.length - 1, 1)];
    [sendPhone_SendJson0 appendString:@"]"];
    newcustomer.cus_PhoneSend = sendPhone_SendJson0;
    
    newcustomer.cus_EmailSend = @"[]";
    
    newcustomer.cus_AddressSend = @"[]";
}

#pragma mark 网络请求
//获得储值卡列表
- (void)levelRequest
{
    NSDictionary * par =@{
                          @"isOnlyMoneyCard":@true,
                          @"isShowAll":@false,
                          @"BranchID":@(ACC_BRANCHID)
                          };
    _requestLevel = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetBranchCardList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [(NSArray *)data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([[obj objectForKey:@"CardTypeID"] integerValue] ==1) {
                    [levelInfo addObject:[[EcardInfo alloc] initWithDictionary:obj]];
                }
            }];
            for (EcardInfo *info in levelInfo) {
                if (info.IsDefault) {
                    newcustomer.cus_Level = info.CardID;
                    newcustomer.cus_LevelName = info.CardName;
                }
            }
            [self getSourceTypeList];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}
//获取顾客来源列表
- (void)getSourceTypeList
{
    NSDictionary * par =@{};
    _requestSourceType = [[GPBHTTPClient sharedClient] requestUrlPath:@"/customer/GetCustomerSourceType" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [(NSArray *)data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [sourceTypeList addObject:[[SourceType alloc] initWithDictionary:obj]];
            }];
            if(sourceTypeList.count>0){
                SourceType *st=[sourceTypeList objectAtIndex:0];
                newcustomer.cus_sourceType = st.ID;
                newcustomer.cus_sourceTypeName = st.Name;
            }
            [cusTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

-(void)addCustomerInfoWithJson:(CustomerDoc *)newCustomerDoc flag:(NSInteger)flag
{
    [SVProgressHUD showWithStatus:@"Loading"];
    self.view.userInteractionEnabled = NO;
    
    int headFlag = 0;
    NSString *imgStr  = @"";
    UIImage *headImg  = newCustomerDoc.cus_HeadImg;
    NSString *imgType = newCustomerDoc.cus_ImgType;
    if (headImg) {
        NSData *imgData = UIImageJPEGRepresentation(headImg, 0.3f);
        imgStr = [imgData base64EncodedString];
        headFlag = 1;
    }
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"CreatorID\":%ld,\"IsCheck\":%ld,\"ResponsiblePersonID\":%ld,\"CustomerName\":\"%@\",\"Title\":\"%@\",\"LoginMobile\":\"%@\",\"CardID\":%ld,\"PhoneList\":%@,\"EmailList\":%@,\"AddressList\":%@,\"ImageString\":\"%@\",\"ImageType\":\"%@\",\"HeadFlag\":%d,\"ImageWidth\":%d,\"ImageHeight\":%d,\"IsPast\":%d,\"SalesPersonIDList\":%@,\"Gender\":%ld,\"SourceType\":%ld}",(long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)flag, (long)newCustomerDoc.cus_ResponsiblePersonID, newCustomerDoc.cus_Name, newCustomerDoc.cus_Title, newCustomerDoc.cus_LoginMobile, (long)newCustomerDoc.cus_Level, newCustomerDoc.cus_PhoneSend, newCustomerDoc.cus_EmailSend, newCustomerDoc.cus_AddressSend, imgStr, imgType, headFlag, 160, 160, newCustomerDoc.isImport, self.slaveID,(long)self.chooseGirl,(long)newCustomerDoc.cus_sourceType];
    
    // Gender //0 nv  1 nan  
    _addCustomerOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/addCustomer" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加成功，是否选中该顾客?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    CustomerDoc *customer = [[CustomerDoc alloc] init];
                    [customer setCus_Name:[data objectForKey:@"CustomerName"]];
                    [customer setCus_ID:[[data objectForKey:@"CustomerID"] integerValue]];
                    [customer setCus_QuanPinYin:[data objectForKey:@"PinYin"]];
                    [customer setCus_ShortPinYin:[data objectForKey:@"PinYinFirst"]];
                    [customer setCus_HeadImgURL:[data objectForKey:@"HeadImageURL"]];
                    [customer setCus_LoginMobile:[data objectForKey:@"LoginMobile"]];
                    float discount = [[data objectForKey:@"Discount"] integerValue];
                    [customer setCus_Discount:discount == 0 ? 1.0f : discount];
                    
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    app.customer_Selected = customer;
                    
                    [customer setCus_IsMyCustomer:[[data objectForKey:@"IsMyCustomer"] boolValue]];
                    if (self.addOrigin == CustomerAddOriginOrderMain) {
                        CusMainViewController *completionVC = [[CusMainViewController alloc] init];
                        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
                        completionVC.viewOrigin = CusMainViewOriginProductList;
                        GPNavigationController *navCon = [[GPNavigationController alloc] initWithRootViewController:completionVC];
                        navCon.canDragBack = YES;
                        
                        CGRect frame = self.slidingViewController.topViewController.view.frame;
                        self.slidingViewController.topViewController = navCon;
                        self.slidingViewController.topViewController.view.frame = frame;
                        [self.slidingViewController resetTopView];

                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                self.view.userInteractionEnabled = YES;
            }];
            
        } failure:^(NSInteger code, NSString *error) {
            if (code == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@%@",error,@"是否继续提交?"] delegate:nil cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        self.view.userInteractionEnabled = YES;
                    } else {
                        [self addCustomerInfoWithJson:newcustomer flag:0];
                    }
                }];
                
            } else if(code == -1){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"新增顾客失败，请重试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {}];
                self.view.userInteractionEnabled = YES;
            } else if(code == -2 || code == -3){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                self.view.userInteractionEnabled = YES;
            }
            
        }];
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
    }];
}


@end
