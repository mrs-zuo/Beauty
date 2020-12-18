//
//  ServiceDetailViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-6-20.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ServiceDetailViewController.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "UIButton+InitButton.h"
#import "UIImageView+WebCache.h"
#import "ServiceObject.h"
#import "ZWJson.h"
#import "AppointmenCreat_ViewController.h"
#import "AppointmentDoc.h"
#import "OrderEditViewController.h"
#import "OrderDoc.h"
#import "PayInfo_ViewController.h"
#import "ShoppingCartViewController.h"
#import "SJAvatarBrowser.h"


@interface ServiceDetailViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestDetailProductInfoOpeartion;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddServiceToCartOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddFavorteOperation;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *nameTitleArray;
@property (strong, nonatomic) NSMutableArray *priceTitleArray;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong ,nonatomic) UIButton *collect_Button;

@property (retain, nonatomic) ServiceObject *CDVCService;
@property (strong , nonatomic)OrderDoc *orderDoc;
@property (strong,nonatomic) NSString * FavoriteID;
@property (assign ,nonatomic) BOOL isCollect;
@end

@implementation ServiceDetailViewController
@synthesize commodityCode;
@synthesize titleArray;
@synthesize nameTitleArray;
@synthesize priceTitleArray;
@synthesize scrollView;
@synthesize pageControl;
@synthesize orderDoc;
@synthesize collect_Button;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = kDefaultBackgroundColor;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestDetailProductInfoByJson];
    
    titleArray = [NSMutableArray arrayWithObjects:@"image", @"name", @"price",@"describe",@"branch" ,nil]; //modified by zhangwei 201.7.9
    nameTitleArray = [NSMutableArray arrayWithObjects:@"name", @"nameDetail", @"spendTime",@"courseFrequency", nil];
    priceTitleArray = [NSMutableArray arrayWithObjects:@"price", @"time",nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestDetailProductInfoOpeartion || [_requestDetailProductInfoOpeartion isExecuting]) {
        [_requestDetailProductInfoOpeartion cancel];
        _requestDetailProductInfoOpeartion = nil;
    }
    //add by zhangwei 2014.7.9
    //    if (_requestAddServiceToCartOperation || [_requestAddServiceToCartOperation isExecuting]) {
    //        [_requestAddServiceToCartOperation cancel];
    //        _requestAddServiceToCartOperation = nil;
    //    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
- (void)viewDidLoad
{
    self.isShowButton = YES;
    [super viewDidLoad];
    self.title = @"服务详情";
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.allowsSelection = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorColor = kTableView_LineColor;

    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 49 - kNavigationBar_Height + 20);
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 20, 140)];
    } else {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 20, 140)];
    }
    
    
    [self initButton];
}


-(void)initButton
{
    UIButton *appointment_Button = [UIButton buttonWithTitle:@""
                                                      target:self
                                                    selector:@selector(selectAction:)
                                                       frame:CGRectMake(10, 10, 30, 30)
                                               backgroundImg:[UIImage imageNamed:@"appointmentBtnImg"]
                                            highlightedImage:nil];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(52, 0, 0.5f, 49)];
    lineView.backgroundColor = [UIColor lightGrayColor];

    
    
     collect_Button = [UIButton buttonWithTitle:@""
                                                  target:self
                                                selector:@selector(selectAction:)
                                                   frame:CGRectMake(52 + 10 + 2, 10, 30, 30)
                                           backgroundImg:[UIImage imageNamed:@"productCollection"]
                                        highlightedImage:nil];
    [collect_Button setBackgroundImage:[UIImage imageNamed:@"productCollection_solid"]  forState:UIControlStateSelected];
    UIButton * viewButton = [UIButton buttonWithTitle:@""
                                               target:self
                                             selector:@selector(selectAction:)
                                                frame:CGRectMake(53.0f, 0.0f, 52.0f, 49.0f)
                                        backgroundImg:nil
                                     highlightedImage:nil];
    viewButton.backgroundColor = kColor_Clear;
    
    UIButton *add_Button = [UIButton buttonWithTitle:@"加入购物车"
                                              target:self
                                            selector:@selector(selectAction:)
                                               frame:CGRectMake(106.0f, 0.0f, 107.0f, 49.0f)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    [add_Button.titleLabel setFont:kFont_Light_14];
    
    
    UIButton *buy_Button = [UIButton buttonWithTitle:@"立即购买"
                                              target:self
                                            selector:@selector(selectAction:)
                                               frame:CGRectMake(213.0f, 0.0f, 107.0f, 49.0f)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    [buy_Button.titleLabel setFont:kFont_Light_14];

    appointment_Button.tag = 0;
    viewButton.tag = 1;
    add_Button.tag = 2;
    buy_Button.tag = 3;
    
    appointment_Button.backgroundColor = kColor_White;
    add_Button.backgroundColor = [UIColor colorWithRed:130/255. green:108/255. blue:86/255. alpha:1.];
    buy_Button.backgroundColor = [UIColor colorWithRed:107/255. green:91/255. blue:72/255. alpha:1.];
    
    [appointment_Button setTitleColor:kColor_Black forState:UIControlStateNormal];
    [collect_Button setTitleColor:kColor_Black forState:UIControlStateNormal];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, 320.0f, 49.0f)];
    footView.backgroundColor = kColor_White;
    
    [self.view addSubview:footView];
    

    
    [footView addSubview:appointment_Button];
    [footView addSubview:add_Button];
    [footView addSubview:buy_Button];
    [footView addSubview:collect_Button];
    [footView addSubview:lineView];
    [footView addSubview:viewButton];
}

