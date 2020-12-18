//
//  MenuViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-2.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "MenuViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "UIImageView+WebCache.h"
#import "UILabel+InitLabel.h"
#import "GDataXMLDocument+ParseXML.h"
#import "AccountListViewController.h"
#import "SalonDetailViewController.h"
#import "ShoppingCartViewController.h"
#import "LoginDoc.h"
#import "SalesPromotionNewViewController.h"
#import "AppointmentList_ViewController.h"

#define CUS_PROMOTIONCOUNT      [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_PROMOTION"] integerValue]
#define CUS_COMPANYSCALE        [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_COMPANYSCALE"] integerValue]
#define CUS_REMINDCOUNT         [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_REMINDCOUNT"] integerValue]
#define CUS_PAYCOUNT            [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_PAYCOUNT"] integerValue]
#define CUS_CONFIRMCOUNT        [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_CONFIRMCOUNT"] integerValue]
#define CUS_COMPANYABBREVIATION [[NSUserDefaults standardUserDefaults]  objectForKey:@"CUSTOMER_COMPANYABBREVIATION"]

UIView* goBackgroundView;

@interface MenuViewController ()
{

    UIWindow *window;
    CGRect defaultRect;

}
@property (weak, nonatomic) AFHTTPRequestOperation * getCartCountOperation;
@property (weak, nonatomic) AFHTTPRequestOperation * getTwoDimensionalCodeOperation;
@property (assign, nonatomic) NSInteger cartCount;      //购物车数量
@property (assign, nonatomic) NSInteger messageCount;   //飞语数量
@property (assign, nonatomic) NSInteger promotionCount; //促销数量
@property (assign, nonatomic) NSInteger remindCount;    //提醒数量
@property (assign, nonatomic) NSInteger payCount;       //待付款数量
@property (assign, nonatomic) NSInteger confirmCount;   //待确认数量
//@property (assign, nonatomic) NSInteger reviewCount;   //待评价数量
@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UILabel *accountNameLabel;
@property (strong ,nonatomic) UIButton * codeButton;
@property (nonatomic) UIImageView *TwoDimensionalCodeImageView;
@property (retain, nonatomic) NSString *twoDimensionalCodeURL;
@property (strong,nonatomic)UIImageView * imageViewL;
@end

@implementation MenuViewController
@synthesize codeButton;
@synthesize twoDimensionalCodeURL;
@synthesize TwoDimensionalCodeImageView;
@synthesize imageViewL;

