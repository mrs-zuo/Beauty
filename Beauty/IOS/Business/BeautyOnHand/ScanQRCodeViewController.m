//
//  ScanQRCodeViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-24.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import "CustomerDoc.h"
#import "ServiceDoc.h"
#import "CommodityDoc.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "UIButton+InitButton.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "AppDelegate.h"
#import "DEFINE.h"
#import "ServiceDetailViewController.h"
#import "ProductDetailViewController.h"
#import "CommodityOrServiceDoc.h"
#import "GPBHTTPClient.h"
#import "ThirdPayResult_ViewController.h"
#import "CusMainViewController.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "GPBHTTPClient.h"


@interface ScanQRCodeViewController ()
@property (strong, nonatomic) ZBarReaderView *readerView;
@property (strong, nonatomic) UIView *coverView;
@property (strong, nonatomic) UIView *scanView;
@property (strong, nonatomic) UILabel *scanStateLbl;
@property (weak ,nonatomic)  AFHTTPRequestOperation * requestWeChatPay;
@property (weak ,nonatomic)  AFHTTPRequestOperation * requestAttendanceByAccountOperation;

@end

@implementation ScanQRCodeViewController
@synthesize coverView;
@synthesize scanView;
@synthesize scanStateLbl;
@synthesize readerView;
@synthesize payType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initLayout];
}

- (void)initLayout
{
    readerView = [[ZBarReaderView alloc]init];
    readerView.frame = self.view.bounds;
    readerView.readerDelegate = self;
    readerView.torchMode = 0;
    readerView.tracksSymbols = NO;
    [readerView.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    CGRect scanMaskRect = CGRectMake((kSCREN_BOUNDS.size.width - 200)/2, (kSCREN_BOUNDS.size.height - 200)/2 - 64.0f, 200, 200);
    readerView.scanCrop = [self getPortraitModeScanCropRect:scanMaskRect forOverlayView:readerView];
    [self.view addSubview:readerView];
    
    coverView = [[UIView alloc] initWithFrame:readerView.frame];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.6f;
    [readerView addSubview:coverView];
    
    scanView = [[UIView alloc] initWithFrame:scanMaskRect];
    scanView.layer.borderColor = [[UIColor whiteColor] CGColor];
    scanView.layer.borderWidth = 2.0f;
    [readerView addSubview:scanView];
    
    scanStateLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, scanView.frame.size.width - 20.0f, 0.8f)];
    scanStateLbl.backgroundColor = [UIColor greenColor];
    scanStateLbl.userInteractionEnabled = YES;
    [scanView addSubview:scanStateLbl];
    [self addAnimation];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side
    CGPathAddRect(path, nil, CGRectMake(0,
                                        0,
                                        scanView.frame.origin.x,
                                        readerView.frame.size.height));
    // Right side
    CGPathAddRect(path, nil, CGRectMake(
                                        scanView.frame.origin.x + scanView.frame.size.width,
                                        0,
                                        readerView.frame.size.width - scanView.frame.origin.x - scanView.frame.size.width,
                                        readerView.frame.size.height));
    // Top side
    CGPathAddRect(path, nil, CGRectMake(0,
                                        0,
                                        readerView.frame.size.width,
                                        scanView.frame.origin.y));
    // Bottom side
    CGPathAddRect(path, nil, CGRectMake(0,
                                        scanView.frame.origin.y + scanView.frame.size.height,
                                        readerView.frame.size.width,
                                        readerView.frame.size.height - scanView.frame.origin.y - scanView.frame.size.height));
    maskLayer.path = path;
    coverView.layer.mask = maskLayer;
    CFRelease(path);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [readerView start];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)addAnimation
{
    CGMutablePathRef p = CGPathCreateMutable();
    CGPathMoveToPoint(p, NULL, 100.0f, 0.0f);
    CGPathAddLineToPoint(p, NULL, 100.0f, scanView.frame.size.height);
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath:p];  CFRelease(p);
    [animation setDuration:5.0f];
    [animation setAutoreverses:NO];
    [animation setRepeatCount:1000];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [scanStateLbl.layer addAnimation:animation forKey:NULL];
}

- (CGRect)getPortraitModeScanCropRect:(CGRect)overlayCropRect forOverlayView:(UIView*)readerVie
{
    CGRect scanCropRect = CGRectMake(0, 0, 1, 1); /*default full screen*/
    float x = overlayCropRect.origin.x;
    float y = overlayCropRect.origin.y;
    float width = overlayCropRect.size.width;
    float height = overlayCropRect.size.height;
    
    float a = y / readerVie.bounds.size.height;
    float b = 1 - (x + width) / readerVie.bounds.size.width;
    float c = (y + height) / readerVie.bounds.size.height;
    float d = 1 - x / readerVie.bounds.size.width;
    
    scanCropRect = CGRectMake(a, b, c, d);
    return scanCropRect;
}

