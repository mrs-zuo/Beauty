//
//  ProductDetailViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-25.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "CommodityDetailViewController.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "UIButton+InitButton.h"
#import "UIImageView+WebCache.h"
#import "ZWJson.h"
#import "CommodityObject.h"
#import <stdlib.h>
#import "OrderEditViewController.h"
#import "PayInfo_ViewController.h"
#import "OrderDoc.h"
#import "ShoppingCartViewController.h"
#import "SJAvatarBrowser.h"


@interface CommodityDetailViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestDetailProductInfoOpeartion;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddCommodityToCartOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddFavorteOperation;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *nameTitleArray;
@property (strong, nonatomic) NSMutableArray *priceTitleArray;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) OrderDoc * orderDoc ;
@property (retain, nonatomic) CommodityObject *CDVCCommodity;
@property (strong ,nonatomic) NSString * FavoriteID;
@property (strong, nonatomic) UIButton *collect_Button;
@property (assign ,nonatomic) BOOL isCollect;
@end

@implementation CommodityDetailViewController
@synthesize commodityCode;
@synthesize titleArray;
@synthesize nameTitleArray;
@synthesize priceTitleArray;
@synthesize scrollView;
@synthesize pageControl;
@synthesize orderDoc;
@synthesize FavoriteID;
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
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self requestDetailProductInfoByJson];
    
    titleArray = [NSMutableArray arrayWithObjects:@"image", @"name", @"price", @"describe",@"branch", nil];//
    nameTitleArray = [NSMutableArray arrayWithObjects:@"name", @"nameDetail", @"specification", nil];
    priceTitleArray = [NSMutableArray arrayWithObjects:@"price",  /*@"inventory",*/ nil];

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestDetailProductInfoOpeartion || [_requestDetailProductInfoOpeartion isExecuting]) {
        [_requestDetailProductInfoOpeartion cancel];
        _requestDetailProductInfoOpeartion = nil;
    }
    
    if (_requestAddCommodityToCartOperation || [_requestAddCommodityToCartOperation isExecuting]) {
        [_requestAddCommodityToCartOperation cancel];
        _requestAddCommodityToCartOperation = nil;
    }
    
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
    [super viewDidLoad];

    self.title = @"商品详情";
    
    _tableView.backgroundColor = kColor_Clear;
    _tableView.backgroundView = nil;
    _tableView.allowsSelection = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorColor = kTableView_LineColor;
    
    collect_Button = [UIButton buttonWithTitle:@""
                                                  target:self
                                                selector:@selector(collectAction)
                                                   frame:CGRectMake(33.0f, 10, 30, 30)
                                 backgroundImg:[UIImage imageNamed:@"productCollection"]
                                        highlightedImage:nil];
    [collect_Button setBackgroundImage:[UIImage imageNamed:@"productCollection_solid"]  forState:UIControlStateSelected];

    UIButton * viewButton = [UIButton buttonWithTitle:@""
                                        target:self
                                      selector:@selector(collectAction)
                                         frame:CGRectMake(0.0f, 0.0f, 107.0f, 49.0f)
                                 backgroundImg:nil
                              highlightedImage:nil];
    viewButton.backgroundColor = kColor_Clear;
    
    
    UIButton *add_Button = [UIButton buttonWithTitle:@"加入购物车"
                                              target:self
                                            selector:@selector(addAction)
                                               frame:CGRectMake(106.0f, 0.0f, 107.0f, 49.0f)
                                       backgroundImg:nil                                    highlightedImage:nil];
    
    [add_Button.titleLabel setFont:kFont_Light_14];
    UIButton *buy_Button = [UIButton buttonWithTitle:@"立即购买"
                                              target:self
                                            selector:@selector(buyNowAction)
                                               frame:CGRectMake(213.0f, 0.0f, 107.0f, 49.0f)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    [buy_Button.titleLabel setFont:kFont_Light_14];
    
    add_Button.backgroundColor = [UIColor colorWithRed:130/255. green:108/255. blue:86/255. alpha:1.];
     [collect_Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    buy_Button.backgroundColor = [UIColor colorWithRed:107/255. green:91/255. blue:72/255. alpha:1.];
    
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height-kNavigationBar_Height - 49  + 20);
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10 - 10, 140)];
    } else {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10 - 10, 140)];
    }
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    footView.backgroundColor = kColor_White;
    
    [self.view addSubview:footView];
    

    
    [footView addSubview:add_Button];
    [footView addSubview:collect_Button];
    [footView addSubview:buy_Button];
    [footView addSubview:viewButton];
    
}