- (void)awakeFromNib
{
    //-------首页group-------
    MenuDoc *menu_Top_FirstTop    = [[MenuDoc alloc] initWithMenuName:@"首页" Image:[UIImage imageNamed:@"MenuIcon1-home"] View:@"FirstTopNavigation"];
    MenuDoc *menu_Top_Remind      = [[MenuDoc alloc] initWithMenuName:@"提醒" Image:[UIImage imageNamed:@"MenuIcon15-remind"] View:@"RemindListNavigation"];
    MenuDoc *menu_Set_Appointment  = [[MenuDoc alloc] initWithMenuName:@"预约" Image:[UIImage imageNamed:@"MenuIcon_Appointment"] View:@"AppointmentList_ViewController"];
    MenuDoc *menu_Top_WaitPay     = [[MenuDoc alloc] initWithMenuName:@"待付款" Image:[UIImage imageNamed:@"MenuIcon17-waitPay"] View:@"PayNavigation"];
    MenuDoc *menu_Top_WaitConfirm = [[MenuDoc alloc] initWithMenuName:@"待确认" Image:[UIImage imageNamed:@"MenuIcon16-waitConfirm"] View:@"ConfirmNavigation"];
    MenuDoc *menu_Top_Appraise = [[MenuDoc alloc] initWithMenuName:@"待评价" Image:[UIImage imageNamed:@"MenuIcon_Evaluate"] View:@"AppraiseNavigation"];
    _menu_Top = [NSMutableArray arrayWithObjects:menu_Top_FirstTop, menu_Top_Remind,menu_Set_Appointment, menu_Top_WaitPay,menu_Top_WaitConfirm,menu_Top_Appraise, nil];
    /*
     menu_Top = [NSMutableArray arrayWithObjects:menu_Top_FirstTop, nil];
     if (CUS_REMINDCOUNT != 0) {
     [menu_Top addObject:menu_Top_Remind];
     }
     if (CUS_PAYCOUNT != 0) {
     [menu_Top addObject:menu_Top_WaitPay];
     }
     if (CUS_CONFIRMCOUNT != 0) {
     [menu_Top addObject:menu_Top_WaitConfirm];
     }*/
    
    //-------信息查询group-------
    MenuDoc *menu_Info_Ecard  = [[MenuDoc alloc] initWithMenuName:@"e账户" Image:[UIImage imageNamed:@"MenuIcon7-eCard"] View:@"PayAndRechargeNavigation1"];
    //    MenuDoc *menu_Info_Ecard  = [[MenuDoc alloc] initWithMenuName:@"e卡" Image:[UIImage imageNamed:@"MenuIcon7-eCard"] View:@"PayAndRechargeNavigation"];
    //MenuDoc *menu_Info_Payment  = [[MenuDoc alloc] initWithMenuName:@"支付记录" Image:[UIImage imageNamed:@"MenuIcon18-paymentHistory"] View:@"PaymentHistoryNavigation"];
    MenuDoc *menu_Info_Order  = [[MenuDoc alloc] initWithMenuName:@"订单" Image:[UIImage imageNamed:@"MenuIcon6-order"] View:@"OrderListNavigation"];
    MenuDoc *menu_Info_Photo  = [[MenuDoc alloc] initWithMenuName:@"相册" Image:[UIImage imageNamed:@"MenuIcon10-photo"] View:@"PhotosNavigation"];
    MenuDoc *menu_Set_Record  = [[MenuDoc alloc] initWithMenuName:@"专业" Image:[UIImage imageNamed:@"MenuIcon8-record"] View:@"RecordListNavigation"]; //咨询记录
    
    //    NSRange range  = [[NSString stringWithFormat:@"%@", CUS_ADVANCED] rangeOfString:@"|1|"];
    //    if (range.length > 0)
    _menu_Info = [NSMutableArray arrayWithObjects:menu_Info_Ecard, menu_Info_Order,menu_Set_Record,  menu_Info_Photo, nil];
    //    else
    //        _menu_Info = [NSMutableArray arrayWithObjects:menu_Info_Ecard, menu_Info_Order, /*menu_Info_Payment, */  menu_Info_Photo, nil];
    //-------咨询联系group-------
    MenuDoc *menu_Business_Business  = [[MenuDoc alloc] initWithMenuName:CUS_COMPANYABBREVIATION Image:[UIImage imageNamed:@"MenuIcon2-business"] View:@"BusinessInfoViewController"];
    MenuDoc *menu_Business_Ctalk = [[MenuDoc alloc] initWithMenuName:@"飞语" Image:[UIImage imageNamed:@"MenuIcon9-cTalk"] View:@"ChatNavigation"];
    _menu_Business = [NSMutableArray arrayWithObjects:menu_Business_Business, menu_Business_Ctalk, nil];
    
    //-------购买group-------
    MenuDoc *menu_Buy_Promotion  = [[MenuDoc alloc] initWithMenuName:@"促销" Image:[UIImage imageNamed:@"MenuIcon14-promotion"] View:@"PtomotionNavigation"];
    MenuDoc *menu_Buy_Product  = [[MenuDoc alloc] initWithMenuName:@"商城" Image:[UIImage imageNamed:@"MenuIcon4-product"] View:@"CommodityNavigation"];
    MenuDoc *menu_Buy_Shoppcart  = [[MenuDoc alloc] initWithMenuName:@"购物车" Image:[UIImage imageNamed:@"MenuIcon5-shoppcart"] View:@"ShoppingCartNavigation"];
    MenuDoc *menu_Buy_Service  = [[MenuDoc alloc] initWithMenuName:@"服务" Image:[UIImage imageNamed:@"MenuIcon18-service"] View:@"ServiceNavigation"];
    MenuDoc *menu_Buy_Collect  = [[MenuDoc alloc] initWithMenuName:@"收藏" Image:[UIImage imageNamed:@"MenuIconCollect"] View:@"CollectNavigation"];
    //    MenuDoc *menu_Set_Collect  = [[MenuDoc alloc] initWithMenuName:@"收藏" Image:[UIImage imageNamed:@"MenuIcon8-record"] View:@"CollectList_ViewController"];
    
    //    if (CUS_PROMOTIONCOUNT == 0) {
    //        _menu_Buy = [NSMutableArray arrayWithObjects:menu_Buy_Product, menu_Buy_Shoppcart,menu_Buy_Service,nil];
    //    } else {
    //    _menu_Buy = [NSMutableArray arrayWithObjects:menu_Buy_Promotion, menu_Buy_Product, menu_Buy_Shoppcart, menu_Buy_Service,nil];
    _menu_Buy = [NSMutableArray arrayWithObjects:menu_Buy_Promotion, menu_Buy_Product, menu_Buy_Service,menu_Buy_Collect,menu_Buy_Shoppcart,nil];
    //    }
    
    //-------其他group-------
    
    MenuDoc *menu_Set_Set = [[MenuDoc alloc] initWithMenuName:@"设置" Image:[UIImage imageNamed:@"MenuIcon11-set"] View:@"SettingNavigation"];
    
    _menu_Set = [NSMutableArray arrayWithObjects:menu_Set_Set, nil];
    
    
    _myListView.backgroundColor = kDefaultBackgroundColor;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化头像和名字
    UIImageView *view = [[UIImageView alloc]init];
    if((IOS7 || IOS8))
        [view setFrame:CGRectMake(160 ,22 , 160, 77)];
    else{
        [view setFrame:CGRectMake(167.5, 2, 144, 77)];
        view.layer.cornerRadius = 10.f;
        view.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1.f].CGColor;
        view.layer.masksToBounds = YES;
        view.layer.borderWidth = 1.25f;
        view.clipsToBounds = YES;
    }
    view.userInteractionEnabled = YES;
    view.backgroundColor = [UIColor whiteColor];
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 60, 60)];
    _accountNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(73, 7, 80, 23)];
    _accountNameLabel.textAlignment = NSTextAlignmentLeft;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = CGRectGetHeight(_headImageView.bounds) / 2;
    _headImageView.layer.borderColor = [kColor_TitlePink CGColor];
    _headImageView.layer.borderWidth = 1.0f;
    
    [_accountNameLabel setFont:kFont_Light_16];
    NSString *account_ImageURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_HEADIMAGE"];
    NSString *account_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_SELFNAME"];
    [_headImageView setImageWithURL:[NSURL URLWithString:account_ImageURL] placeholderImage:[UIImage imageNamed:@"People-default"]];
    [_accountNameLabel setText:account_Name];
    _accountNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    UIView *lineView = [[UIView alloc]init];
    if((IOS7 || IOS8)){
        [lineView setFrame:CGRectMake(0, 77, 160, .5)];
        lineView.backgroundColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1.f];
    }
    [view addSubview:_headImageView];
    [view addSubview:_accountNameLabel];
    
    //二维码
    codeButton = [UIButton buttonWithTitle:nil target:self selector:@selector(CodeShow:) frame:CGRectMake(93, 35 , 30, 30) backgroundImg:[UIImage imageNamed:@"twoCode1"] highlightedImage:nil];
    [view addSubview:codeButton];
    TwoDimensionalCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(93, 35 , 30, 30)];
    [view addSubview:TwoDimensionalCodeImageView];
    
    if((IOS7 || IOS8))
        [view addSubview:lineView];
    [self.view addSubview:view];
    
    if ((IOS7 || IOS8)) {
        UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
        [stateView setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:stateView];
        [_myListView setFrame:CGRectMake(160.0f, 77 + 20.0f, 160.0f, kSCREN_BOUNDS.size.height - 60.f)];
    } else {
        [_myListView setFrame:CGRectMake(160.0f, 77 + 4.f, 160.0f, kSCREN_BOUNDS.size.height - 60.f)];
    }

    _myListView.separatorColor = kTableView_LineColor;
    _myListView.backgroundView = nil;
    _myListView.showsHorizontalScrollIndicator = NO;
    _myListView.showsVerticalScrollIndicator = NO;
     
    [self.slidingViewController setAnchorLeftRevealAmount:160.0f];
    self.slidingViewController.underRightWidthLayout = ECFullWidth;
}