- (void)showMessage:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self goToFirstPage];
    }];
}

- (void)goToFirstPage
{
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstNavigation"];
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)readerView:(ZBarReaderView*)zbReaderView didReadSymbols:(ZBarSymbolSet*)symbols fromImage:(UIImage*)image
{
    for(ZBarSymbol *sym in symbols) {
        
        if (self.viewFor == 1) {
            NSInteger number = [[sym.data substringToIndex:2] integerValue];
            [readerView stop];
            if ((self.payType == PayTypeWeiXin && (number == 11 || number ==12 || number == 13 || number==14 || number==15)) || (self.payType == PayTypeZhiFuBao && number == 28)) {
                [self requestCodePayInfo:sym.data];
            }else
            {
                [SVProgressHUD showErrorWithStatus2:@"条形码或者二维码出现错误！" touchEventHandle:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        } else if (self.viewFor == 2) { //打卡
            [self requestGetAttendanceByAccount:sym.data];
        }else{
            NSArray *array = [sym.data componentsSeparatedByString:@"?id="];
            if ([array count]!= 2) {
                [self showMessage:@"二维码内容错误！"];
                return;
            }
            NSArray *info = [[array objectAtIndex:1] componentsSeparatedByString:@"^"];
            NSString *commpany = [info objectAtIndex:0];
            if (![commpany isEqualToString:ACC_COMPANTCODE]) { //
                [self showMessage:@"商家信息错误！"];
                return;
            }
            NSInteger type = [[info objectAtIndex:1] integerValue];
            NSMutableString *QRCodeString = [NSMutableString stringWithString:[array objectAtIndex:1]];
            [readerView stop];
            [self requestScanResultWithQRCode:QRCodeString andType:type];
        }
        
        break;
    }
}

#pragma mark - 接口

// -- 商家去扫用户刷卡支付

-(void)requestCodePayInfo:(NSString *)code
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary * par;
    if([[self.para allKeys] containsObject:@"OrderID"])
    {
        NSArray * arr = [self.para objectForKey:@"OrderID"];
        if ([arr count]>0) {
            par = @{
                   @"UserCode":code,
                   @"CustomerID":[self.para objectForKey:@"CustomerID"],
                   @"OrderID":[self.para objectForKey:@"OrderID"],
                   @"Slavers":[self.para objectForKey:@"Slavers"],
                   @"TotalAmount":[self.para objectForKey:@"TotalAmount"],
                   @"PointAmount":[self.para objectForKey:@"PointAmount"],
                   @"CouponAmount":[self.para objectForKey:@"CouponAmount"],
                   @"Remark":[self.para objectForKey:@"Remark"]
                   };
        }
    }else
    {
        par =@{
                @"UserCode":code,
                @"CustomerID":[self.para objectForKey:@"CustomerID"],
                @"Slavers":[self.para objectForKey:@"Slavers"],
                @"TotalAmount":[self.para objectForKey:@"TotalAmount"],
                @"PointAmount":[self.para objectForKey:@"PointAmount"],
                @"CouponAmount":[self.para objectForKey:@"CouponAmount"],
                @"Remark":[self.para objectForKey:@"Remark"],
                @"MoneyAmount":[self.para objectForKey:@"MoneyAmount"],
                @"UserCardNo":[self.para objectForKey:@"UserCardNo"],
                @"ResponsiblePersonID":[self.para objectForKey:@"ResponsiblePersonID"]
               };
    }
//    /Payment/AliPayByAuthCode 支付宝顾客刷卡支付
//    所需参数
//    {"CustomerID":123,"OrderID":[1,2,3],"SlaveID":[1,2,3],"TotalAmount":100,"PointAmount":1000,"CouponAmount":1000,"UserCode":"65417854566521445","Remark":"adasdasddas"}
//    返回参数
//    { "Data": { "NetTradeNo": "NPC16021800000004", "TradeState": "TRADE_SUCCESS", "Code": "10000", "Msg": "Success", "SubMsg": "", "TradeNo": "2016021821001004910297988385", "TotalAmount": 0.00, "ReceiptAmount": 0.0, "InvoiceAmount": 0.0, "BuyerPayAmount": 0.0, "PointAmount": 1000.00, "DisplayResult": "交易支付成功", "OperationTip": null, "ChangeType": 1, "ChangeTypeName": null }, "Code": "1", "Message": "支付成功" }
    
    NSString *urlPath;
    if (payType == PayTypeWeiXin) {
        urlPath  =@"/Payment/WeChatPayByCustomer";
    }
    if (payType == PayTypeZhiFuBao) {
        urlPath  = @"/Payment/AliPayByAuthCode";
    }

    _requestWeChatPay = [[GPBHTTPClient sharedClient] requestUrlPath:urlPath andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            
            ThirdPayResult_ViewController * result = [[ThirdPayResult_ViewController alloc] init];
            result.NetTradeNo = [data objectForKey:@"NetTradeNo"];
            result.orderComeFrom = self.orderComeFrom;
            result.payType = payType;
            [self.navigationController pushViewController:result animated:YES];
            
        } failure:^(NSInteger code, NSString *error) {
            
            [SVProgressHUD showSuccessWithStatus2:error duration:3 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)requestScanResultWithQRCode:(NSString *)QRCodeString andType:(NSInteger)type
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"QRCode\":\"%@\",\"AccountID\":%ld,\"BranchID\":%ld}", QRCodeString, (long)ACC_ACCOUNTID, (long)ACC_BRANCHID];

    [[GPBHTTPClient sharedClient] requestUrlPath:@"/WebUtility/getInfoByQRcode" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (type == 0) {
                
                CustomerDoc *customerDoc = [[CustomerDoc alloc]init];
                [customerDoc setCus_ID:[[data objectForKey:@"CustomerID"] integerValue]];
                
                [customerDoc setCus_Name:[data objectForKey:@"CustomerName"]];
                [customerDoc setCus_Discount:[[data objectForKey:@"Discount"] doubleValue]];
                [customerDoc setCus_HeadImgURL:[data objectForKey:@"HeadImageURL"]];
                [customerDoc setCus_IsMyCustomer:[[data objectForKey:@"IsMyCustomer"] boolValue]];
                
                //   NSInteger code = [[dataDic objectForKey:@"Code"] integerValue];
                if (customerDoc.cus_ID > 0) {
                    if ([[PermissionDoc sharePermission] rule_MyCustomer_Read]) {
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        appDelegate.customer_Selected = customerDoc;
                        
                        [SVProgressHUD showSuccessWithStatus2:@"扫描顾客成功" duration:3 touchEventHandle:^{
                            CusMainViewController *cus = [[CusMainViewController alloc] init];
                            ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
                            [self.navigationController pushViewController:cus animated:YES];
                        }];
                    }else{
                        [self showMessage:@"扫描顾客成功，\n但您无权限查看顾客信息！"];
                    }
                }else
                    [self showMessage:@"扫描顾客失败！"];
            } else if(type == 2) {
                
                ServiceDoc *serviceDoc = [[ServiceDoc alloc]init];
                [serviceDoc setService_ID:[[data objectForKey:@"ID"] integerValue]];
                [serviceDoc setService_Code:[[data objectForKey:@"Code"] longLongValue]];
                [serviceDoc setService_ServiceName:[data objectForKey:@"Name"]];
                [serviceDoc setService_UnitPrice:[[data objectForKey:@"UnitPrice"] doubleValue]];
                [serviceDoc setService_PromotionPrice:[[data objectForKey:@"PromotionPrice"] doubleValue]];
                [serviceDoc setService_ExpirationTime:[data objectForKey:@"ExpirationTime"]];
                
                if (serviceDoc.service_ID > 0) {
                    if (ACC_BRANCHID == 0) {
                        ServiceDetailViewController *serviceDetailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"ServiceDetailViewController"];
                        serviceDetailVC.serviceCode = serviceDoc.service_Code;
                        [self.navigationController pushViewController:serviceDetailVC animated:YES];
                    }else{
                        if([[PermissionDoc sharePermission] rule_MyOrder_Write]){
                            if ([[PermissionDoc sharePermission] rule_Service_Read]) {
                                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                
                                BOOL isTrue = NO;
                                for(int i = 0; i<[appDelegate.serviceArray_Selected count] ;i++) {
                                    if(((ServiceDoc *)[appDelegate.serviceArray_Selected objectAtIndex:i]).service_ID == serviceDoc.service_ID)
                                    {
                                        [self showMessage:@"已添加该服务！"];
                                        isTrue = YES;
                                        break;
                                    }
                                }
                                if (!isTrue) {
                                    [appDelegate.serviceArray_Selected addObject:serviceDoc];
                                    [self showMessage:@"扫描服务成功！"];
                                    isTrue = NO;
                                }
                                for(int i = 0; i<[appDelegate.commodityOrServiceArray_Selected count] ;i++) {
                                    if(((ServiceDoc *)((CommodityOrServiceDoc *)[appDelegate.commodityOrServiceArray_Selected objectAtIndex:i]).commodityOrService).service_ID == serviceDoc.service_ID)
                                    {
                                        isTrue = YES;
                                        break;
                                    }
                                }
                                if (!isTrue) {
                                    CommodityOrServiceDoc *newCommodityOrService = [[CommodityOrServiceDoc alloc]init];
                                    newCommodityOrService.productType = 0;
                                    newCommodityOrService.commodityOrService = serviceDoc;
                                    [appDelegate.commodityOrServiceArray_Selected addObject:newCommodityOrService];
                                }
                                
                            }else
                                [self showMessage:@"扫描成功，\n但您权限查看服务信息！"];
                        }else
                            [self showMessage:@"扫描成功，\n但您无订单编辑权限！"];
                    }
                }else
                    [self showMessage:@"扫描服务失败！"];
            } else if(type == 1) {
                CommodityDoc *commodityDoc = [[CommodityDoc alloc]init];
                [commodityDoc setComm_ID:[[data objectForKey:@"ID"] integerValue]];
                [commodityDoc setComm_Code:[[data objectForKey:@"Code"] longLongValue]];
                [commodityDoc setComm_CommodityName:[data objectForKey:@"Name"]];
                [commodityDoc setComm_UnitPrice:[[data objectForKey:@"UnitPrice"] doubleValue]];
                [commodityDoc setComm_PromotionPrice:[[data objectForKey:@"PromotionPrice"] doubleValue]];
                if (commodityDoc.comm_ID > 0) {
                    if (ACC_BRANCHID == 0) {
                        ProductDetailViewController *productDetailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"ProductDetailViewController"];
                        productDetailVC.commodityCode = commodityDoc.comm_Code;
                        [self.navigationController pushViewController:productDetailVC animated:YES];
                    }else{
                        if ([[PermissionDoc sharePermission] rule_MyOrder_Write]) {
                            if([[PermissionDoc sharePermission] rule_Commodity_Read]){
                                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                BOOL isTrue = NO;
                                for(int i = 0; i<[appDelegate.commodityArray_Selected count] ;i++) {
                                    if(((CommodityDoc *)[appDelegate.commodityArray_Selected objectAtIndex:i]).comm_ID ==commodityDoc.comm_ID)
                                    {
                                        [self showMessage:@"已添加该商品！"];
                                        isTrue = YES;
                                        break;
                                    }
                                }
                                if (!isTrue) {
                                    [appDelegate.commodityArray_Selected addObject:commodityDoc];
                                    [self showMessage:@"扫描商品成功！"];
                                    isTrue = NO;
                                }
                                for(int i = 0; i<[appDelegate.commodityOrServiceArray_Selected count] ;i++) {
                                    if(((CommodityDoc *)((CommodityOrServiceDoc *)[appDelegate.commodityOrServiceArray_Selected objectAtIndex:i]).commodityOrService).comm_ID == commodityDoc.comm_ID)
                                    {
                                        isTrue = YES;
                                        break;
                                    }
                                }
                                if (!isTrue) {
                                    CommodityOrServiceDoc *newCommodityOrService = [[CommodityOrServiceDoc alloc]init];
                                    newCommodityOrService.productType = 0;
                                    newCommodityOrService.commodityOrService = commodityDoc;
                                    [appDelegate.commodityOrServiceArray_Selected addObject:newCommodityOrService];
                                }
                                
                            }else
                                [self showMessage:@"扫描成功，\n但您无权限查看商品信息！"];
                        }else
                            [self showMessage:@"扫描成功，\n但您无订单编辑权限！"];
                    }
                }else
                    [self showMessage:@"扫描商品失败！"];
            }

        } failure:^(NSInteger code, NSString *error) {
            if (type == 0) {
                [self showMessage:@"扫描顾客失败！"];
            } else if (type == 2) {
                [self showMessage:@"扫描服务失败！"];
            } else if (type == 1) {
                [self showMessage:@"扫描商品失败！"];
            }
        }];
    } failure:^(NSError *error) {
        [self showMessage:@"获取二维码信息失败！"];
    }];
}
// 打卡
-(void)requestGetAttendanceByAccount:(NSString  *)Prama
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
     NSDictionary *par = @{@"Prama":Prama};
    _requestAttendanceByAccountOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/account/AttendanceByAccount" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            [SVProgressHUD showSuccessWithStatus2:message touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
    
}


@end
