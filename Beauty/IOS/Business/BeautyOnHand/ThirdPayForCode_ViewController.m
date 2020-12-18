//
//  ThirdPayForCode_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/10/27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ThirdPayForCode_ViewController.h"
#import "FooterView.h"
#import "NavigationView.h"
#import "ColorImage.h"
#import "NormalEditCell.h"
#import "GPBHTTPClient.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "ThirdPayResult_ViewController.h"
#import "UIButton+InitButton.h"

@interface ThirdPayForCode_ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) UITableView * myTableView;
@property (weak, nonatomic) AFHTTPRequestOperation *requestPayForCode;
@property (nonatomic ,strong) NSString * codeUrl;
@property (nonatomic, strong) NSString * productName;
@property (nonatomic ,strong) NSString * NetTradeNo;
@end

@implementation ThirdPayForCode_ViewController
@synthesize myTableView;
@synthesize codeUrl;
@synthesize  productName;
@synthesize  NetTradeNo;
@synthesize payType;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"扫码支付"];

    [self.view addSubview:navigationView];
    
    [self initTableView];
    
    [self requestCodePayInfo];
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f )style:UITableViewStyleGrouped];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];
    
    if ((IOS7 || IOS8)) {
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
    }
    UIView * View = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 64.0f - 49.0f, myTableView.frame.size.width+10 , 49.0f)];
    View.backgroundColor = kColor_Background_View;;
    [self.view addSubview:View];
    
    UIButton * buttonCancel = [UIButton buttonWithTitle:@"下一步" target:self selector:@selector(goToresult) frame:CGRectMake( 5, 5 , 310, 39) backgroundImg:ButtonStyleBlue];
    [View addSubview:buttonCancel];
}

-(void)goToresult
{
    if (NetTradeNo > 0) {
        
        ThirdPayResult_ViewController * result = [[ThirdPayResult_ViewController alloc] init];
        result.NetTradeNo = NetTradeNo;
        result.payPrice = self.payPrice;
        result.productName = productName;
        result.orderComeFrom = self.orderComeFrom;
        result.payType = payType;
        [self.navigationController pushViewController:result animated:YES];
        
    }else
    {
        [SVProgressHUD showErrorWithStatus2:@"下单失败,请重新获取" touchEventHandle:nil];
    }

}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==1) {
        return 260;
    }
    return kTableView_HeightOfRow;
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
    if (section ==0) {
        return 4;
    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = [NSString stringWithFormat:@"editCell%ld",(long)indexPath.row];
    NormalEditCell *editCell = [tableView dequeueReusableCellWithIdentifier:string];
    if (!editCell) {
        editCell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
        editCell.valueText.userInteractionEnabled = NO;
        editCell.valueText.textColor = kColor_Black;
    }
    [editCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.section ==0) {
        switch (indexPath.row) {
            case 0:
                editCell.titleLabel.text =@"第三方平台";
                if (payType == PayTypeWeiXin) {
                    editCell.valueText.text = @"微信";
                }
                if (payType == PayTypeZhiFuBao) {
                    editCell.valueText.text = @"支付宝";
                }
                break;
            case 1:
                editCell.titleLabel.text =@"第三方支付编号";
                editCell.valueText.text = NetTradeNo;
                break;
            case 2:
                editCell.titleLabel.textColor = kColor_Black;
                editCell.titleLabel.text = productName;
                break;
            case 3:
                editCell.titleLabel.text =@"金额";
                editCell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf",MoneyIcon,self.payPrice];
                break;
                
            default:
                break;
        }
        
    }else
    {
        editCell.titleLabel.text = @"";
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(55, 20, 200, 200)];
        [imageView setImageWithURL:[NSURL URLWithString:codeUrl] placeholderImage:nil];
        [editCell.contentView addSubview:imageView];
        imageView.backgroundColor = [UIColor clearColor];
        
        UILabel * textLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 225,310 , 20)];
        if (payType == PayTypeWeiXin) {
            textLable.text = @"请使用微信扫一扫，扫描二维码支付";
        }
        if (payType == PayTypeZhiFuBao) {
            textLable.text = @"请打开支付宝钱包，使用扫一扫完成支付";
        }

        textLable.textAlignment = NSTextAlignmentCenter;
        textLable.font = kFont_Light_14;
        textLable.textColor = kColor_Editable;
        [editCell.contentView addSubview:textLable];
        
    }
    return  editCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

// --获取二维码支付信息

-(void)requestCodePayInfo
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlPath;
    if (payType == PayTypeWeiXin) {
       urlPath = @"/Payment/GetNetTradeQRCode";
    }
    if (payType == PayTypeZhiFuBao) {
        urlPath = @"/Payment/GetAliPayNetTradeQRCode";
    }
    _requestPayForCode = [[GPBHTTPClient sharedClient] requestUrlPath:urlPath andParameters:self.para failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            productName = [data objectForKey:@"ProductName"];
            NetTradeNo = [data objectForKey:@"NetTradeNo"];
            codeUrl = [data objectForKey:@"QRCodeUrl"];
            [myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus:error];
        }];
    } failure:^(NSError *error) {
        
    }];

}

@end
