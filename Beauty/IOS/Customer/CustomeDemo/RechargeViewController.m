//
//  RechargeViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-20.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//
#import "RechargeViewController.h"
#import "TwoLabelCell.h"
#import "GPHTTPClient.h"
#import "GDataXMLDocument+ParseXML.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "ECardLevelViewController.h"
#import "NSDate+Convert.h"
#import "discountListJSON.h"
#import "GetDetailPayNewViewController.h"
#import "CustomerCard.h"
#import "CardInfoJson.h"
#import "GetDetailPayNewViewController.h"

#define CUS_CUSTOMERID [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_USERID"] integerValue]

UIView* goBackgroundView;

@interface RechargeViewController ()
@property (assign, nonatomic)CGSize expectedLabelSize;
@property (weak  , nonatomic) AFHTTPRequestOperation *getBalanceOperation;
@property (weak  , nonatomic) AFHTTPRequestOperation *getTwoDimensionalCodeOperation;
@property (weak , nonatomic) AFHTTPRequestOperation * requestECardInfoOperation;
@property (strong, nonatomic) NSArray *titleNameArry;
@property (strong, nonatomic) UITextView *textView_selected;
@property (assign, nonatomic) CGFloat text_Height;
@property (assign, nonatomic) CGFloat text_Y;
@property (copy  , nonatomic) NSString *twoDimensionalCodeURL;
@property (strong, nonatomic) UIImageView *TwoDimensionalCodeImageView;
@property (strong, nonatomic) UIImageView *customerHeadImage;
@property (copy  , nonatomic) NSString *balance;
@property (copy  , nonatomic) NSString *level;
@property (copy  , nonatomic) NSString *discount;
@property (copy  , nonatomic) NSString *eCardExpirationTime;
@property (assign, nonatomic) NSInteger showRechargePayView;//是否显示充值消费记录 0不显示  1显示
@property (strong, nonatomic) UIView *footView;
@property (strong, nonatomic)CardInfoJson *cardInfoJson;

@end

@implementation RechargeViewController
@synthesize cardInfoJson;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20  - 5)];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    self.title  = @"账户详情";
    if (![[_cardDefaultOrNot[0] valueForKey:@"isDefault"] boolValue] && [[_cardDefaultOrNot[0] valueForKey:@"cardTypeID"]integerValue ] == 1) {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, 320.0f, 49.0f)];
        _footView.backgroundColor = kColor_FootView;
        [self.view addSubview:_footView];
        
        UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 49.0f)];
        [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
        [_footView addSubview:footViewImage];
        
        UIButton *add_Button = [UIButton buttonWithTitle:@""
                                                  target:self
                                                selector:@selector(setToDefault)
                                                   frame:CGRectMake(5.0f, 6.5f, 310.0f, 36.0f)
                                           backgroundImg:[UIImage imageNamed:@"order-paybtn"]
                                        highlightedImage:nil];
        [_footView addSubview:add_Button];
    }
   
    [self getCardInfo];
}