- (void)selectAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
        {
            if (_CDVCService.product_selectedIndex == 0) {
                [SVProgressHUD showSuccessWithStatus2:@"请选择服务门店"];
                return;
            }else {
                AppointmenCreat_ViewController * create = [[AppointmenCreat_ViewController alloc] init];
                create.BranchID = [[_CDVCService.product_soldBranch objectAtIndex:(_CDVCService.product_selectedIndex - 1)] product_branchId];
                create.branchName =  [[_CDVCService.product_soldBranch objectAtIndex:(_CDVCService.product_selectedIndex - 1)] product_branchName];
                create.serviceCode = self.commodityCode;
                create.serviceName = _CDVCService.product_name;
                create.ReservedOrderType = 2 ;
                create.taskSourceType = 1;
                create.viewTag = 2 ;
                self.hidesBottomBarWhenPushed=true;
                [self.navigationController pushViewController:create animated:YES];
            }
        }
            break;
        case 1://收藏
        {
            if (!self.isCollect) {
                
                [self requestAddFavorte];
                
            }else
            {
                //取消收藏
                [self CancelCollect];
            }
            
            
        }
            break;
        case 2:
        {
            NSInteger isAvaible = NO;
            for (ProductSold *obj in _CDVCService.product_soldBranch) {
                if (!(obj.product_storageType == 1 && obj.product_quantity <= 0))
                    isAvaible = YES;
            }
            if (!isAvaible){
                [SVProgressHUD showErrorWithStatus2:@"对不起，暂无库存"];
                return;
            }
            
            if (_CDVCService.product_selectedIndex <= 0) {
                [SVProgressHUD showErrorWithStatus2:@"请选择购买商品的门店"];
                return;
            }
            [self requestAddServerToCart:1];
        }
            break;
        case 3:
        {
            NSInteger isAvaible = NO;
            for (ProductSold *obj in _CDVCService.product_soldBranch) {
                if (!(obj.product_storageType == 1 && obj.product_quantity <= 0))
                    isAvaible = YES;
            }
            if (!isAvaible){
                [SVProgressHUD showErrorWithStatus2:@"对不起，暂无库存"];
                return;
            }
            
            if (_CDVCService.product_selectedIndex <= 0) {
                [SVProgressHUD showErrorWithStatus2:@"请选择购买商品的门店"];
                return;
            }
            [self requestAddServerToCart:10];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = floor((self.scrollView.contentOffset.x)/300) + 1 ;
    pageControl.currentPage = page;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [titleArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *titleStr = [titleArray objectAtIndex:section];
    if ([titleStr isEqualToString:@"image"] || [titleStr isEqualToString:@"note"]) { //modified by zhangwei 201.7.9
        return 1;
    } else if ([titleStr isEqualToString:@"name"]) {
        if(_CDVCService.service_hasSubService)
            return _CDVCService.service_subService.count + 2;
        else
            return nameTitleArray.count;
        
    } else if ([titleStr isEqualToString:@"price"]) {
        if(_CDVCService.service_haveExpiration)
            return  priceTitleArray.count;
        else
            return priceTitleArray.count-1;
    } else if ([titleStr isEqualToString:@"describe"]) {
        return 2;
    } else if ([titleStr isEqualToString:@"branch"]) {
        return _CDVCService.product_soldBranch.count == 0 ? 0 : _CDVCService.product_soldBranch.count + 1;
    } else {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"image"]){
        return 140.0f;
    } else if ([titleStr isEqualToString:@"name"]){
        if(_CDVCService.service_hasSubService)
            return kTableView_DefaultCellHeight;
        else {
            NSString *nameTitleStr = [nameTitleArray objectAtIndex:indexPath.row];
            if ([nameTitleStr isEqualToString:@"name"]) {
                return kTableView_DefaultCellHeight;
            } else if ([nameTitleStr isEqualToString:@"nameDetail"]){
                return kTableView_DefaultCellHeight;
            } else if ([nameTitleStr isEqualToString:@"spendTime"]) {
                return kTableView_DefaultCellHeight;
            } else if ([nameTitleStr isEqualToString:@"courseFrequency"]) {
                return kTableView_DefaultCellHeight;
            }
        }
    } else if ([titleStr isEqualToString:@"price"]){
        NSString *priceTitleStr = [priceTitleArray objectAtIndex:indexPath.row];
        if ([priceTitleStr isEqualToString:@"price"]) {
            return kTableView_DefaultCellHeight;
        }
        if ([priceTitleStr isEqualToString:@"memberPrice"]) {
            return kTableView_DefaultCellHeight;
        }
    } else if ([titleStr isEqualToString:@"describe"]){
        if (indexPath.row == 0) {
            return kTableView_DefaultCellHeight;
        } else if (indexPath.row == 1) {
            CGRect tempRect = [_CDVCService.product_describe boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
            CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
            if (lines > 1) {
                return tempRect.size.height + (lines * 5)-10;
            }else {
                return kTableView_DefaultCellHeight;
            }
        }
    } else if ([titleStr isEqualToString:@"note"]){ //add by zhangwei 2014.7.9
        return 54.f;
    }
    return kTableView_DefaultCellHeight;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"image"]){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DisplayPicCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DisplayPicCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (scrollView != nil) {
            [scrollView removeFromSuperview];
        }
        scrollView.directionalLockEnabled = YES; //只能一个方向滑动
        scrollView.pagingEnabled = YES; //是否翻页
        scrollView.showsVerticalScrollIndicator =NO;
        scrollView.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
        scrollView.delegate = self;
        CGSize newSize = CGSizeMake(300 * [_CDVCService.product_pictureURLArray count], 140);
        [scrollView setContentSize:newSize];
        
        for (int i = 0 ; i<[_CDVCService.product_pictureURLArray count];i++){
            UIImageView *imageView = [[UIImageView alloc] init];

            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
            tap.delegate = self;
            imageView.tag = i  + 100;
            [imageView addGestureRecognizer:tap];
            
            imageView.userInteractionEnabled = YES;
            [imageView setImageWithURL:[NSURL URLWithString:[_CDVCService.product_pictureURLArray objectAtIndex:i]]];
            [imageView setFrame:CGRectMake(300 * i + 86, 2, 135, 135)];
            [scrollView addSubview:imageView];
        }
        
        pageControl =[[UIPageControl alloc] initWithFrame:CGRectMake(0,300,300,140)];
        pageControl.backgroundColor =[UIColor clearColor];
        pageControl.numberOfPages = [_CDVCService.product_pictureURLArray count];
        pageControl.currentPage = 0;
        [scrollView addSubview:pageControl];
        [cell.contentView addSubview:scrollView];
        return cell;
    } else if ([titleStr isEqualToString:@"name"]){
        if(_CDVCService.service_hasSubService){
            if(indexPath.row <= 1){
                NSString *nameTitleStr = [nameTitleArray objectAtIndex:indexPath.row];
                if ([nameTitleStr isEqualToString:@"name"]) {
                    NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
                    [cell.titleLabel setText:@"名称"];
                    [cell.valueText setText:@""];
                    [cell setAccessoryText:@""];
                    return cell;
                } else if ([nameTitleStr isEqualToString:@"nameDetail"]){
                    ContentEditCell *cell = [self configContentEditCell:tableView indexPath:indexPath];
                    cell.contentEditText.text = _CDVCService.product_name;
                    
                    CGRect rect = cell.contentEditText.frame;
                    rect.size.height = [_CDVCService valuationProductNameHeightWithFont:kFont_Light_16] + 20.0f;
                    cell.contentEditText.frame = rect;
                    return cell;
                }
            } else {
                NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
                SubServiceObject *subService = [_CDVCService.service_subService objectAtIndex:indexPath.row - 2];
                [cell.titleLabel setText:subService.service_subServiceName];
                [cell.valueText setText:[NSString stringWithFormat:@"%ld分钟",(long)subService.service_subServiceTime]];
                [cell setAccessoryText:@""];
                
                CGRect rect = cell.titleLabel.frame;
                rect.origin.x = 25;
                cell.titleLabel.frame = rect;
                cell.titleLabel.textColor = kColor_Black;
                return cell;
            }
        }else{
            NSString *nameTitleStr = [nameTitleArray objectAtIndex:indexPath.row];
            if ([nameTitleStr isEqualToString:@"name"]) {
                NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
                [cell.titleLabel setText:@"名称"];
                [cell.valueText setText:@""];
                [cell setAccessoryText:@""];
                return cell;
            } else if ([nameTitleStr isEqualToString:@"nameDetail"]){
                ContentEditCell *cell = [self configContentEditCell:tableView indexPath:indexPath];
                cell.contentEditText.textColor=kColor_Black;
                cell.contentEditText.text = _CDVCService.product_name;
                
                CGRect rect = cell.contentEditText.frame;
                rect.size.height = [_CDVCService valuationProductNameHeightWithFont:kNormalFont_14] + 20.0f;
                cell.contentEditText.frame = rect;
                return cell;
            } else if ([nameTitleStr isEqualToString:@"spendTime"]) {
                NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
                [cell.titleLabel setText:@"服务时间"];
                CGRect rect = cell.valueText.frame;
                rect.origin.x=140;
                cell.valueText.frame=rect;
                cell.valueText.textColor=kColor_Black;
                [cell.valueText setText:[NSString stringWithFormat:@"%ld%@", (long)_CDVCService.service_spendTime,@"分钟"]];
                //[cell setAccessoryText:@""];
                return cell;
            } else if ([nameTitleStr isEqualToString:@"courseFrequency"]) {
                NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
                [cell.titleLabel setText:@"服务次数"];
                CGRect rect = cell.valueText.frame;
                rect.origin.x=140;
                cell.valueText.frame=rect;
                cell.valueText.textColor=kColor_Black;
                if (_CDVCService.service_courseFrequency == 0) {
                    [cell.valueText setText:[NSString stringWithFormat:@"不限次"]];
                }else
                    [cell.valueText setText:[NSString stringWithFormat:@"%ld次",(long)_CDVCService.service_courseFrequency]];
                //[cell setAccessoryText:@""];
                return cell;
            }
        }
    } else if ([titleStr isEqualToString:@"price"]){
        NSString *priceTitleStr = [priceTitleArray objectAtIndex:indexPath.row];
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        [cell.titleLabel setText:@""];
        [cell.valueText setText:@""];
        [cell setAccessoryText:@""];
        
        if ([priceTitleStr isEqualToString:@"price"]) {
            cell.titleLabel.text = @"单价";
            CGRect rect = cell.valueText.frame;
            rect.origin.x=150;
            cell.valueText.frame=rect;
            cell.valueText.textColor=kColor_Black;
            cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , _CDVCService.product_originalPrice];
            
        }
        if ([priceTitleStr isEqualToString:@"memberPrice"]) {
            if (_CDVCService.product_sellingWay == GPProductSellingWayDiscountPrice) {
                cell.titleLabel.text = @"折扣价";
                cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , _commodityDiscount];
            } else if(_CDVCService.product_sellingWay == GPProductSellingWayPromotionPrice){
                cell.titleLabel.text = @"促销价";
                cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN , _CDVCService.product_salesPrice];
            }
        }
        else if ([priceTitleStr isEqualToString:@"time"]){
            NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
            [cell.titleLabel setText:@"有效期"];
            CGRect rect = cell.valueText.frame;
            rect.origin.x=150;
            cell.valueText.frame=rect;
            [cell.valueText setText:[_CDVCService.product_expirationDate integerValue] ==0 ?@"当天有效":[NSString stringWithFormat:@"%@天",_CDVCService.product_expirationDate]];
            [cell setAccessoryText:@""];
            return cell;
        }
        return cell;
    }else if ([titleStr isEqualToString:@"describe"]){
        if (indexPath.row == 0) {
            NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
            [cell.titleLabel setText:@"介绍"];
            [cell.valueText setText:@""];
            [cell setAccessoryText:@""];
            return cell;
        } else if (indexPath.row == 1) {
            NSString *reuseidentifier = [NSString stringWithFormat:@"cell%@",indexPath];
            UITableViewCell *cellDes = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
           UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10,-5, kSCREN_BOUNDS.size.width - 20,20)];
           label.tag = 300;
           label.numberOfLines = 0;
           label.textColor = kMainLightGrayColor;
           label.font = kNormalFont_14;
           label.textAlignment = NSTextAlignmentLeft;
           [cellDes.contentView addSubview:label];
            UILabel *deslab = [cellDes.contentView viewWithTag:300];
            CGRect tempRect = [_CDVCService.product_describe  boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
            
            CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
            CGRect rect = deslab.frame;
            rect.size.height = tempRect.size.height + (lines * 5) ;
            deslab.frame = rect;
            if (_CDVCService.product_describe) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_CDVCService.product_describe];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineSpacing  = 5;
                [attributedString setAttributes:@{NSFontAttributeName:kNormalFont_14,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                deslab.attributedText = attributedString;
            }
            return cellDes;
        }
    }
    else if ([titleStr isEqualToString:@"note"]){ //add by zhangwei 2014.7.9
        ContentEditCell *cell = [self configContentEditCell:tableView indexPath:indexPath];
        [cell setContentText:@"温馨提示：如需购买该服务请与您的美丽顾问联系！"];
        cell.contentEditText.textColor = [UIColor colorWithRed:255.0/255.0f green:165.0/255.0f blue:59.f/255.f alpha:1.0f];
        [cell.contentEditText sizeToFit];
        return cell;
        
    } else if ([titleStr isEqualToString:@"branch"])
    {
        NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
        if (indexPath.row == 0){
            [cell.titleLabel setText:@"提供服务门店"];
            [cell.valueText setText:@""];
            [cell setAccessoryText:@""];
            cell.titleLabel.frame = CGRectMake(10, 15, 290, 20);
        }else{
            [cell.titleLabel setText:[[_CDVCService.product_soldBranch objectAtIndex:indexPath.row -1] product_branchName]];
            [cell setAccessoryText:@""];
            cell.titleLabel.textColor = kColor_Black;
            cell.titleLabel.frame = CGRectMake(20, 15, 270, 20);
            
            UIButton *stateButton = (UIButton *)[cell viewWithTag:10000];
            if (!stateButton) {
                stateButton = [UIButton buttonWithTitle:@""
                                                 target:self
                                               selector:@selector(selectBranchAction:)
                                                  frame:CGRectMake(275.0f, 2.f, 36.0f, 36.0f)
                                          backgroundImg:[UIImage imageNamed:@"icon_unSelected"]
                                       highlightedImage:nil];
                [stateButton setBackgroundImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
                [stateButton setBackgroundImage:[UIImage imageNamed:@"icon_Selected"] forState:UIControlStateSelected];
            }
            if (indexPath.row == _CDVCService.product_selectedIndex)
                stateButton.selected = YES;
            else
                stateButton.selected = NO;
            
            stateButton.tag = 10000;
            [cell addSubview:stateButton];
        }
        return cell;
    }
    return nil;
    
}