- (void)addAction
{
    NSInteger isAvaible = NO;
    for (ProductSold *obj in _CDVCCommodity.product_soldBranch) {
        if (!(obj.product_storageType == 1 && obj.product_quantity <= 0))
            isAvaible = YES;
    }
    if (!isAvaible){
        [SVProgressHUD showErrorWithStatus2:@"对不起，暂无库存"];
        return;
    }
    
    if (_CDVCCommodity.product_selectedIndex <= 0) {
        [SVProgressHUD showErrorWithStatus2:@"请选择购买商品的门店"];
        return;
    }
    [self requestAddCommodityToCart:1];
}

-(void)collectAction
{
    if (!self.isCollect) {
        [self requestAddFavorte];
    }else{
        //取消收藏
        [self CancelCollect];
    }

}

-(void)buyNowAction
{

    NSInteger isAvaible = NO;
    for (ProductSold *obj in _CDVCCommodity.product_soldBranch) {
        if (!(obj.product_storageType == 1 && obj.product_quantity <= 0))
            isAvaible = YES;
    }
    if (!isAvaible){
        [SVProgressHUD showErrorWithStatus2:@"对不起，暂无库存"];
        return;
    }
    
    if (_CDVCCommodity.product_selectedIndex <= 0) {
        [SVProgressHUD showErrorWithStatus2:@"请选择购买商品的门店"];
        return;
    }
     [self requestAddCommodityToCart:10];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = floor((self.scrollView.contentOffset.x-150)/300) + 1 ;
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
    if ([titleStr isEqualToString:@"image"]) {
        return 1;
    } else if ([titleStr isEqualToString:@"name"]) {
        return nameTitleArray.count;
    } else if ([titleStr isEqualToString:@"price"]) {
        return priceTitleArray.count;
    } else if ([titleStr isEqualToString:@"describe"]) {
        return 2;
    }  else if ([titleStr isEqualToString:@"branch"]){
        return _CDVCCommodity.product_soldBranch.count == 0 ? 0 : _CDVCCommodity.product_soldBranch.count + 1;
    }else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"image"]){
        return 140.0f;
    } else if ([titleStr isEqualToString:@"name"]){
        NSString *nameTitleStr = [nameTitleArray objectAtIndex:indexPath.row];
        if ([nameTitleStr isEqualToString:@"name"]) {
            return kTableView_DefaultCellHeight;
        } else if ([nameTitleStr isEqualToString:@"nameDetail"]){
            return kTableView_DefaultCellHeight;
        } else if ([nameTitleStr isEqualToString:@"specification"]) {
            return kTableView_DefaultCellHeight;
        }
    } else if ([titleStr isEqualToString:@"price"]){
        NSString *priceTitleStr = [priceTitleArray objectAtIndex:indexPath.row];
        if ([priceTitleStr isEqualToString:@"price"]) {
            return kTableView_DefaultCellHeight;
        }
        if ([priceTitleStr isEqualToString:@"memberPrice"]) {
            return kTableView_DefaultCellHeight;
        }
        if ([priceTitleStr isEqualToString:@"inventory"]) {
            return kTableView_DefaultCellHeight;
        }
    } else if ([titleStr isEqualToString:@"describe"]){
        if (indexPath.row == 0) {
            return kTableView_HeightOfRow;
        } else if (indexPath.row == 1) {
            CGRect tempRect = [_CDVCCommodity.product_describe boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
            CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
            if (lines > 1) {
                return tempRect.size.height + (lines * 5)+ 5;
            }else {
                return kTableView_DefaultCellHeight;
            }
        }
    } else if ([titleStr isEqualToString:@"branch"]) {
        if (indexPath.row == 0)
            return kTableView_DefaultCellHeight;
        else
            return kTableView_HeightOfRow_Multiline;
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
        scrollView.tag = 999999;
        scrollView.directionalLockEnabled = YES; //只能一个方向滑动
        scrollView.pagingEnabled = YES; //是否翻页
        scrollView.showsVerticalScrollIndicator =NO;
        scrollView.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
        scrollView.delegate = self;
        CGSize newSize = CGSizeMake(300 * [_CDVCCommodity.product_pictureURLArray count], 140);
        [scrollView setContentSize:newSize];
        
        for (int i = 0 ; i<[_CDVCCommodity.product_pictureURLArray count];i++){
            UIImageView *imageView = [[UIImageView alloc] init];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
            tap.delegate = self;
            imageView.tag = i  + 100;
            [imageView addGestureRecognizer:tap];
            
            imageView.userInteractionEnabled = YES;
            [imageView setImageWithURL:[NSURL URLWithString:[_CDVCCommodity.product_pictureURLArray objectAtIndex:i]]];
            [imageView setFrame:CGRectMake(300 * i + 86, 2, 135, 135)];
            [scrollView addSubview:imageView];
        }
        
        pageControl =[[UIPageControl alloc] initWithFrame:CGRectMake(0,300,300,140)];
        pageControl.backgroundColor =[UIColor clearColor];
        pageControl.numberOfPages = [_CDVCCommodity.product_pictureURLArray count];
        pageControl.currentPage = 0;
        [scrollView addSubview:pageControl];
        [cell.contentView addSubview:scrollView];
        return cell;
    } else if ([titleStr isEqualToString:@"name"]){
        NSString *nameTitleStr = [nameTitleArray objectAtIndex:indexPath.row];
        if ([nameTitleStr isEqualToString:@"name"]) {
            NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
            [cell.titleLabel setText:@"名称"];
            [cell.valueText setText:@""];
            [cell setAccessoryText:@""];
            return cell;
        } else if ([nameTitleStr isEqualToString:@"nameDetail"]){
            ContentEditCell *cell = [self configContentEditCell:tableView indexPath:indexPath];
            cell.contentEditText.text = _CDVCCommodity.product_name;
            
            CGRect rect = cell.contentEditText.frame;
            rect.size.height = [_CDVCCommodity valuationProductNameHeightWithFont:kNormalFont_14] + 20.0f;
            cell.contentEditText.frame = rect;
            return cell;
        } else if ([nameTitleStr isEqualToString:@"specification"]) {
            NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
            [cell.titleLabel setText:@"规格"];
            CGRect rect = cell.valueText.frame;
            rect.origin.x=140;
            cell.valueText.frame=rect;
            [cell.valueText setText:_CDVCCommodity.commodity_specification];
            //[cell setAccessoryText:@""];
            return cell;
        }
    } else if ([titleStr isEqualToString:@"price"]){
        NSString *priceTitleStr = [priceTitleArray objectAtIndex:indexPath.row];
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        [cell.titleLabel setText:@""];
        [cell.valueText setText:@""];
        [cell setAccessoryText:@""];
        if ([priceTitleStr isEqualToString:@"price"]) {
            cell.titleLabel.text = @"零售价";
            CGRect rect = cell.valueText.frame;
            rect.origin.x=150;
            cell.valueText.frame=rect;
            cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f", CUS_CURRENCYTOKEN,_CDVCCommodity.product_originalPrice];
        }
        if ([priceTitleStr isEqualToString:@"memberPrice"]) {
            if (_CDVCCommodity.product_sellingWay == GPProductSellingWayDiscountPrice) {
                cell.titleLabel.text = @"折扣价";
                cell.valueText.text  = [NSString stringWithFormat:@"%@ %.2f", CUS_CURRENCYTOKEN, _commodityDiscount];
            }else if(_CDVCCommodity.product_sellingWay == GPProductSellingWayPromotionPrice){
                cell.titleLabel.text = @"促销价";
                cell.valueText.text  = [NSString stringWithFormat:@"%@ %.2f", CUS_CURRENCYTOKEN, _CDVCCommodity.product_salesPrice];
            }
        }
        if ([priceTitleStr isEqualToString:@"inventory"]) {
            cell.titleLabel.text = @"库存";
            cell.valueText.text = [NSString stringWithFormat:@"%ld", (long)_CDVCCommodity.commodity_stockQuantity];
        }
        return cell;
    } else if ([titleStr isEqualToString:@"describe"]){
        if (indexPath.row == 0) {
            NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
            [cell.titleLabel setText:@"介绍"];
            [cell.valueText setText:@""];
            [cell setAccessoryText:@""];
            return cell;
        } else if (indexPath.row == 1) {
            NSString *reuseidentifier = [NSString stringWithFormat:@"cell%@",indexPath];
            UITableViewCell *cellDes = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10,0, kSCREN_BOUNDS.size.width - 20,20)];
            label.tag = 300;
            label.numberOfLines = 0;
            label.textColor = kMainLightGrayColor;
            label.font = kNormalFont_14;
            label.textAlignment = NSTextAlignmentLeft;
            [cellDes.contentView addSubview:label];
            UILabel *deslab = [cellDes.contentView viewWithTag:300];
            CGRect tempRect = [_CDVCCommodity.product_describe  boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
            
            CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
            CGRect rect = deslab.frame;
            rect.size.height = tempRect.size.height + (lines * 5) ;
            deslab.frame = rect;
            if (_CDVCCommodity.product_describe) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:_CDVCCommodity.product_describe];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineSpacing  = 5;
                [attributedString setAttributes:@{NSFontAttributeName:kNormalFont_14,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                deslab.attributedText = attributedString;
            }
            return cellDes;
        }
    } else if ([titleStr isEqualToString:@"branch"])
    {
        if (indexPath.row == 0){
            NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
            [cell.titleLabel setText:@"请选择购买门店"];
            [cell.valueText setText:@""];
            [cell setAccessoryText:@""];
            cell.titleLabel.frame = CGRectMake(10, 15, 270, 20);
            return cell;
        } else {
            NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
            [cell.titleLabel setText:[[_CDVCCommodity.product_soldBranch objectAtIndex:indexPath.row - 1] product_branchName]];
            [cell setAccessoryText:@""];
            cell.titleLabel.frame = CGRectMake(20.0f, 7, 250, 24.0f);
            
            UILabel *inventory = (UILabel *)[cell viewWithTag:9999];
            if (!inventory)
                inventory = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 33, 250, 24.0f)];
            if (IOS6)
                inventory.frame = CGRectMake(20.0f, 33, 250, 24.0f);
            inventory.font = kNormalFont_14;
            inventory.tag = 9999;
            [cell addSubview:inventory];
            
            NSInteger storageType = [[_CDVCCommodity.product_soldBranch objectAtIndex:indexPath.row -1] product_storageType];
            NSInteger storageQuantity = [[_CDVCCommodity.product_soldBranch objectAtIndex:indexPath.row -1] product_quantity];
            
            switch (storageType) {
                case 1:
                    if (storageQuantity > 0)
                        [inventory setText:[NSString stringWithFormat:@"库存%ld件",(long)storageQuantity]];
                    else
                        [inventory setText:@"暂无库存"];
                    
                    break;
                    
                default: [inventory setText:@"可售"];
                    break;
            }
            
            UIButton *stateButton = (UIButton *)[cell viewWithTag:10000];
            if (!stateButton) {
                stateButton = [UIButton buttonWithTitle:@""
                                                 target:self
                                               selector:@selector(selectAction:)
                                                  frame:CGRectMake(275.0f, 12.f, 36.0f, 36.0f)
                                          backgroundImg:[UIImage imageNamed:@"icon_unSelected"]
                                       highlightedImage:nil];
                [stateButton setBackgroundImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
                [stateButton setBackgroundImage:[UIImage imageNamed:@"icon_Selected"] forState:UIControlStateSelected];
            }
            if (indexPath.row == _CDVCCommodity.product_selectedIndex)
                stateButton.selected = YES;
            else
                stateButton.selected = NO;
            
            stateButton.tag = 10000;
            [cell addSubview:stateButton];
            if (storageType == 1 && storageQuantity <= 0)
            {
                [stateButton removeFromSuperview];
                _CDVCCommodity.product_selectedIndex = 0;
            }
            return cell;
        }
    }
    return nil;
}
- (void)selectAction:(UIButton *)sender
{
    UITableViewCell *cell = nil;
    if (IOS6 || IOS8)
        cell = (NormalEditCell *)sender.superview;
    else
        cell = (NormalEditCell *)sender.superview.superview;
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    UITableViewCell *oldCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_CDVCCommodity.product_selectedIndex inSection:indexPath.section]];
    ((UIButton *)[oldCell viewWithTag:10000]).selected = NO;
    
    _CDVCCommodity.product_selectedIndex = indexPath.row;
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
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
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
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
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
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    [cell.contentEditText setTextColor:[UIColor blackColor]];
    [cell.contentEditText setUserInteractionEnabled:NO];
    return cell;
}