-(void)setToDefault{
    [_cardDefaultOrNot[0] setValue:@"YES" forKey:@"isDefault"];
    _footView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_getBalanceOperation || [_getBalanceOperation isExecuting]) {
        [_getBalanceOperation cancel];
        _getBalanceOperation = nil;
    }
    
    if (_getTwoDimensionalCodeOperation || [_getTwoDimensionalCodeOperation isExecuting]) {
        [_getTwoDimensionalCodeOperation cancel];
        _getTwoDimensionalCodeOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 1;

        case 1: return 1;

        case 2:
            if (cardInfoJson.discountList.count == 0) {
                return 1;
            }else{
                return cardInfoJson.discountList.count + 1;
            }
        case 3:
            if ([[_cardList[0] valueForKey:@"cardDescription" ] isEqual:@""]) {
                return 1;
            }else{
                return 2;
            }
        case 4:
            return 1;
            
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellindity =[NSString stringWithFormat: @"RechargeEditCell_%@",indexPath];
    TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[TwoLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.section == 1){
        if (indexPath.row == 0) {
            [cell setTitle:@"有效期"];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:1006];
            if (!imageView)
                imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"outOfDate"]];

            imageView.frame = CGRectMake(165.0f, (kTableView_DefaultCellHeight - 30.0f)/2 + 5, 45.0f, 18.0f);
            if (IOS6) {
                imageView.frame = CGRectMake(170.0f, (kTableView_DefaultCellHeight - 30.0f)/2 + 5, 45.0f, 18.0f);
            }
            imageView.tag = 1006;
            imageView.hidden = YES;
            
            NSDate *date = nil;
            date = [NSDate dateFromString:cardInfoJson.cardExpiredDate];
            date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + 8*3600)];
            [cell setValue:[NSDate stringFromDate:date] isEditing:NO];
            NSDate *currentDate = [NSDate date];
            date = [NSDate dateFromString:[date.description substringToIndex:10]];
            currentDate = [NSDate dateFromString:[currentDate.description substringToIndex:10]];
            if([date compare:currentDate] != NSOrderedAscending)
                imageView.hidden = YES;
            else
                imageView.hidden = NO;
            
            [cell addSubview:imageView];
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            
            [cell setTitle:@"账户类型"];
            [cell setValue:cardInfoJson.cardTypeName isEditing:NO];
           
        }else {
            
            discountListJSON *discountlistJson = [[discountListJSON alloc]init];
            discountlistJson = [cardInfoJson.discountList objectAtIndex:indexPath.row - 1];

            cell.titleLabel.frame = CGRectMake(kCell_LabelToLeft+20, (kTableView_DefaultCellHeight - kCell_LabelHeight)/2, 140, kCell_LabelHeight);
            cell.titleLabel.text = [NSString stringWithFormat:@"%@",[discountlistJson valueForKey:@"discountName"]];
            cell.titleLabel.textColor = [UIColor blackColor];
            [cell setValue:[[discountlistJson valueForKey:@"discount" ]stringValue] isEditing:NO];
        }
        
    }else if(indexPath.section == 0 && indexPath.row == 0){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell setValue:@"" isEditing:NO];
        [cell setTitle:@""];
        
        cell.backgroundColor = [UIColor clearColor];
        
        UIView * redBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, 310, 170)];
        UIView *redView = (UIView *)[cell viewWithTag:239];
        if (redView ==nil) {
            redBackGroundView.backgroundColor = [UIColor colorWithRed:239/255. green:27/255. blue:100/255. alpha:1.];
            redBackGroundView.tag = 239;
            redBackGroundView.layer.cornerRadius = 8;
            [cell addSubview:redBackGroundView];
        }
        
        UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 310, 176)];

        UIView *cartCheck = (UIView *)[cell viewWithTag:827];
        if (cartCheck == nil) {
            cardView.backgroundColor = [UIColor whiteColor];
            cardView.tag = 827;
            cardView.layer.cornerRadius = 8;
            [cell addSubview:cardView];
        }
        
        //默认标示
        UIButton *  defaultImageView = [[UIButton alloc] initWithFrame:CGRectMake(255, 0, 40, 25)];
        UIButton *defaultCheck = (UIButton *)[cell viewWithTag:230];
        
        if (defaultCheck == nil) {
            defaultImageView.tag = 230;
            defaultImageView.backgroundColor = [UIColor colorWithRed:254/255. green:147/255. blue:30/255. alpha:1.];
            [defaultImageView setTitle:@"默认" forState:UIControlStateNormal];
            defaultImageView.titleLabel.font = kNormalFont_14;
            defaultImageView.userInteractionEnabled = NO;
            [cardView addSubview:defaultImageView];
            defaultImageView.hidden = YES;

        }

        if ([[_cardDefaultOrNot[0] valueForKey:@"isDefault"] boolValue]) {
            defaultImageView.hidden = NO;
        }
        //
        UILabel *companyCheck = (UILabel *)[cell viewWithTag:828];
        if (companyCheck == nil) {
            UILabel *companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 17.5, 130, 30)];
            companyNameLabel.backgroundColor = [UIColor clearColor];
            companyNameLabel.text = [NSString stringWithString:self.cardName];
            companyNameLabel.font = kNormalFont_14;
            companyNameLabel.tag = 828;
            [cell addSubview:companyNameLabel];
        }

        UILabel *customerCheck = (UILabel *)[cell viewWithTag:829];

        if (customerCheck ) {
            [customerCheck removeFromSuperview];
        }
        UILabel *customerCardNumberTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, 90.5, 280, 16)];
        customerCardNumberTitleLabel.backgroundColor = [UIColor clearColor];
        customerCardNumberTitleLabel.text = cardInfoJson.realCardNo.length >0 ?[NSString stringWithFormat:@"实体卡号:%@",cardInfoJson.realCardNo] : @" ";
        customerCardNumberTitleLabel.font = kNormalFont_14;
        customerCardNumberTitleLabel.tag = 829;
        customerCardNumberTitleLabel.textColor =kColor_Editable;
        [cell addSubview:customerCardNumberTitleLabel];

        UILabel *cardNumberCheck = (UILabel *)[cell viewWithTag:830];
        UILabel *customerCardNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, 65.5, 280, 16)];
       
        if (cardNumberCheck == nil) {
            customerCardNumberLabel.backgroundColor = [UIColor clearColor];
            customerCardNumberLabel.font = kNormalFont_14;
            customerCardNumberLabel.textColor = kColor_Editable;
            customerCardNumberLabel.text = [NSString stringWithFormat:@"NO.%@",self.cardNO];
            customerCardNumberLabel.tag = 830;
            [cell addSubview:customerCardNumberLabel];
        }
        
        //余额
        UILabel * balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 145, 300, 20)];
        UILabel * balanceCheck = (UILabel *)[cell viewWithTag:135];
        if (balanceCheck == nil) {
            balanceLabel.font = kNormalFont_14;
            balanceLabel.textColor = [UIColor colorWithRed:251/255. green:146/255. blue:58/255. alpha:1.];
            balanceLabel.textAlignment = NSTextAlignmentRight;
            if (self.cardType ==2) {
                balanceLabel.text =[NSString stringWithFormat:@"%.2Lf",self.cardBalance];
            }else
                balanceLabel.text = [NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN,self.cardBalance];
            balanceLabel.tag=135;
            [cell addSubview:balanceLabel];
        }
        if ((IOS7 || IOS8)) {
            _TwoDimensionalCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(140, 22.5, 150, 150)];
            _customerHeadImage = [[UIImageView alloc] initWithFrame:CGRectMake(140+(150-30)/2, 22.5+(150-30)/2, 30, 30)];
        } else {
            _TwoDimensionalCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(150, 22.5, 150, 150)];
            _customerHeadImage = [[UIImageView alloc] initWithFrame:CGRectMake(150+(150-30)/2, 22.5+(150-30)/2, 30, 30)];
            cardView.frame = CGRectMake(10, 10, 310, 200);
        }
        
        [_TwoDimensionalCodeImageView setImageWithURL:[NSURL URLWithString:[_twoDimensionalCodeURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@""]];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoDimensionalCodeImageViewScale)];
        [_TwoDimensionalCodeImageView addGestureRecognizer:singleTap];
        _TwoDimensionalCodeImageView.userInteractionEnabled  = YES;
        [_customerHeadImage setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults]objectForKey:@"CUSTOMER_HEADIMAGE"]] placeholderImage:[UIImage imageNamed:@"People-default"]];
        _customerHeadImage.layer.masksToBounds = YES;
        _customerHeadImage.layer.cornerRadius = 5.0f;
        _customerHeadImage.layer.borderColor = [[UIColor whiteColor] CGColor];
        _customerHeadImage.layer.borderWidth = 2.0f;

    }else if (indexPath.section == 3){
        if (indexPath.row == 0) {
            [cell setTitle:@"账户描述"];
            cell.valueText.enabled = NO;
        }
        if (indexPath.row == 1) {
            cell.titleLabel.text = @"";
            cell.valueText.enabled = NO;
            UILabel * lable = (UILabel *)[cell viewWithTag:101];
            if (lable) {
                [lable removeFromSuperview];
            }
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kCell_LabelToLeft , (kTableView_DefaultCellHeight - kCell_LabelHeight)/2, 300, kCell_LabelHeight) ];           titleLabel.numberOfLines = 0;
            [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
            titleLabel.textColor = kColor_Black;
            titleLabel.font = kNormalFont_14;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.text = cardInfoJson.cardDescription;
            titleLabel.tag = 101;
         
            CGRect newFrame = titleLabel.frame;
            newFrame.size.height = _expectedLabelSize.height;
            titleLabel.frame = newFrame;
            [cell addSubview:titleLabel];
        }

    }else if (indexPath.section == 4){
        
        [cell setTitle:@"交易详细"];
        cell.valueText.enabled = NO;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
   return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 && indexPath.row == 1) {
        
        CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
        _expectedLabelSize = [cardInfoJson.cardDescription sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        
        return  (_expectedLabelSize.height+ 15) < kTableView_DefaultCellHeight? kTableView_DefaultCellHeight:(_expectedLabelSize.height+ 15);//13127634801
    }
    
    if (indexPath.section == 0 && indexPath.row == 0)
        return 180.0f;
    else
        return kTableView_DefaultCellHeight;
}