- (void)selectBranchAction:(UIButton *)sender
{
    UITableViewCell *cell = nil;
    if (IOS6 || IOS8)
        cell = (NormalEditCell *)sender.superview;
    else
        cell = (NormalEditCell *)sender.superview.superview;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSLog(@"old %ld, new %ld",(long)_CDVCService.product_selectedIndex, (long)indexPath.row);
    
    UITableViewCell *oldCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_CDVCService.product_selectedIndex inSection:indexPath.section]];
    ((UIButton *)[oldCell viewWithTag:10000]).selected = NO;
    
    _CDVCService.product_selectedIndex = indexPath.row;
    sender.selected = YES;
}

// 配置NormalEditCell
- (NormalEditCell *)configNormalEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"NormalEditCell";
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.valueText setEnabled:NO];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
    return cell;
}
// 配置ContentEditCell
- (ContentEditCell *)configContentEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"ContentEditCell";
    ContentEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.contentEditText setUserInteractionEnabled:NO];
    return cell;
}
// 配置NormalEditCell
- (NormalEditCell *)configNormalEditCell1:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"NormalEditBranchCell";
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.valueText setEnabled:NO];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
    return cell;
}

- (void)tapImageView:(UIGestureRecognizer *)ges
{
    if ([ges.view isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)ges.view;
       NSString *imageUrl = [_CDVCService.product_pictureURLArray objectAtIndex:imgView.tag - 100];
        NSString *tempUrl = [imageUrl componentsSeparatedByString:@"&"].firstObject;
        UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tempUrl]]];
        [SJAvatarBrowser showImage:imgView img:image];
    }
}
#pragma mark -  手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    //    NSLog(@"%@", NSStringFromClass([touch.view class]));
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}
#pragma mark - 接口
- (void)requestDetailProductInfoByJson
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"ProductCode":[NSNumber numberWithLongLong:commodityCode],
                           @"CustomerID":@(CUS_CUSTOMERID),
                           @"ImageWidth":@160,
                           @"ImageHeight":@160};
    _requestDetailProductInfoOpeartion = [[GPCHTTPClient sharedClient] requestUrlPath:@"/service/getServiceDetailByServiceCode_2_1"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        
        if (!_CDVCService) {
            _CDVCService = [[ServiceObject alloc] init];
        }
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            self.FavoriteID = [data objectForKey:@"FavoriteID"];
            if ([self.FavoriteID isKindOfClass:[NSNull class]] || self.FavoriteID.length == 0) {
                
                self.isCollect = NO;
                collect_Button.selected = NO;
            }else
            {
                self.isCollect = YES;
                collect_Button.selected = YES;
            }
            
            orderDoc = [[OrderDoc alloc]init];
            [orderDoc setProductType:1];
            [orderDoc setOrder_ObjectID:[[data objectForKey:@"CategoryID"] integerValue]];
            [orderDoc setOrder_ID:[[data objectForKey:@"CommodityID"] integerValue]];
            [orderDoc setOrder_Type:0];
            [orderDoc setOrder_TotalPrice:[[data objectForKey:@"PromotionPrice"] doubleValue] ];
            [orderDoc setOrder_TotalSalePrice:[[data objectForKey:@"UnitPrice"] doubleValue]];
            
            
            NSDictionary *dict = @{@"product_code":@"ServiceCode",
                                   @"product_name":@"ServiceName",
                                   @"service_courseFrequency":@"CourseFrequency",
                                   @"service_spendTime":@"SpendTime",
                                   @"product_describe":@"Describe",
                                   @"product_sellingWay":@"MarketingPolicy",
                                   @"product_originalPrice":@"UnitPrice",
                                   @"product_promotionPrice":@"PromotionPrice",
                                   @"product_discountPrice":@"PromotionPrice",
                                   @"product_expirationDate":@"ExpirationDate"
                                   };//折扣价和促销价都取该字段
            
            [_CDVCService assignObjectPropertyWithDictionary:data andObjectPropertyAssociatedDictionary:dict];
            [_CDVCService valuationProductSalesPrice];
            
            NSMutableArray *soldBranch = [NSMutableArray array];
            if (data[@"ProductEnalbeInfo"] != [NSNull null]) {
                for (NSDictionary *obj in data[@"ProductEnalbeInfo"]) {
                    ProductSold *product = [[ProductSold alloc] init];
                    product.product_branchId = [obj[@"BranchID"] integerValue];
                    product.product_branchName = obj[@"BranchName"];
                    [soldBranch addObject:product];
                }
            }
            _CDVCService.product_soldBranch = soldBranch;
            
            //如果只有一个门店则默认勾选
            if (soldBranch.count == 1)
                _CDVCService.product_selectedIndex = 1;
            
            if(data[@"ServiceImage"] != [NSNull null])
                [_CDVCService setProduct_pictureURLArray:data[@"ServiceImage"]];
            
            _CDVCService.service_subService = [NSMutableArray array];
            _CDVCService.service_hasSubService = [data[@"HasSubServices"] boolValue];
            _CDVCService.service_haveExpiration = [data[@"HaveExpiration"] boolValue];
            if(_CDVCService.service_hasSubService){
                NSArray *subServiceArray = data[@"SubServices"];
                if ((NSNull *)subServiceArray == [NSNull null])
                    subServiceArray = nil;
                for (NSDictionary *dict in subServiceArray){
                    SubServiceObject *subService = [[SubServiceObject alloc] init];
                    subService.service_subServiceCode = [dict[@"SubServiceCode"] longLongValue];
                    subService.service_subServiceTime = [dict[@"SpendTime"] integerValue];
                    subService.service_subServiceName = dict[@"SubServiceName"];
                    [_CDVCService.service_subService addObject:subService];
                }
            }
            
            NSMutableArray *deleteArray = [NSMutableArray array];
            if(_CDVCService.product_name.length == 0){
                [deleteArray addObject:[nameTitleArray objectAtIndex:0]];
                [deleteArray addObject:[nameTitleArray objectAtIndex:1]];
            }
            if (_CDVCService.service_spendTime == 0) {
                [deleteArray addObject:[nameTitleArray objectAtIndex:2]];
            }
            if (_CDVCService.service_courseFrequency < 0) {
                [deleteArray addObject:[nameTitleArray objectAtIndex:3]];
            }
            [nameTitleArray removeObjectsInArray:deleteArray];
            [deleteArray removeAllObjects];
            
            if( _CDVCService.product_originalPrice < 0){
                [deleteArray addObject:[priceTitleArray objectAtIndex:0]];
            }
            [priceTitleArray removeObjectsInArray:deleteArray];
            [deleteArray removeAllObjects];
            
            if(_CDVCService.product_pictureURLArray.count == 0){
                [deleteArray addObject:[titleArray objectAtIndex:0]];
            }
            if([nameTitleArray count] == 0){
                [deleteArray addObject:[titleArray objectAtIndex:1]];
            }
            if([priceTitleArray count] == 0){
                [deleteArray addObject:[titleArray objectAtIndex:2]];
            }
            if (_CDVCService.product_describe.length == 0){
                [deleteArray addObject:[titleArray objectAtIndex:3]];
            }
            [titleArray removeObjectsInArray:deleteArray];
            
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}