-(void)viewWillAppear:(BOOL)animated
{
    NSString *account_ImageURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_HEADIMAGE"];
    [_accountNameLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_SELFNAME"]];
    [_headImageView setImageWithURL:[NSURL URLWithString:account_ImageURL] placeholderImage:[UIImage imageNamed:@"People-default"]];
    
    [self.myListView reloadData];
    [self requestMenuCount];
    [self requestTwoDimensionalCode];
}


-(void)CodeShow:(UIButton *)sender
{
    UIImage *image = imageViewL.image;
    if (!image) return;
    window = [UIApplication sharedApplication].keyWindow;
    goBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    defaultRect = [TwoDimensionalCodeImageView convertRect:TwoDimensionalCodeImageView.bounds toView:window];//关键代码，坐标系转换
    goBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
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

- (void)viewDidUnload
{
    [self setMyListView:nil];
    [super viewDidUnload];
}

 

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    switch (sectionIndex) {
        case 0: return _menu_Top.count;
        case 1: return _menu_Info.count;
        case 2: return _menu_Business.count;
        case 3: return _menu_Buy.count;
        case 4: return _menu_Set.count;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        NSString *cellIdentifier = @"menuCell";
        __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        MenuDoc *MenuItem = [self.menu_Top objectAtIndex:indexPath.row];
        cell.imageView.image = MenuItem.Image;
        cell.textLabel.text = MenuItem.MenuName;
        cell.textLabel.font = kFont_Light_16;
        
        [[cell.contentView viewWithTag:1000] removeFromSuperview];
        [[cell.contentView viewWithTag:1001] removeFromSuperview];
        
        UILabel *cartCountLabel = [[UILabel alloc] init];
        cartCountLabel.textColor = [UIColor whiteColor];
        [cartCountLabel setTextAlignment:NSTextAlignmentCenter];
        [cartCountLabel setBackgroundColor:[UIColor clearColor]];
        [cartCountLabel setFont:kFont_Number_Menu_12];
        cartCountLabel.tag = 1000;
        
        UIImageView *cartCountImage = [[UIImageView alloc] init];
        cartCountImage.image = [UIImage imageNamed:@"remindBackground"];
        cartCountImage.tag = 1001;
        
        if ((IOS7 || IOS8)) {
            [cartCountLabel setFrame:CGRectMake(130.0f, 13.0f, 18.0f, 16.5f)];
            [cartCountImage setFrame:CGRectMake(130.0f, 12.0f, 18.0f, 16.5f)];
        } else {
            [cartCountLabel setFrame:CGRectMake(110.0f, 12.0f, 18.0f, 16.5f)];
            [cartCountImage setFrame:CGRectMake(110.0f, 11.0f, 18.0f, 16.5f)];
        }
        
        if (indexPath.row == 1) {
            if (_remindCount != 0) {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
                [cell.contentView addSubview:cartCountImage];
                [cell.contentView addSubview:cartCountLabel];
                if (_remindCount > 99) {
                    [cartCountLabel setText:[NSString stringWithFormat:@"n"]];
                } else {
                    [cartCountLabel setText:[NSString stringWithFormat:@"%ld", (long)_remindCount]];
                }
            } else {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
            }
        }
        if (indexPath.row == 3) {
            if (_payCount != 0) {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
                [cell.contentView addSubview:cartCountImage];
                [cell.contentView addSubview:cartCountLabel];
                if (_payCount > 99) {
                    [cartCountLabel setText:[NSString stringWithFormat:@"n"]];
                } else {
                    [cartCountLabel setText:[NSString stringWithFormat:@"%ld", (long)_payCount]];
                }
            } else {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
            }
        }
        if (indexPath.row == 4) {
            if (_confirmCount != 0) {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
                [cell.contentView addSubview:cartCountImage];
                [cell.contentView addSubview:cartCountLabel];
                if (_confirmCount > 99) {
                    [cartCountLabel setText:[NSString stringWithFormat:@"n"]];
                } else {
                    [cartCountLabel setText:[NSString stringWithFormat:@"%ld", (long)_confirmCount]];
                }
            } else {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
            }
        }
//        if (indexPath.row == 4) {
//            if (_remindCount != 0) {
//                [[cell.contentView viewWithTag:1000] removeFromSuperview];
//                [[cell.contentView viewWithTag:1001] removeFromSuperview];
//                [cell.contentView addSubview:cartCountImage];
//                [cell.contentView addSubview:cartCountLabel];
//                if (_remindCount > 99) {
//                    [cartCountLabel setText:[NSString stringWithFormat:@"n"]];
//                } else {
//                    [cartCountLabel setText:[NSString stringWithFormat:@"%ld", (long)_remindCount]];
//                }
//            } else {
//               
//            }
//            [[cell.contentView viewWithTag:1000] removeFromSuperview];
//            [[cell.contentView viewWithTag:1001] removeFromSuperview];
//        }

        
        if (IOS6) {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        return cell;
    } else if(indexPath.section == 1) {
        NSString *cellIdentifier = @"menuCell";
        __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        MenuDoc *MenuItem = [self.menu_Info objectAtIndex:indexPath.row];
        cell.imageView.image = MenuItem.Image;
        cell.textLabel.text = MenuItem.MenuName;
        cell.textLabel.font = kFont_Light_16;
        
        [[cell.contentView viewWithTag:1000] removeFromSuperview];
        [[cell.contentView viewWithTag:1001] removeFromSuperview];
        
        if (IOS6) {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        return cell;
    } else if(indexPath.section == 2) {
        NSString *cellIdentifier = @"menuCell";
        __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        MenuDoc *MenuItem = [self.menu_Business objectAtIndex:indexPath.row];
        cell.imageView.image = MenuItem.Image;
        cell.textLabel.text = MenuItem.MenuName;
        cell.textLabel.font = kFont_Light_16;
        
        [[cell.contentView viewWithTag:1000] removeFromSuperview];
        [[cell.contentView viewWithTag:1001] removeFromSuperview];
        
        UILabel *cartCountLabel = [[UILabel alloc] init];
        cartCountLabel.textColor = [UIColor whiteColor];
        [cartCountLabel setTextAlignment:NSTextAlignmentCenter];
        [cartCountLabel setBackgroundColor:[UIColor clearColor]];
        [cartCountLabel setFont:kFont_Number_Menu_12];
        cartCountLabel.tag = 1000;
        
        UIImageView *cartCountImage = [[UIImageView alloc] init];
        cartCountImage.image = [UIImage imageNamed:@"remindBackground"];
        cartCountImage.tag = 1001;
        
        if ((IOS7 || IOS8)) {
            [cartCountLabel setFrame:CGRectMake(130.0f, 13.0f, 18.0f, 16.5f)];
            [cartCountImage setFrame:CGRectMake(130.0f, 12.0f, 18.0f, 16.5f)];
        } else {
            [cartCountLabel setFrame:CGRectMake(110.0f, 12.0f, 18.0f, 16.5f)];
            [cartCountImage setFrame:CGRectMake(110.0f, 11.0f, 18.0f, 16.5f)];
        }
        
        if (indexPath.row == 1) {
            if (_messageCount != 0) {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
                [cell.contentView addSubview:cartCountImage];
                [cell.contentView addSubview:cartCountLabel];
                if (_messageCount > 99) {
                    [cartCountLabel setText:[NSString stringWithFormat:@"n"]];
                } else {
                    [cartCountLabel setText:[NSString stringWithFormat:@"%ld", (long)_messageCount]];
                }
            } else {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
            }
        }
        
        if (IOS6) {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        return cell;
    } else if(indexPath.section == 3) {
        NSString *cellIdentifier = @"menuCell";
        __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        MenuDoc *MenuItem = [self.menu_Buy objectAtIndex:indexPath.row];
        cell.imageView.image = MenuItem.Image;
        cell.textLabel.text = MenuItem.MenuName;
        cell.textLabel.font = kFont_Light_16;
        
        [[cell.contentView viewWithTag:1000] removeFromSuperview];
        [[cell.contentView viewWithTag:1001] removeFromSuperview];
        
        UILabel *cartCountLabel = [[UILabel alloc] init];
        cartCountLabel.textColor = [UIColor whiteColor];
        [cartCountLabel setTextAlignment:NSTextAlignmentCenter];
        [cartCountLabel setBackgroundColor:[UIColor clearColor]];
        [cartCountLabel setFont:kFont_Number_Menu_12];
        cartCountLabel.tag = 1000;
        
        UIImageView *cartCountImage = [[UIImageView alloc] init];
        cartCountImage.image = [UIImage imageNamed:@"remindBackground"];
        cartCountImage.tag = 1001;
        
        if ((IOS7 || IOS8)) {
            [cartCountLabel setFrame:CGRectMake(130.0f, 13.0f, 18.0f, 16.5f)];
            [cartCountImage setFrame:CGRectMake(130.0f, 12.0f, 18.0f, 16.5f)];
        } else {
            [cartCountLabel setFrame:CGRectMake(110.0f, 12.0f, 18.0f, 16.5f)];
            [cartCountImage setFrame:CGRectMake(110.0f, 11.0f, 18.0f, 16.5f)];
        }
        
        if (indexPath.row == 4) {
            if (_cartCount != 0) {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
                [cell.contentView addSubview:cartCountImage];
                [cell.contentView addSubview:cartCountLabel];
                if (_cartCount > 99) {
                    [cartCountLabel setText:[NSString stringWithFormat:@"n"]];
                } else {
                    [cartCountLabel setText:[NSString stringWithFormat:@"%ld", (long)_cartCount]];
                }
            } else {
                [[cell.contentView viewWithTag:1000] removeFromSuperview];
                [[cell.contentView viewWithTag:1001] removeFromSuperview];
            }
        }
        
        if (IOS6) {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        return cell;
    } else if(indexPath.section == 4) {
        NSString *cellIdentifier = @"menuCell";
        __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        MenuDoc *MenuItem = [self.menu_Set objectAtIndex:indexPath.row];
        cell.imageView.image = MenuItem.Image;
        cell.textLabel.text = MenuItem.MenuName;
        cell.textLabel.font = kFont_Light_16;
        
        [[cell.contentView viewWithTag:1000] removeFromSuperview];
        [[cell.contentView viewWithTag:1001] removeFromSuperview];
        
        if (IOS6) {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_myListView deselectRowAtIndexPath:indexPath animated:YES];
    MenuDoc *MenuItem;
    switch (indexPath.section) {
            // case 0: return;
        case 0: MenuItem = [self.menu_Top objectAtIndex:indexPath.row];break;
        case 1: MenuItem = [self.menu_Info objectAtIndex:indexPath.row];break;
        case 2: MenuItem = [self.menu_Business objectAtIndex:indexPath.row];break;
        case 3: MenuItem = [self.menu_Buy objectAtIndex:indexPath.row];break;
        case 4: MenuItem = [self.menu_Set objectAtIndex:indexPath.row];break;
        default: return ;
    }
    
    NSString *identifier = MenuItem.View;
    NSInteger target = 1;
    
    if(/*_promotionCount != 0 && */[identifier isEqualToString:@"FirstTopNavigation"]){
        target = 0;
        identifier = @"PtomotionNavigation";
    }
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    if([identifier isEqualToString:@"PtomotionNavigation"]){
        ((SalesPromotionNewViewController*)[newTopViewController.childViewControllers objectAtIndex:0]).promotionSource = target;
    }
    [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (indexPath.section == 0 && indexPath.row == 0) {
    //        return kTableView_HeightOfRow * 2;
    //    } else {
    return kTableView_HeightOfRow;
    //  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if((IOS7 || IOS8))
            return 15;
        else
            return 11;
    } else {
        return 2;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //    if (section == 0) {报表     //        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.1)];
    //        [view setBackgroundColor:[UIColor clearColor]];
    //        return view;
    //    } else {
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 2)];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
    // }
}

#pragma mark - 接口

- (void)requestMenuCount
{
    _getCartCountOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/customer/getCartAndNewMessageCount"  showErrorMsg:YES  parameters:nil WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _cartCount = [data[@"CartCount"] integerValue];
            _messageCount = [data[@"NewMessageCount"] integerValue];
            _promotionCount = [data[@"PromotionCount"] integerValue];
            _remindCount = [data[@"RemindCount"] integerValue];
            _payCount = [data[@"UnpaidOrderCount"] integerValue];
            _confirmCount = [data[@"UnconfirmedOrderCount"] integerValue];
//            _reviewCount = [data[@"UnconfirmedOrderCount"] integerValue];
            [[NSUserDefaults standardUserDefaults] setObject:@(_promotionCount) forKey:@"CUSTOMER_PROMOTION"];
            [_myListView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

-(void)requestTwoDimensionalCode
{
    NSDictionary *para = @{@"Code":@(CUS_CUSTOMERID),
                           @"Type":@0,
                           @"CompanyCode":CUS_COMPANYCODE,
                           @"QRCodeSize":@9};
    
    _getTwoDimensionalCodeOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/WebUtility/GetQRCode"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (data){
                
                twoDimensionalCodeURL = data;
                imageViewL = [[UIImageView alloc] init];
                [imageViewL setImageWithURL:[NSURL URLWithString:[twoDimensionalCodeURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@""]];
            }
            else
                [SVProgressHUD showErrorWithStatus2:@"获取二维码失败！"];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}



@end