#pragma mark -  手势
- (void)tapImageView:(UIGestureRecognizer *)ges
{
    if ([ges.view isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)ges.view;
        NSString *imageUrl = [_CDVCCommodity.product_pictureURLArray objectAtIndex:imgView.tag - 100];
        NSString *tempUrl = [imageUrl componentsSeparatedByString:@"&"].firstObject;
        UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tempUrl]]];
        [SJAvatarBrowser showImage:imgView img:image];
    }
}
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
                           @"ImageWidth":@270,
                           @"ImageHeight":@270};
    _requestDetailProductInfoOpeartion = [[GPCHTTPClient sharedClient] requestUrlPath:@"/commodity/getCommodityDetailByCommodityCode"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        
        if (!_CDVCCommodity) {
            _CDVCCommodity = [[CommodityObject alloc] init];
        }
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _CDVCCommodity.product_code = commodityCode;
            
            FavoriteID = [data objectForKey:@"FavoriteID"];
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
            [orderDoc setOrder_Type:1];
            [orderDoc setOrder_TotalPrice:[[data objectForKey:@"PromotionPrice"] doubleValue] ];
            [orderDoc setOrder_TotalSalePrice:[[data objectForKey:@"UnitPrice"] doubleValue]];
            
            NSDictionary *dict = @{@"product_ID":@"CommodityID",
                                   @"product_name":@"CommodityName",
                                   @"product_describe":@"Describe",
                                   @"commodity_specification":@"Specification",
                                   @"commodity_stockQuantity":@"StockQuantity",
                                   @"commodity_stockCalcType":@"StockCalcType",
                                   @"product_sellingWay":@"MarketingPolicy",
                                   @"product_originalPrice":@"UnitPrice",
                                   @"product_promotionPrice":@"PromotionPrice",//折扣价和促销价都取该字段
                                   @"product_discountPrice":@"PromotionPrice"};
            [_CDVCCommodity assignObjectPropertyWithDictionary:data andObjectPropertyAssociatedDictionary:dict];
            BOOL isDeleteCommodity_stockQuantity = NO;
            if(_CDVCCommodity.commodity_stockCalcType != 1 || data[@"StockQuantity"] == [NSNull null])
                isDeleteCommodity_stockQuantity = YES;
            [_CDVCCommodity valuationProductSalesPrice];
            
            NSMutableArray *soldBranch = [NSMutableArray array];
            if (data[@"ProductEnalbeInfo"] != [NSNull null]) {
                for (NSDictionary *obj in data[@"ProductEnalbeInfo"]) {
                    ProductSold *product = [[ProductSold alloc] init];
                    NSDictionary *dict1 = @{@"product_branchId":@"BranchID",
                                            @"product_branchName":@"BranchName",
                                            @"product_quantity":@"Quantity",
                                            @"product_storageType":@"StockCalcType"};
                    
                    [product assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict1];
                    [soldBranch addObject:product];
                }
            }
            _CDVCCommodity.product_soldBranch = soldBranch;
            
            //如果只有一个门店则默认勾选
            if (soldBranch.count == 1)
                _CDVCCommodity.product_selectedIndex = 1;
            
            if(data[@"CommodityImage"] != [NSNull null])
                [_CDVCCommodity setProduct_pictureURLArray:data[@"CommodityImage"]];
            
            
            NSMutableArray *deleteArray = [NSMutableArray array];
            if(_CDVCCommodity.product_name.length == 0){
                [deleteArray addObject:[nameTitleArray objectAtIndex:0]];
                [deleteArray addObject:[nameTitleArray objectAtIndex:1]];
            }
            if(_CDVCCommodity.commodity_specification.length == 0){
                [deleteArray addObject:[nameTitleArray objectAtIndex:2]];
            }
            [nameTitleArray removeObjectsInArray:deleteArray];
            [deleteArray removeAllObjects];
            
            if( _CDVCCommodity.product_originalPrice < 0){
                [deleteArray addObject:[priceTitleArray objectAtIndex:0]];
            }

        [priceTitleArray removeObjectsInArray:deleteArray];
            [deleteArray removeAllObjects];
            
            if(_CDVCCommodity.product_pictureURLArray.count == 0){
                [deleteArray addObject:[titleArray objectAtIndex:0]];
            }
            if([nameTitleArray count] == 0){
                [deleteArray addObject:[titleArray objectAtIndex:1]];
            }
            if([priceTitleArray count] == 0){
                [deleteArray addObject:[titleArray objectAtIndex:2]];
            }
            if (_CDVCCommodity.product_describe.length == 0){
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

-(void)requestFavoriteID
{
    NSDictionary *para = @{@"ProductCode":[NSNumber numberWithLongLong:commodityCode],
                           @"CustomerID":@(CUS_CUSTOMERID),
                           @"ImageWidth":@270,
                           @"ImageHeight":@270};
    _requestDetailProductInfoOpeartion = [[GPCHTTPClient sharedClient] requestUrlPath:@"/commodity/getCommodityDetailByCommodityCode"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {

        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {

            FavoriteID = [data objectForKey:@"FavoriteID"];
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

- (void)requestAddCommodityToCart:(NSInteger)flag
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSInteger branchId = [[_CDVCCommodity.product_soldBranch objectAtIndex:_CDVCCommodity.product_selectedIndex - 1] product_branchId];
    
    NSDictionary  *para = @{@"ProductCode":[NSNumber numberWithLongLong:_CDVCCommodity.product_code],
                            @"BranchID":@(branchId),
                            @"ProductType":@1,
                            @"Quantity":@1};
    
    _requestAddCommodityToCartOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Cart/AddCart"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus2:[message length] > 0 ? message : @"成功添加商品都购物车！"];
            
            if (flag ==10) {
                //购物车 
                self.tabBarController.selectedIndex = 2;
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus2:error];
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestAddFavorte
{
    [SVProgressHUD showWithStatus:@"Loading"];
    

    NSDictionary  *para = @{@"ProductCode":[NSNumber numberWithLongLong:_CDVCCommodity.product_code],
                            @"ProductType":@(1),

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
    
    NSDictionary  *para = @{@"UserFavoriteID":FavoriteID
                            };
    
    _requestAddFavorteOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Customer/DelFavorite"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            [self requestFavoriteID];
            self.isCollect = NO;
            collect_Button.selected = NO;
            [SVProgressHUD showSuccessWithStatus2:message];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus2:error];
            
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    
}

@end