-(void)twoDimensionalCodeImageViewScale
{
    UIImage *image = _TwoDimensionalCodeImageView.image;
    if (!image) return;
    
    window = [UIApplication sharedApplication].keyWindow;
    goBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    defaultRect = [_TwoDimensionalCodeImageView convertRect:_TwoDimensionalCodeImageView.bounds toView:window];//关键代码，坐标系转换
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
    _TwoDimensionalCodeImageView.alpha = 0;
    [UIView animateWithDuration:0.5f animations:^{
        imageView.frame=CGRectMake(20.0f,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width - 40.0f, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width - 40.0f);
        goBackgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
    } completion:^(BOOL finished) {
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 4 && indexPath.row == 0) {
        GetDetailPayNewViewController *getdetailPay = (GetDetailPayNewViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"getDetailPayNew"];
        getdetailPay.cardInfo = _cardList;
        getdetailPay.cardType = self.cardType;
        [self.navigationController pushViewController:getdetailPay animated:YES];
    }
    
    if (indexPath.section == 2 && indexPath.row == 0 && _showRechargePayView == 1)
        [self performSegueWithIdentifier:@"gotoPayAndRechargeListViewController" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoEcardLevelDiscount"]) {
        ECardLevelViewController *eCardLevel = segue.destinationViewController;
        eCardLevel.eCardLevel = _level;
    }
}

- (void)hideImage:(UITapGestureRecognizer*)tap{
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.5f animations:^{
        imageView.frame = defaultRect;
        goBackgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        self.view.alpha = 1;
        [goBackgroundView removeFromSuperview];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return kTableView_WithTitle;
        case 1: return kTableView_Margin;
        default: return 0;
    }
}

- (void)goBackPreviousViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 接口

-(void)getCardInfo{
    
    NSDictionary *paraGet = @{@"CustomerID":@(CUS_CUSTOMERID),
                              @"UserCardNo":_cardNO};
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *dict = @{@"discountName" : @"DiscountName",
                           @"discount" : @"Discount"};
    
    
    _requestECardInfoOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCardInfo"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            cardInfoJson = [[CardInfoJson alloc]init];
            cardInfoJson.cardID = [data objectForKey:@"CardID"];
            cardInfoJson.cardName = [data objectForKey:@"CardName"];
            cardInfoJson.userCardNo = [data objectForKey:@"UserCardNo"];
            cardInfoJson.balance = [[data objectForKey:@"Balance"] doubleValue];
            cardInfoJson.currency = [data objectForKey:@"Currency"];
            cardInfoJson.cardCreatedDate = [data objectForKey:@"CardCreatedDate"];
            cardInfoJson.cardExpiredDate = [data objectForKey:@"CardExpiredDate"];
            cardInfoJson.cardDescription = [data objectForKey:@"CardDescription"];
            cardInfoJson.cardType = [data objectForKey:@"CardType"];
            cardInfoJson.cardTypeName = [data objectForKey:@"CardTypeName"];
            cardInfoJson.realCardNo = [data objectForKey:@"RealCardNo"];
            
            cardInfoJson.discountList = [[NSMutableArray alloc]init];
            
            for (NSDictionary *obj in [data objectForKey:@"DiscountList"])
            {
                discountListJSON *discountlistJSON = [[discountListJSON alloc]init];
                [discountlistJSON assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [cardInfoJson.discountList addObject:discountlistJSON];
            }

            
            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)showMessage:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}
@end