- (void)requestAddServerToCart:(NSInteger)flag
{
    [SVProgressHUD showWithStatus:@"Loading"];

    NSInteger branchId =  [[_CDVCService.product_soldBranch objectAtIndex:(_CDVCService.product_selectedIndex - 1)] product_branchId];
    NSDictionary  *para = @{@"ProductCode":@((long long)self.commodityCode),
                            @"BranchID":@(branchId),
                            @"ProductType":@0,
                            @"Quantity":@1};
    
    _requestAddServiceToCartOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Cart/AddCart"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
         [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            [SVProgressHUD showSuccessWithStatus2:[message length] > 0 ? message : @"成功添加商品都购物车！"];
            if (flag == 10) {
                self.tabBarController.selectedIndex = 2;
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus2:error];
           
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

-(void)requestFavoriteID
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"ProductCode":[NSNumber numberWithLongLong:commodityCode],
                           @"CustomerID":@(CUS_CUSTOMERID),
                           @"ImageWidth":@160,
                           @"ImageHeight":@160};
    _requestDetailProductInfoOpeartion = [[GPCHTTPClient sharedClient] requestUrlPath:@"/service/getServiceDetailByServiceCode_2_1"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            self.FavoriteID = [data objectForKey:@"FavoriteID"];
            if ([self.FavoriteID isKindOfClass:[NSNull class]] || self.FavoriteID.length == 0) {
                
                self.isCollect = NO;
                collect_Button.selected = NO;
            }else
            {
                self.isCollect = YES;
                 collect_Button.selected = YES;
            }
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)requestAddFavorte
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary  *para = @{@"ProductCode":@((long long)self.commodityCode),
                            @"ProductType":@(0),
                            };
    
    _requestAddFavorteOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Customer/AddFavorite"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            self.isCollect = YES;
             collect_Button.selected = YES;
            [self requestFavoriteID];
            [SVProgressHUD showSuccessWithStatus2:message];
            
        } failure:^(NSInteger code, NSString *error) {
            
            [SVProgressHUD showSuccessWithStatus2:error];
           
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


//取消收藏
- (void)CancelCollect
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary  *para = @{@"UserFavoriteID":self.FavoriteID
                            };
    
    _requestAddFavorteOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Customer/DelFavorite"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            self.isCollect = NO;
             collect_Button.selected = NO;
            [self requestFavoriteID];
            [SVProgressHUD showSuccessWithStatus2:message];

            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus2:error];
            
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    
}


@end
