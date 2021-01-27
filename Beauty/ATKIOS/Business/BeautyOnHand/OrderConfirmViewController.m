//
//  OrderConfirmViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-24.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "OrderConfirmViewController.h"
#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"

#import "SVProgressHUD.h"
#import "NormalEditCell.h"
#import "NumberEditCell.h"
#import "ContentEditCell.h"

#import "OrderDoc.h"
#import "ServiceDoc.h"
#import "ScheduleDoc.h"
#import "TreatmentDoc.h"
#import "CourseDoc.h"
#import "ContactDoc.h"
#import "OpportunityDoc.h"
#import "DEFINE.h"

#import "OrderListViewController.h"
#import "NavigationView.h"
#import "CusTabBarController.h"
#import "AppDelegate.h"
#import "FooterView.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "PayInfoViewController.h"
#import "UIButton+InitButton.h"
#import "UserDoc.h"
#import "OrderDetailViewController.h"

#import "GPBHTTPClient.h"
#import "OppStepObject.h"

#import "OppStepViewController.h"
#import "EcardInfo.h"

#import "SubOrderViewController.h"  
#import "DFChooseAlertView.h"
#import "DFTableCell.h"
#import "AwaitFinishOrder.h"
#import "WelfareDetailsViewController.h"
#import "WelfareRes.h"
#import "GPBHTTPClient.h"
#import "AppDelegate.h"


#define EditWidth   0.0f

@interface OrderConfirmViewController ()<OppStepVCDelegate>
{
    NSIndexPath *_index;
}
@property (weak, nonatomic) AFHTTPRequestOperation *getCustomerBenefitListOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddOrderOperation;
@property (nonatomic, weak) AFHTTPRequestOperation *requestProductPaid;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (assign, nonatomic) BOOL isShowedKeyboard;  // ProductAndPriceView中的TableView didSelectRow事件是否可用(该事件与UITapGestureRecognizer事件冲突)

@property (strong, nonatomic) UITextField *textField_Editing;
@property (strong, nonatomic) NSIndexPath *deleteIndexPath;
@property (strong, nonatomic) UserDoc *userDoc;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) NSDate *oldDate;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (nonatomic, assign) NSInteger orderList;
@property (nonatomic, assign) BOOL   refresh;
@property (nonatomic, strong) NSMutableIndexSet    *payedOrderIndexSet;

///是否可以用优惠券
@property (nonatomic, assign)BOOL isUseWelfare;
@property (nonatomic,strong) NSMutableArray *welfareDatas;

//@property (nonatomic,strong) NSMutableArray *orderConfirmServerDatas;
//@property (nonatomic,strong) NSMutableArray *orderConfirmProductDatas;


- (NSIndexPath *)indexPathForCellWithTextFiled:(UITextField *)textField;
@end

@implementation OrderConfirmViewController
@synthesize theOpportunityDoc;
@synthesize orderEditMode;
@synthesize isShowedKeyboard;
@synthesize userDoc,datePicker,pickerData,pickerView,inputAccessoryView;
@synthesize orderList;
@synthesize refresh;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    if (_requestAddOrderOperation && [_requestAddOrderOperation isExecuting]) {
        [_requestAddOrderOperation cancel];
    }
    _requestAddOrderOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    self.view.backgroundColor = kColor_Background_View;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    refresh = NO;
    [self initData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];


    isShowedKeyboard = NO;
    
    orderList = 0;
    
    userDoc = [[UserDoc alloc] init];
    userDoc.user_Id = ACC_ACCOUNTID;
    userDoc.user_Name = ACC_ACCOUNTName;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];

}

- (void)initData
{
    _welfareDatas = [NSMutableArray array];
//    selectWelfareRes = [[WelfareRes alloc]init];
//    selectWelfareRes.PolicyID = @"-1";
//    selectWelfareRes.PolicyName = @"不使用优惠券";
    if (orderEditMode == OrderEditModeConfirm1) {
        CustomerDoc *customerDoc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
        NSArray *serviceArray    = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected;
        NSArray *commodityArray  = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected;
        
        theOpportunityDoc = [[OpportunityDoc alloc] init];
        theOpportunityDoc.customerId = customerDoc.cus_ID;
        theOpportunityDoc.customerName = customerDoc.cus_Name;
        
        
            NSMutableString *string = [NSMutableString string];
            [string appendString:@"["];
            for (ServiceDoc *service in serviceArray) {
                [string appendFormat:@"{\"Code\":%lld,\"ProductType\":%d},", (long long)service.service_Code, 0];
            }
            
            for (CommodityDoc *commodityDoc in commodityArray) {
                [string appendFormat:@"{\"Code\":%lld,\"ProductType\":%d},", (long long)commodityDoc.comm_Code, 1];
            }
            
            if([[string substringFromIndex:string.length -1] isEqual:@","])
                [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
            
            [string appendString:@"]"];

            [self requestProductInfoCustomerID:customerDoc.cus_ID andJSON:string];
    }
    if (orderEditMode == OrderEditModeFavour) {
        CustomerDoc *customerDoc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
        theOpportunityDoc = [[OpportunityDoc alloc] init];
        theOpportunityDoc.customerId = customerDoc.cus_ID;
        theOpportunityDoc.customerName = customerDoc.cus_Name;
        
        [self.favouritestList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 isKindOfClass:[ServiceDoc class]]) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }];
        
        NSMutableString *string = [NSMutableString string];
        [string appendString:@"["];
        for (id product in self.favouritestList) {
            if ([product isKindOfClass:[ServiceDoc class]]) {
                [string appendFormat:@"{\"Code\":%lld,\"ProductType\":%d},", (long long)((ServiceDoc *)product).service_Code, 0];
            } else {
                [string appendFormat:@"{\"Code\":%lld,\"ProductType\":%d},", (long long)((CommodityDoc *)product).comm_Code, 1];
            }
        }
        
        if([[string substringFromIndex:string.length -1] isEqual:@","])
            [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
        
        [string appendString:@"]"];
        
        [self requestProductInfoCustomerID:customerDoc.cus_ID andJSON:string];
    }
    if (orderEditMode == OrderEditModeOlder) {
        CustomerDoc *customerDoc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
        theOpportunityDoc = [[OpportunityDoc alloc] init];
        theOpportunityDoc.customerId = customerDoc.cus_ID;
        theOpportunityDoc.customerName = customerDoc.cus_Name;

        theOpportunityDoc.productAndPriceDoc.productArray = [self.pastOrderArray mutableCopy];
        [self.tableView reloadData];
    }
    /*
    if (orderEditMode == OrderEditModeConfirm2) {
        
        NSMutableString *string = [NSMutableString string];
        [string appendString:@"["];
        [string appendFormat:@"{\"Code\":%lld,\"ProductType\":%ld},", (long long)theOpportunityDoc.productAndPriceDoc.productDoc.pro_Code, (long)theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type];
        if([[string substringFromIndex:string.length -1] isEqual:@","])
            [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
        
        [string appendString:@"]"];
        
        [self requestProductInfoOppCustomerID:theOpportunityDoc.customerId andJSON:string];
    }
     */
}

- (void)initTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:(kMenu_Type == 0 ? @"转成订单" : @"开单")];
    [self.view addSubview:navigationView];
    
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = YES;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if (IOS7 || IOS8) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    _initialTVHeight = _tableView.frame.size.height;

//    if (orderEditMode == OrderEditModeConfirm2 || ![[PermissionDoc sharePermission] rule_Oppotunity_Use]  || !RMO(@"|2|")) {
        FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"buttonLong_Confirm"] submitTitle:@"确定"  submitAction:@selector(confirmOrderAction)];
        [footerView showInTableView:_tableView];
//    }
//    else {
//        FooterView *footerView = [[FooterView alloc] initWithTarget:self
//                                                          submitImg:[UIImage imageNamed:@"button_AddOrderFromProduct"]
//                                                       submitAction:@selector(confirmOrderAction)
//                                                          deleteImg:[UIImage imageNamed:@"button_AddOpp"]
//                                                       deleteAction:@selector(confirmOppAction)];
//        [footerView showInTableView:_tableView];
//        
//    }
    

//    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"button_LoginAddOrder"] submitAction:@selector(confirmOrderAction)];
 //   [footerView showInTableView:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark - Keyboard Notification
-(void)keyboardDidShown:(NSNotification*)notification
{
    isShowedKeyboard = YES;
    
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
    _tableView.frame = tvFrame;
    [UIView commitAnimations];
    if (_textField_Editing) {
        [self scrollToTextField:_textField_Editing withOption:UITableViewScrollPositionMiddle];
    }
    if (self.textView_Selected) {
        [self scrollToTextView:self.textView_Selected];
    }

}

-(void)keyboardDidHidden:(NSNotification*)notification
{
    isShowedKeyboard = NO;
    
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _tableView.frame = tvFrame;
    [UIView commitAnimations];
}

- (void)scrollToTextField:(UITextField *)textField withOption:(UITableViewScrollPosition)position
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath* path = [_tableView indexPathForCell:cell];
    if(position == UITableViewScrollPositionTop && path.row - 2 >= 0)
        path = [NSIndexPath indexPathForRow:path.row - 2 inSection:path.section];
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:position animated:YES];
}


- (void)scrollToTextView:(UITextView *)textView
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview;
    }
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)dismissKeyBoard
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /*
     * 屏蔽UIButton的tap
     */
    
     if ([touch.view isKindOfClass:[UIButton class]]) {
     return NO;
     }
    /*
     NSLog(@"\n\n\n");
     NSLog(@"----superView:%@", touch.view);
     NSLog(@"----superView:%@", touch.view.superview);
     NSLog(@"----superView:%@", touch.view.superview.superview);
     NSLog(@"----superView:%@", touch.view.superview.superview.superview);
      */
    
     /*
     * 屏蔽UITableViewCell上的tap
      */
     UIView *view = nil;
     if (IOS6 || IOS8) {
     view = touch.view.superview;
     } else {
     view = touch.view.superview.superview;
     }
     
     NSLog(@"+++view:%@", view);
     if (isShowedKeyboard) {
//          if ([view isKindOfClass:[UITableViewCell class]]) {
//          NSIndexPath *indexPath = [_tableView indexPathForCell:((UITableViewCell *)view)];
//          ProductDoc *productDoc = nil;
//              NSString *title;
//              productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
//              if (productDoc.pro_Type == 0) {
//                  title = _orderConfirmServerDatas[indexPath.row];
//              }else {
//                  title = _orderConfirmProductDatas[indexPath.row];
//              }
//
//          if(indexPath.section > 0 &&  indexPath.section <= theOpportunityDoc.productAndPriceDoc.productArray.count)
//          productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
//               if ( indexPath.section != 0 &&
//              indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1  &&
//              ([title isEqualToString:@"会员价"]|| [title isEqualToString:@"完成次数"])) {
//              NSIndexPath *path = INDEX(_textField_Editing.tag);
//              return ( path.section == indexPath.section && ([title isEqualToString:@"优惠券"]|| [title isEqualToString:@"备注"]|| [title isEqualToString:@"输入备注"])) ? YES : NO;
//              }
//          }
         return YES;
     } else {
         if ([view isKindOfClass:[UITableViewCell class]]) {
             NSIndexPath *indexPath = [_tableView indexPathForCell:((UITableViewCell *)view)];
             ProductDoc *productDoc = nil;
             NSString *title;
            if(theOpportunityDoc.productAndPriceDoc.productArray.count == 1){
                 productDoc = theOpportunityDoc.productAndPriceDoc.productArray.firstObject;
            }else  if(theOpportunityDoc.productAndPriceDoc.productArray.count > 1){
                if (0 < indexPath.section && indexPath.section <= theOpportunityDoc.productAndPriceDoc.productArray.count) {
                     productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
                 }
             }
             if (productDoc.pro_Type == 0) {
                 title = productDoc.orderConfirmServerDatas[indexPath.row];
             }else {
                 title = productDoc.orderConfirmProductDatas[indexPath.row];
             }
             if ([title isEqualToString:@"e账户"]) {
                 return NO;
             }
             if ([title isEqualToString:@"优惠券"]) {
                 return NO;
             }
             if ([title isEqualToString:@"会员价"]) {
                 return NO;
             }
             if ([title isEqualToString:@"订单转入"]) {
                 return NO;
             }
             if ([title isEqualToString:@"数量"]|| [title isEqualToString:@"服务次数"] || [title isEqualToString:@"完成次数"]){
                 return NO;
             }
             }else{
                 return YES;
             }
        }
    return YES;
}

/*
 * 原来的点击相应方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /*
     * 屏蔽UIButton的tap
 
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    /*
    NSLog(@"\n\n\n");
    NSLog(@"----superView:%@", touch.view);
    NSLog(@"----superView:%@", touch.view.superview);
    NSLog(@"----superView:%@", touch.view.superview.superview);
    NSLog(@"----superView:%@", touch.view.superview.superview.superview);
    
    /*
     * 屏蔽UITableViewCell上的tap

    UIView *view = nil;
    if (IOS6 || IOS8) {
        view = touch.view.superview;
    } else {
        view = touch.view.superview.superview;
    }
    
    NSLog(@"+++view:%@", view);
    if (isShowedKeyboard) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            NSIndexPath *indexPath = [_tableView indexPathForCell:((UITableViewCell *)view)];
            ProductDoc *productDoc = nil;
            if(indexPath.section > 0 &&  indexPath.section <= theOpportunityDoc.productAndPriceDoc.productArray.count)
                productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
            int cellIndex = [self getTheProductCellInfo:productDoc indexPath:indexPath];
            
            if ( indexPath.section != 0 &&
                indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1  &&
//                (cellIndex == 7 || cellIndex == 9)) { 
                (cellIndex == 7 || cellIndex == 12)) {
                NSIndexPath *path = INDEX(_textField_Editing.tag);
                int textIndex = [self getTheProductCellInfo:productDoc indexPath:path];
//                return ( path.section == indexPath.section && (textIndex == 8 || textIndex == 10 || textIndex == 11)) ? YES : NO;
                return ( path.section == indexPath.section && (textIndex == 8 || textIndex == 13 || textIndex == 14)) ? YES : NO;
            }
        }

        return YES;
    } else {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            NSIndexPath *indexPath = [_tableView indexPathForCell:((UITableViewCell *)view)];
            ProductDoc *productDoc = nil;
            
            if(indexPath.section > 0 &&  indexPath.section <= theOpportunityDoc.productAndPriceDoc.productArray.count)
                productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
            
            int cellIndex = [self getTheProductCellInfo:productDoc indexPath:indexPath];

            if ( indexPath.section != 0 &&
                indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1  &&
                cellIndex == 7) {
                return NO;
            }
            if ( indexPath.section != 0 &&
                indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1  &&
//                (cellIndex == 2 || cellIndex == 1 || cellIndex == 9 || cellIndex == 6))
                (cellIndex == 2 || cellIndex == 1 || cellIndex == 12 || cellIndex == 6))
                return NO;
        }
    }
    return YES;
}
*/

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    //GPB-922
    if ([theOpportunityDoc.productAndPriceDoc.productArray count] == 0) {
        return 1;
    }
    else if ([theOpportunityDoc.productAndPriceDoc.productArray count] == 1) {
        return 2;
    } else {
        return [theOpportunityDoc.productAndPriceDoc.productArray count] + 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
     * 原来的逻辑
     if (section == 0) return 1;
     if (section == [theOpportunityDoc.productAndPriceDoc.productArray count] + 1) {
     return 2;
     } else {
     id order = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:section - 1];
     
     if ([order isKindOfClass:[ProductDoc class]]) {
     ProductDoc *productDoc = order;
     int count = 0;
     if (productDoc.pro_Type == 0)
     count = productDoc.pro_IsShowDiscountMoney ? 11 : 10;
     else
     count = productDoc.pro_IsShowDiscountMoney ? 8 : 7;
     
     if (productDoc.isCount && productDoc.pro_Type == 0) {
     count += 2;
     }
     //            if (productDoc.pro_MarketingPolicy == 1) {
     ++count;
     //            }
     return count;
     
     } else {
     return 1;
     }
     }
     */
    if (section == 0) return 1;
    if (section == [theOpportunityDoc.productAndPriceDoc.productArray count] + 1) {
        return 2;
    } else {
        id order = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:section - 1];
        if ([order isKindOfClass:[ProductDoc class]]) {
            ProductDoc *productDoc = order;
            return [self orderConfirmDatasWithProductDoc:productDoc].count;
        } else {
            return 1;
        }
    }
}

- (NSMutableArray *)orderConfirmDatasWithProductDoc:(ProductDoc *)productDoc
{
    if (productDoc.pro_Type == 0) { //服务
        if (productDoc.orderConfirmServerDatas) {
            productDoc.orderConfirmServerDatas = nil;
        }
        productDoc.orderConfirmServerDatas = [NSMutableArray arrayWithObjects:@"名称",@"美丽顾问",@"服务有效期",@"数量",@"服务次数",@"小计",@"e账户",@"会员价",@"订单转入",@"备注",@"输入备注内容", nil];
        NSInteger index = [productDoc.orderConfirmServerDatas indexOfObject:@"会员价"];
        if (self.isUseWelfare) {
            [productDoc.orderConfirmServerDatas insertObject:@"优惠券" atIndex:index + 1];
            index = [productDoc.orderConfirmServerDatas indexOfObject:@"优惠券"];
            if (productDoc.pro_IsShowWelfareInfo) {
                [productDoc.orderConfirmServerDatas insertObject:@"优惠券说明" atIndex:index + 1];
                index = [productDoc.orderConfirmServerDatas indexOfObject:@"优惠券说明"];
                productDoc.pro_IsShowDiscountMoney = YES;
            }
        }
        if (productDoc.pro_IsShowDiscountMoney) {
            [productDoc.orderConfirmServerDatas insertObject:@"成交价" atIndex:index + 1];
        }
        if (productDoc.isCount) {
            NSInteger index = [productDoc.orderConfirmServerDatas indexOfObject:@"订单转入"];
            if ([[PermissionDoc sharePermission] rule_PastPayment]){
                [productDoc.orderConfirmServerDatas insertObject:@"过去支付" atIndex:index + 1];
                if ([[PermissionDoc sharePermission] rule_PastFinished]){
                    [productDoc.orderConfirmServerDatas insertObject:@"完成次数" atIndex:index + 2];
                }
                
            }
            else{
                if ([[PermissionDoc sharePermission] rule_PastFinished]){
                    [productDoc.orderConfirmServerDatas insertObject:@"完成次数" atIndex:index + 1];
                }
            }
        }
        return productDoc.orderConfirmServerDatas;
        
    }else{
        if (productDoc.orderConfirmProductDatas) {
            productDoc.orderConfirmProductDatas = nil;
        }
        productDoc.orderConfirmProductDatas = [NSMutableArray arrayWithObjects:@"名称",@"美丽顾问",@"数量",@"小计",@"e账户",@"会员价",@"备注",@"输入备注内容", nil];
        NSInteger index = [productDoc.orderConfirmProductDatas indexOfObject:@"会员价"];
        if (self.isUseWelfare) {
            [productDoc.orderConfirmProductDatas insertObject:@"优惠券" atIndex:index + 1];
            index = [productDoc.orderConfirmProductDatas indexOfObject:@"优惠券"];
            if (productDoc.pro_IsShowWelfareInfo) {
                [productDoc.orderConfirmProductDatas insertObject:@"优惠券说明" atIndex:index + 1];
                index = [productDoc.orderConfirmProductDatas indexOfObject:@"优惠券说明"];
                productDoc.pro_IsShowDiscountMoney = YES;
            }
        }
        if (productDoc.pro_IsShowDiscountMoney) {
            [productDoc.orderConfirmProductDatas insertObject:@"成交价" atIndex:index + 1];
        }
        return productDoc.orderConfirmProductDatas;
    }
}
//
//// 单订单Count
//- (NSInteger)productCount:(ProductDoc *)productDoc
//{
//    NSInteger count;
//    if (productDoc.pro_Type == 0) { //服务
//        if (self.isUseWelfare) {
//            count  = 12; // 默认12个
//            if (productDoc.pro_IsShowDiscountMoney) {
//                count += 1;
//            }
//            if (productDoc.pro_IsShowWelfareInfo) {
//                count += 2;
//            }
//            if (productDoc.isCount) {
//                count +=2;
//            }
//        }else{
//            count  = 11; // 默认11个
//            count = productDoc.pro_IsShowDiscountMoney ? count + 1 : count;
//        }
//    }else{ //商品
//        if (self.isUseWelfare) { // 有优惠券
//            count = 11;
//            if (productDoc.pro_IsShowDiscountMoney) {
//                count += 1;
//            }
//            if (productDoc.pro_IsShowWelfareInfo) {
//                count +=2;
//            }
//        }else{ // 没有优惠券
//            count = 10;
//            count = productDoc.pro_IsShowDiscountMoney ? count + 1 : count;
//        }
//    }
//    return count;
//}

/*    
 *原来的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
        cell.titleLabel.text = @"顾客";
        cell.valueText.text  = theOpportunityDoc.customerName;
        [cell setAccessoryText:@""];
        return cell;
    }else if (indexPath.section == theOpportunityDoc.productAndPriceDoc.productArray.count + 1 )
    {
        switch (indexPath.row) {
            case 0:
            {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"总价";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOpportunityDoc.productAndPriceDoc.totalMoney];
                return cell;
            }
            case 1:
            {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"总优惠价";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOpportunityDoc.productAndPriceDoc.discountMoney];
                return cell;
            }
        }
    }
    else
    {
        id order = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
     
        if ([order isKindOfClass:[ProductDoc class]]) {
            ProductDoc *productDoc = order;
            int row = [self getTheProductCellInfo:productDoc indexPath:indexPath];
            NSLog(@"row =%d",row);
            
            /* 最新修改
             0---名称
             1---美丽顾问
             2---服务有效期
             3---数量
             4---服务次数
             5---原价（小计）
             6---会员账户
             7---会员价
             8---优惠券
             9---优惠券说明
             10---协议价
             11—订单转入
             12—过去支付
             13---完成次数
             14—备注栏
             15—备注内容
            
            switch (row) {
                case 0:
                {
                    static NSString *identity = @"cell_ProductName";
                    ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
                    if (cell == nil) {
                        cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identity];
                        cell.backgroundColor = [UIColor whiteColor];
                    }
                    cell.contentEditText.frame = CGRectMake(0, 0, 300, kTableView_HeightOfRow);
                    [cell setContentText:productDoc.pro_Name];
                    cell.contentEditText.textColor = [UIColor blackColor];
                    cell.userInteractionEnabled = NO;
                    return cell;
                    
                }
                    break;
                case 1:
                {
                    UIButton *addButton = [UIButton buttonWithTitle:@""
                                                             target:self
                                                           selector:@selector(chooseAccount:)
                                                              frame:CGRectMake(275.0f + EditWidth, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                                      backgroundImg:[UIImage imageNamed:@"order_changeRP"]
                                                   highlightedImage:nil];
                    addButton.tag = 1005;
                    
                    if (IOS6) {
                        addButton.frame = CGRectMake(285.0f + EditWidth, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
                    }
                    
                    NormalEditCell *cell = [self configNormalEditCell3:tableView indexPath:indexPath];
                    [cell.titleLabel setText:@"美丽顾问"];
                    if (!productDoc.pro_ResponsiblePersonName) {
                        productDoc.pro_ResponsiblePersonID = ACC_ACCOUNTID;
                        productDoc.pro_ResponsiblePersonName = ACC_ACCOUNTName;
                    }
                    [cell.valueText setText:productDoc.pro_ResponsiblePersonName];
                    cell.valueText.enabled = NO;
                    [cell setAccessoryText:@"      "];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    
                    UIButton *button = (UIButton *)[cell viewWithTag:1005];
                    UIButton *buttonMv = (UIButton *)[cell viewWithTag:1015];
                    
                    if (buttonMv) {
                        [buttonMv removeFromSuperview];
                    }
                    
                    if (button == nil) {
                        [cell addSubview:addButton];
                    }
                    
                    return cell;
                }
                    break;
                case 2:
                {
                    UIButton *addButton = [UIButton buttonWithTitle:@""
                                                             target:self
                                                           selector:@selector(chooseDate:)
                                                              frame:CGRectMake(275.0f + EditWidth, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                                      backgroundImg:[UIImage imageNamed:@"changeDate"]
                                                   highlightedImage:nil];
                    addButton.tag = 1009;
                    
                    if (IOS6) {
                        addButton.frame = CGRectMake(285.0f + EditWidth, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
                    }
                    NormalEditCell *cell = [self configNormalEditCell4:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"服务有效期";
                    cell.valueText.enabled = NO;
                    [cell setAccessoryText:@"      "];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
                    if (productDoc.pro_ExpirationTime && ![productDoc.pro_ExpirationTime isEqualToString:@""]) {
                        cell.valueText.text = productDoc.pro_ExpirationTime;
                    }else{
                        //                        NSDate *currentDate = [NSDate date];
                        //                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        //                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        cell.valueText.text = @"2099-12-31";//[dateFormatter stringFromDate:currentDate];
                        productDoc.pro_ExpirationTime = @"2099-12-31";
                    }
                    UIButton *button = (UIButton *)[cell viewWithTag:1009];
                    if (button == nil) {
                        [cell addSubview:addButton];
                    }
                    return cell;
                }
                    break;
                case 3:
                {
                    NumberEditCell *cell = [self configNumberEditCell:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"数量";
                    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)productDoc.pro_quantity];
                    return cell;
                }
                    break;
                case 4:
                {
                    if (productDoc.pro_UnitCourseCount == 0) {
                        NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                        cell.titleLabel.text = @"服务次数";
                        cell.valueText.text = [NSString stringWithFormat:@"不限次数"];
                        return cell;
                    } else {
                        NumberEditCell *cell = [self configNumberEditCell:tableView indexPath:indexPath];
                        cell.titleLabel.text = @"服务次数";
                        cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)productDoc.courseCount];
                        return cell;
                    }
                }
                    break;
                case 5:
                {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"小计";
                    cell.userInteractionEnabled = YES;
                    cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_TotalMoney];
                    return cell;
                }
                    break;
                case 6:
                {
                    NormalEditCell *cell = [self configCardCell:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"e账户";
                    cell.valueText.text = productDoc.cardName;
                    return cell;
                }
                    break;
                case 7:
                {
                    NormalEditCell *cell = [self configPrice:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"会员价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon,productDoc.pro_TotalCalcPrice];
                    return cell;
                }
                    break;
//                case 8:
//                {
//                    NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
//                    cell.titleLabel.text = @"成交价";
//                    if (![[PermissionDoc sharePermission] rule_OrderTotalSalePrice_Write]) { //!([[PermissionDoc sharePermission] rule_MyOrder_Write] &&
//                        cell.nocopyText.enabled = NO;
//                        cell.nocopyText.textColor = kColor_Black;
//                    }
//                    cell.nocopyText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_TotalSaleMoney];
//                    cell.nocopyText.tag = 1000;
//                    return cell;
//                }
//                    break;
                case 8:
                {
                    NormalEditCell *cell = [self configCardCell:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"优惠券";
                    cell.valueText.text = selectWelfareRes.PolicyName;
                    return cell;
                }
                    break;
                case 9:
                {
                    NormalEditCell *cell = [self configCardCell:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"优惠券说明";
                    cell.valueText.text =  @"优惠券说明。。。。。。。";
                    return cell;
                }
                    break;
                case 10:
                {
                    NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"成交价";
                    if (![[PermissionDoc sharePermission] rule_OrderTotalSalePrice_Write]) { //!([[PermissionDoc sharePermission] rule_MyOrder_Write] &&
                        cell.nocopyText.enabled = NO;
                        cell.nocopyText.textColor = kColor_Black;
                    }
                    cell.nocopyText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_TotalSaleMoney];
                    cell.nocopyText.tag = 1000;
                    return cell;

                }
                    break;
                case 11:
                {
                    
                    static NSString *CellTag = @"cellTag";
                    NormalEditCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTag];
                    
                    if (!cell) {
                        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellTag];
                        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(284.0f, 9.0f, 21.0f, 21.0f)];
                        button.userInteractionEnabled = NO;
                        [button setBackgroundImage:[UIImage imageNamed:@"zixun_Permit"] forState:UIControlStateNormal];
                        button.tag = 100;
                        [cell.contentView addSubview:button];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.titleLabel.text = @"订单转入";
                    cell.valueText.text = @"";
                    cell.valueText.userInteractionEnabled = NO;

                    UIButton *button = (UIButton *)[cell.contentView viewWithTag:100];
                    [button setBackgroundImage: (productDoc.isCount ? [UIImage imageNamed:@"zixun_Permit"]:[UIImage imageNamed:@"zixun_NoPermit"]) forState:UIControlStateNormal];
                    return cell;
                }
                    break;
                case 12:
                {
                    NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"    过去支付";
                    //                cell.nocopyText.enabled = OrderTotalSalePrice_Write;
                    //                cell.nocopyText.clearsOnBeginEditing = YES;
                    cell.nocopyText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_HaveToPay];
                    cell.nocopyText.tag = 1010;
                    return cell;
                }
                    break;
                case 13:
                {
                    NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"完成次数";
                    //                cell.nocopyText.enabled = OrderTotalSalePrice_Write;
                    //                cell.nocopyText.clearsOnBeginEditing = YES;
                    cell.nocopyText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_HaveToPay];
                    cell.nocopyText.tag = 1010;
                    return cell;
                }
                    break;
                case 14:
                {
                    NSString *identity = @"cell_ProductName";
                    ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
                    if (cell == nil) {
                        cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identity];
                        cell.backgroundColor = [UIColor whiteColor];
                    }
                    [cell setContentText:@"备注"];
                    cell.contentEditText.textColor = kColor_DarkBlue;
                    cell.userInteractionEnabled = NO;
                    
                    return cell;

                }
                    break;
                case 15:
                {
                    static NSString *identityRemark = @"cell_remark";
                    ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identityRemark];
                    if (cell == nil) {
                        cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identityRemark];
                        cell.backgroundColor = [UIColor whiteColor];
                    }
                    [cell setContentText:@""];
                    if (productDoc.pro_Remark) {
                        [cell setContentText:productDoc.pro_Remark];
                    } else {
                        cell.contentEditText.placeholder = @"输入备注内容";
                    }
                    
                    cell.userInteractionEnabled = YES;
                    [cell setDelegate:self];
                    cell.contentEditText.tag = TAG(indexPath);
                    return cell;

                }
                    break;
                default:
                    break;
            }
        } else {
            NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
            AwaitFinishOrder *awaitOrder = order;
            cell.titleLabel.text = awaitOrder.ProductName;
            cell.valueText.text = awaitOrder.statusText;
            return cell;
        }
    }
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}
*
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
        cell.titleLabel.text = @"顾客";
        cell.valueText.text  = theOpportunityDoc.customerName;
        [cell setAccessoryText:@""];
        return cell;
    }else if (indexPath.section == theOpportunityDoc.productAndPriceDoc.productArray.count + 1 )
    {
        switch (indexPath.row) {
            case 0:
            {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"总价";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOpportunityDoc.productAndPriceDoc.totalMoney];
                return cell;
            }
            case 1:
            {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"总优惠价";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOpportunityDoc.productAndPriceDoc.discountMoney];
                return cell;
            }
        }
    }
    else
    {
       
        id order = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
        
        if ([order isKindOfClass:[ProductDoc class]]) {
            ProductDoc *productDoc = order;
            NSString *title;
            if (productDoc.pro_Type == 0) {
                title = productDoc.orderConfirmServerDatas[indexPath.row];
            }else{
                title = productDoc.orderConfirmProductDatas[indexPath.row];
            }
            //            int row = [self getTheProductCellInfo:productDoc indexPath:indexPath];
            //            NSLog(@"row =%d",row);
            
            /* 最新修改
             0---名称
             1---美丽顾问
             2---服务有效期
             3---数量
             4---服务次数
             5---小计
             6---e账户
             7---会员价
             8---优惠券
             9---优惠券说明
             10---协议价
             11—订单转入
             12—过去支付
             13---完成次数
             14—备注
             15—输入备注内容
             */
            if ([title isEqualToString:@"名称"]) {
                static NSString *identity = @"cell_ProductName";
                ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
                if (cell == nil) {
                    cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identity];
                    cell.backgroundColor = [UIColor whiteColor];
                }
                cell.contentEditText.frame = CGRectMake(0, 0, 300, kTableView_HeightOfRow);
                [cell setContentText:productDoc.pro_Name];
                cell.contentEditText.textColor = [UIColor blackColor];
                cell.userInteractionEnabled = NO;
                return cell;
            }
            else   if ([title isEqualToString:@"美丽顾问"]) {
                UIButton *addButton = [UIButton buttonWithTitle:@""
                                                         target:self
                                                       selector:@selector(chooseAccount:)
                                                          frame:CGRectMake(275.0f + EditWidth, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                                  backgroundImg:[UIImage imageNamed:@"order_changeRP"]
                                               highlightedImage:nil];
                addButton.tag = 1005;
                
                if (IOS6) {
                    addButton.frame = CGRectMake(285.0f + EditWidth, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
                }
                
                NormalEditCell *cell = [self configNormalEditCell3:tableView indexPath:indexPath];
                [cell.titleLabel setText:@"美丽顾问"];
                if (!productDoc.pro_ResponsiblePersonName) {
                    productDoc.pro_ResponsiblePersonID = ACC_ACCOUNTID;
                    productDoc.pro_ResponsiblePersonName = ACC_ACCOUNTName;
                }
                [cell.valueText setText:productDoc.pro_ResponsiblePersonName];
                cell.valueText.enabled = NO;
                [cell setAccessoryText:@"      "];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                UIButton *button = (UIButton *)[cell viewWithTag:1005];
                UIButton *buttonMv = (UIButton *)[cell viewWithTag:1015];
                
                if (buttonMv) {
                    [buttonMv removeFromSuperview];
                }
                
                if (button == nil) {
                    [cell addSubview:addButton];
                }
                
                return cell;
            }
            
            else    if ([title isEqualToString:@"服务有效期"]) {
                UIButton *addButton = [UIButton buttonWithTitle:@""
                                                         target:self
                                                       selector:@selector(chooseDate:)
                                                          frame:CGRectMake(275.0f + EditWidth, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                                  backgroundImg:[UIImage imageNamed:@"changeDate"]
                                               highlightedImage:nil];
                addButton.tag = 1009;
                
                if (IOS6) {
                    addButton.frame = CGRectMake(285.0f + EditWidth, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
                }
                NormalEditCell *cell = [self configNormalEditCell4:tableView indexPath:indexPath];
                cell.titleLabel.text = @"服务有效期";
                cell.valueText.enabled = NO;
                [cell setAccessoryText:@"      "];
                cell.accessoryType = UITableViewCellAccessoryNone;
                ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
                if (productDoc.pro_ExpirationTime && ![productDoc.pro_ExpirationTime isEqualToString:@""]) {
                    cell.valueText.text = productDoc.pro_ExpirationTime;
                }else{
                    //                        NSDate *currentDate = [NSDate date];
                    //                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    //                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    cell.valueText.text = @"2099-12-31";//[dateFormatter stringFromDate:currentDate];
                    productDoc.pro_ExpirationTime = @"2099-12-31";
                }
                UIButton *button = (UIButton *)[cell viewWithTag:1009];
                if (button == nil) {
                    [cell addSubview:addButton];
                }
                return cell;
            }
            else   if ([title isEqualToString:@"数量"]) {
                NumberEditCell *cell = [self configNumberEditCell:tableView indexPath:indexPath];
                cell.titleLabel.text = @"数量";
                cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)productDoc.pro_quantity];
                return cell;
            }
            else   if ([title isEqualToString:@"服务次数"]) {
                if (productDoc.pro_UnitCourseCount == 0) {
                    NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"服务次数";
                    cell.valueText.text = [NSString stringWithFormat:@"不限次数"];
                    return cell;
                } else {
                    NumberEditCell *cell = [self configNumberEditCell:tableView indexPath:indexPath];
                    cell.titleLabel.text = @"服务次数";
                    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)productDoc.courseCount];
                    return cell;
                }
                
            }
            else  if ([title isEqualToString:@"小计"]) {
                NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
                cell.titleLabel.text = @"小计";
                cell.userInteractionEnabled = YES;
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_TotalMoney];
                return cell;
            }
            else  if ([title isEqualToString:@"e账户"]) {
                NormalEditCell *cell = [self configCardCell:tableView indexPath:indexPath];
                cell.titleLabel.text = @"e账户";
                cell.valueText.text = productDoc.cardName;
                return cell;
            }
            else  if ([title isEqualToString:@"会员价"]) {
                NormalEditCell *cell = [self configPrice:tableView indexPath:indexPath];
                cell.titleLabel.text = @"会员价";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon,productDoc.pro_TotalCalcPrice];
                return cell;
            }
            else  if ([title isEqualToString:@"优惠券"]) {
                NormalEditCell *cell = [self configCardCell:tableView indexPath:indexPath];
                cell.titleLabel.text = @"优惠券";
                cell.valueText.text = productDoc.welfareRes.PolicyName;
                return cell;
            }
            else  if ([title isEqualToString:@"优惠券说明"]) {
                NormalEditCell *cell = [self configCardCell:tableView indexPath:indexPath];
                cell.titleLabel.text = @"";
                cell.valueText.text = productDoc.welfareRes.PolicyDescription;
                return cell;
            }
            else  if ([title isEqualToString:@"成交价"]) {
                NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                cell.titleLabel.text = @"成交价";
                if (![[PermissionDoc sharePermission] rule_OrderTotalSalePrice_Write]) { //!([[PermissionDoc sharePermission] rule_MyOrder_Write] &&
                    cell.nocopyText.enabled = NO;
                    cell.nocopyText.textColor = kColor_Black;
                }
                cell.nocopyText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_TotalSaleMoney];
                cell.nocopyText.tag = 1000;
                return cell;
                
            }
            else   if ([title isEqualToString:@"订单转入"]) {
                static NSString *CellTag = @"cellTag";
                NormalEditCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTag];
                
                if (!cell) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellTag];
                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(284.0f, 9.0f, 21.0f, 21.0f)];
                    button.userInteractionEnabled = NO;
                    [button setBackgroundImage:[UIImage imageNamed:@"zixun_Permit"] forState:UIControlStateNormal];
                    button.tag = 100;
                    [cell.contentView addSubview:button];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.titleLabel.text = @"订单转入";
                cell.valueText.text = @"";
                cell.valueText.userInteractionEnabled = NO;
                
                UIButton *button = (UIButton *)[cell.contentView viewWithTag:100];
                [button setBackgroundImage: (productDoc.isCount ? [UIImage imageNamed:@"zixun_Permit"]:[UIImage imageNamed:@"zixun_NoPermit"]) forState:UIControlStateNormal];
                return cell;
                
            }
            
            else if ([title isEqualToString:@"过去支付"]) {
                NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
                cell.titleLabel.text = @"    过去支付";
                //                cell.nocopyText.enabled = OrderTotalSalePrice_Write;
                //                cell.nocopyText.clearsOnBeginEditing = YES;
                cell.nocopyText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, productDoc.pro_HaveToPay];
                cell.nocopyText.tag = 1010;
                return cell;
            }
            else if ([title isEqualToString:@"完成次数"]) {
                NumberEditCell *cell = [self configNumberEditCell:tableView indexPath:indexPath];
                cell.titleLabel.text = @"    完成次数";
                cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)productDoc.TgPastCount];
                return cell;
            }
            else if ([title isEqualToString:@"备注"]) {
                NSString *identity = @"cell_ProductName";
                ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
                if (cell == nil) {
                    cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identity];
                    cell.backgroundColor = [UIColor whiteColor];
                }
                [cell setContentText:@"备注"];
                cell.contentEditText.textColor = kColor_DarkBlue;
                cell.userInteractionEnabled = NO;
                
                return cell;
            }
            
            else if ([title isEqualToString:@"输入备注内容"]) {
                static NSString *identityRemark = @"cell_remark";
                ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identityRemark];
                if (cell == nil) {
                    cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identityRemark];
                    cell.backgroundColor = [UIColor whiteColor];
                }
                [cell setContentText:@""];
                if (productDoc.pro_Remark) {
                    [cell setContentText:productDoc.pro_Remark];
                } else {
                    cell.contentEditText.placeholder = @"输入备注内容";
                }
                
                cell.userInteractionEnabled = YES;
                [cell setDelegate:self];
                cell.contentEditText.tag = TAG(indexPath);
                return cell;
                
            }
        }
    }
    id order = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
    if ([order isKindOfClass:[AwaitFinishOrder class]]) {
        NormalEditCell *cell = [self configNormalEditCell1:tableView indexPath:indexPath];
        AwaitFinishOrder *awaitOrder = order;
        cell.titleLabel.text = awaitOrder.ProductName;
        cell.valueText.text = awaitOrder.statusText;
        return cell;
    }else{
        NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        return cell;
    }
    
}



#pragma mark -  返回正确的行号

//- (int)convertWithRow:(int)row productInfo:(ProductDoc *)productInfo;
//{
//    
//    int number;
//    if (productInfo.pro_Type == 0) { //服务
//        if (self.isUseWelfare) {
//               return [self realNumberWithProductInfo:productInfo row:row];
//            }else{
//             return  row;
//        }
//    }else{ // 商品
//        if (self.isUseWelfare) {
//            return  row;
//        }else{
//            return  row;
//        }
//    }
//    return number;
//    
//}
//- (int)realNumberWithProductInfo:(ProductDoc *)productInfo row:(int)row
//{
//    int count = 0 ;
//    if (productInfo.pro_IsShowDiscountMoney) {
//        switch (row) {
//            case 9:{
//                count = row + 1;
//            }
//                break;
//            case 10:{
//                count = row;
//            }
//                break;
//            case 11:{
//                count = row + 2;
//            }
//                break;
//            case 12:{
//                count = row + 2;
//            }
//                break;
//            default:
//                count = row;
//                break;
//        }
//
//    }else{
//        switch (row) {
//            case 9:{
//                count = row + 2;
//            }
//                break;
//            case 10:{
//                count = row + 4;
//            }
//                break;
//            case 11:{
//                count = row + 4;
//            }
//                break;
//            default:
//                count = row;
//                break;
//        }
//    }
//    return count;
//}

//- (int )getTheProductCellInfo:(ProductDoc *)productInfo indexPath:(NSIndexPath *)indexPath
//{
//    
//    if ([productInfo isKindOfClass:[AwaitFinishOrder class]]) {
//        return -1;
//    }
//    int row = (int)indexPath.row;
//   return  [self convertWithRow:row productInfo:productInfo];
//    /*
//     0---名称
//     1---美丽顾问
//     2---服务有效期
//     3---数量
//     4---会员账户
//     5---原价（小计）
//     6---折扣价
//     7---协议价
//     8---订单转入
//     9---过去支付
//     10---过去完成/过去交付
//     11--备注栏
//     12--备注内容
//     */
//    
//    /* 最新修改
//     0---名称
//     1---美丽顾问
//     2---服务有效期
//     3---数量
//     4---服务次数
//     5---原价（小计）
//     6---会员账户
//     7---会员价
//     8---协议价
//     9---订单转入
//     10---过去支付
//     11---完成次数
//     12--备注栏
//     13--备注内容
//     */
//    
//    /* 最新修改
//     0---名称
//     1---美丽顾问
//     2---服务有效期
//     3---数量
//     4---服务次数
//     5---原价（小计）
//     6---会员账户
//     7---会员价
//     8---协议价
//     9---优惠券
//     10---优惠券说明
//     11---协议价
//     12---订单转入
//     13---过去支付
//     14---完成次数
//     15--备注栏
//     16--备注内容
//     */
//  
//    /*
//     *原来的逻辑
//    if (productInfo.pro_Type == 0) {
//        //        if (row == 6 && productInfo.pro_MarketingPolicy != 1) {//不是折扣价
//        //            row = row + 1;
//        //        }
//        //        if (row > 6 && productInfo.pro_MarketingPolicy != 1) {
//        //            row = (int)indexPath.row + 1;
//        //        }
//        if (row > 7 && productInfo.pro_IsShowDiscountMoney == NO) {
//            row = row + 1;
//        }
//        if (row > 9 && !productInfo.isCount) {
//            row += 2;
//        }
//    } else {
//        if (indexPath.row >1 ) {
//            ++row;
//        }
//        if (row > 3) {
//            ++row;
//        }
//        //        if (row > 5 && productInfo.pro_MarketingPolicy != 1) {
//        //            ++row;
//        //        }
//        if (productInfo.pro_IsShowDiscountMoney == YES) {
//            if (row > 8) {
//                row += 3;
//            }
//        } else {
//            if (row > 7) {
//                row += 4;
//            }
//        }
//    }
//    return row;
//    */
//
//
//}

- (NormalEditCell *)configCardCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *identity = @"Card";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.userInteractionEnabled = NO;
    cell.valueText.textColor = kColor_Editable;
    [cell setAccessoryText:@""];
    return cell;
}

- (NormalEditCell *)configNormalEditCell1:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *identity = @"Product_NormalEditCell_NotEditing";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.userInteractionEnabled = NO;
    cell.valueText.textColor = [UIColor blackColor];
    [cell setAccessoryText:@""];
    return cell;
}

- (NormalEditCell *)configPrice:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *priceIdentity = @"priceIdentity";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:priceIdentity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:priceIdentity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.userInteractionEnabled = NO;
    cell.valueText.textColor = [UIColor blackColor];
    return cell;
}

- (NormalEditCell *)configNormalEditCell2:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identityEditing2 = @"Product_NormalEditCell_Editing";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identityEditing2];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyleNocopy:UITableViewCellStyleDefault reuseIdentifier:identityEditing2];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.nocopyText.userInteractionEnabled = YES;
    cell.nocopyText.keyboardType = UIKeyboardTypeDecimalPad;
    cell.nocopyText.textColor = kColor_Editable;
    cell.nocopyText.delegate = self;
    [cell setAccessoryText:@""];
    return cell;
}

- (NormalEditCell *)configNormalEditcount:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identityEditing2 = @"tgPast";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identityEditing2];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyleNocopy:UITableViewCellStyleDefault reuseIdentifier:identityEditing2];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.nocopyText.userInteractionEnabled = YES;
    cell.nocopyText.keyboardType = UIKeyboardTypeNumberPad;
    cell.nocopyText.textColor = kColor_Editable;
    cell.nocopyText.delegate = self;
//    cell.nocopyText.keyboardType = UIKeyboardTypeDecimalPad;
    [cell setAccessoryText:@""];
    return cell;

}

- (NormalEditCell *)configNormalEditCell3:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identity3 = @"EditCell3";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity3];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity3];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.userInteractionEnabled = YES;
    cell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
    cell.valueText.textColor = kColor_Editable;
    cell.valueText.delegate = self;
    cell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
    [cell setAccessoryText:@""];
    return cell;
}
- (NormalEditCell *)configNormalEditCell4:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identity4 = @"EditCell4";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity4];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity4];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.userInteractionEnabled = YES;
    cell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
    cell.valueText.textColor = kColor_Editable;
    cell.valueText.delegate = self;
    cell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
    [cell setAccessoryText:@""];
    return cell;
}
- (NumberEditCell *)configNumberEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identity5 = @"Product_NumberEditCell";
    NumberEditCell *cell = [tableView dequeueReusableCellWithIdentifier:identity5];
    if (cell == nil) {
        cell = [[NumberEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity5];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    cell.numberLabel.delegate = self;
    cell.minNum = 1;
    cell.maxNum = 100;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >0 && indexPath.section <= theOpportunityDoc.productAndPriceDoc.productArray.count) {
        
        id order = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
        if ([order isKindOfClass:[ProductDoc class]]) {
            ProductDoc *productDoc = order;
//            int remarkCell = [self getTheProductCellInfo:productDoc indexPath:indexPath];
            
            if(indexPath.row == 0){
                CGSize size = [productDoc.pro_Name sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByWordWrapping];
                if(size.height > 16)
                    return size.height + 18.f;
                else
                    return kTableView_HeightOfRow;
            }
            NSString *title;
            if (productDoc.pro_Type == 0) {
                title = productDoc.orderConfirmServerDatas[indexPath.row];
            }else{
                title = productDoc.orderConfirmProductDatas[indexPath.row];
            }
            if ([title isEqualToString:@"输入备注"]) {
                return kTableView_HeightOfRow > productDoc.pro_RemarkHeight ? kTableView_HeightOfRow :productDoc.pro_RemarkHeight;
            }
        }
        else
            return kTableView_HeightOfRow;
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

#pragma mark -
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //_pIndexPath(indexPath);
    NSLog(@"%lu", (unsigned long)theOpportunityDoc.productAndPriceDoc.productArray.count);
    ProductDoc *productDoc = nil;
    if (theOpportunityDoc.productAndPriceDoc.productArray.count == 1) {
        productDoc = theOpportunityDoc.productAndPriceDoc.productArray.firstObject;
    }else if (theOpportunityDoc.productAndPriceDoc.productArray.count > 1){
        if (0 < indexPath.section && indexPath.section <= theOpportunityDoc.productAndPriceDoc.productArray.count) {
            productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
        }
    }else{
        return;
    }
    NSString *title;
    if (productDoc.pro_Type == 0) {
        title = productDoc.orderConfirmServerDatas[indexPath.row];
    }else{
        title = productDoc.orderConfirmProductDatas[indexPath.row];
    }
    if ([title isEqualToString:@"e账户"]) {
        [self requestProductDiscount:productDoc];
    }
    if ([title isEqualToString:@"优惠券"]) {
        [self requestGetCustomerBenefitList:productDoc];
    }
    if ([title isEqualToString:@"会员价"]) {
        productDoc.pro_IsShowDiscountMoney = !productDoc.pro_IsShowDiscountMoney;
    }
    if ([title isEqualToString:@"订单转入"]) {
        productDoc.isCount = !productDoc.isCount;
    }
    if ([title isEqualToString:@"数量"]|| [title isEqualToString:@"服务次数"] || [title isEqualToString:@"完成次数"]){
    }
    [_tableView reloadData];
    //选择美丽顾问
    if(indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
       indexPath.row == 1 )
    {
        [self chooseAccount:[[tableView cellForRowAtIndexPath:indexPath]viewWithTag:1005]];
    }
    //选择服务有效期
    if(indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
       ( productDoc.pro_Type == 0 && indexPath.row == 2) )
    {
        [self chooseDate:[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:1009]];
    }
}

/*
 *
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //_pIndexPath(indexPath);
    NSLog(@"%lu", (unsigned long)theOpportunityDoc.productAndPriceDoc.productArray.count);
    ProductDoc *productDoc = nil;
    if (indexPath.section > 0 && indexPath.section <= theOpportunityDoc.productAndPriceDoc.productArray.count)
        productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
    
    int cellIndex = [self getTheProductCellInfo:productDoc indexPath:indexPath];
    
    //订单转入
//    if (indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
//        cellIndex == 9) {
    if (indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
        cellIndex == 12) {
        UIButton *button = (UIButton *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:100];;
        productDoc.isCount = !productDoc.isCount;
        [button setBackgroundImage: (productDoc.isCount ? [UIImage imageNamed:@"zixun_Permit"]:[UIImage imageNamed:@"zixun_NoPermit"]) forState:UIControlStateNormal];

        NSLog(@"the click ");
        if (productDoc.isCount) {
            if (productDoc.pro_HaveToPay > productDoc.pro_TotalSaleMoney) {
                productDoc.pro_HaveToPay = 0;
            }
            if ((productDoc.TgPastCount > productDoc.courseCount) && productDoc.pro_UnitCourseCount) {
                productDoc.TgPastCount = 1;
            }

            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section], [NSIndexPath indexPathForRow:indexPath.row + 2 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section], [NSIndexPath indexPathForRow:indexPath.row + 2 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDelay:0.1f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        CGSize size = self.tableView.contentSize;
        size.height +=  (productDoc.isCount ? kTableView_HeightOfRow : -kTableView_HeightOfRow);
        self.tableView.contentSize = size;
        [UIView commitAnimations];

    }
    //会员账户
    if (indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
        cellIndex == 6) {
#warning showError;
        [self choseCard:indexPath cellIndex:cellIndex];
    }
    //优惠券
    if (indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
        cellIndex == 9) {
        [self choseCard:indexPath cellIndex:cellIndex];
    }
    //显示隐藏折扣价
    if (indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
        cellIndex == 7) //( (productDoc.pro_Type == 1 && indexPath.row == 3) || (productDoc.pro_Type == 0 && indexPath.row == 4))
    {
        if (productDoc.pro_IsShowDiscountMoney) {
            productDoc.pro_IsShowDiscountMoney = NO;
            if (self.isUseWelfare) {
                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 2 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            }
        } else {
            productDoc.pro_IsShowDiscountMoney = YES;
            if (self.isUseWelfare) {
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 2 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];

            }
        }
        
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDelay:0.1f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        CGSize size = self.tableView.contentSize;
        size.height +=  (productDoc.pro_IsShowDiscountMoney ? kTableView_HeightOfRow : -kTableView_HeightOfRow);
        self.tableView.contentSize = size;
        [UIView commitAnimations];
    }
    
    //选择美丽顾问
    if(indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
        indexPath.row == 1 )
    {
        [self chooseAccount:[[tableView cellForRowAtIndexPath:indexPath]viewWithTag:1005]];
    }
    
//    if(indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
//       cellIndex == 2)
//    {
//        [self chooseSales:[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:1015]];
//    }
    //选择服务有效期
    if(indexPath.section != 0 && indexPath.section != [theOpportunityDoc.productAndPriceDoc.productArray count] + 1 &&
       ( productDoc.pro_Type == 0 && indexPath.row == 2) )
    {
        [self chooseDate:[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:1009]];
    }
}
*/


#pragma mark -  选择卡或者选择优惠券 接口
- (void)requestGetCustomerBenefitList:(ProductDoc *)pro{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"Type\":1,\"CustomerID\":%ld}", (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID];
    _getCustomerBenefitListOperation= [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCustomerBenefitList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            [_welfareDatas removeAllObjects];
            WelfareRes *welfareRes = [[WelfareRes alloc]init];
            welfareRes.BenefitID = @"-1";
            welfareRes.PolicyName = @"不使用优惠券";
            [_welfareDatas addObject:welfareRes];
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
                        if (pro.pro_TotalCalcPrice >= welfareRes.PRValue1.doubleValue) { // 会员价满足条件
                            [_welfareDatas addObject:welfareRes];
                        }
                    }
                }
            }
            [self  choseWelfareAndChangePrice:pro];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
}

- (void)requestProductDiscount:(ProductDoc *)pro
{
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"ProductCode\":%lld,\"ProductType\":%ld}", (long)theOpportunityDoc.customerId, pro.pro_Code, (long)pro.pro_Type];
    _requestAddOrderOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCardDiscountList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            pro.cardArray = [[NSMutableArray alloc] init];
            EcardInfo * ecard = [[EcardInfo alloc] init];
            ecard.CardName = @"不使用e账户";
            ecard.Discount = 1;
            ecard.CardID = -1;
            [pro.cardArray addObject:ecard];
            
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [pro.cardArray addObject:[[EcardInfo alloc] initWithDictionary:obj]];
            }];
            [self choseCardAndChangePrice:pro];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:@"获取会员信息出错，请重试!" touchEventHandle:^{}];
        }];
        
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark -  选择卡或者选择优惠券
//- (void)choseCard:(NSIndexPath *)index cellIndex:(int)cellIndex
//{
//    ProductDoc *pro = theOpportunityDoc.productAndPriceDoc.productArray[index.section - 1];
//    if (cellIndex == 6) {
//        [self requestProductDiscount:pro];
//    }
//    if (cellIndex == 9) {
//        [self requestGetCustomerBenefitList:pro];
//    }
//}

//- (void)choseCard:(NSIndexPath *)index
//{
//    ProductDoc *pro = theOpportunityDoc.productAndPriceDoc.productArray[index.section - 1];
//
//    [self requestProductDiscount:pro];
//}
- (void)choseCardAndChangePrice:(ProductDoc *)pro
{
    __weak typeof(self) weakSelf = self;
    DFChooseAlertView *alertView = [DFChooseAlertView DFchooseAlterTitle:@" 选择e账户" numberOfRow:pro.cardArray.count ChooseCells:^UITableViewCell *(DFChooseAlertView *alert, NSIndexPath *indexPath) {
        static NSString *cardCell = @"cardCell";
        DFTableCell *chooseCell = [alert.table dequeueReusableCellWithIdentifier:cardCell];
        if (!chooseCell) {
            chooseCell = [[DFTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cardCell];
            chooseCell.textLabel.font = kFont_Light_18;
            chooseCell.selectionStyle = UITableViewCellSelectionStyleNone;
            chooseCell.textLabel.textColor = kColor_Black;
        }
        EcardInfo *ecarInfo = pro.cardArray[indexPath.row];
        if (ecarInfo.Discount == 1) {
            chooseCell.textLabel.text = [NSString stringWithFormat:@"%@",ecarInfo.CardName];
        }else{
            chooseCell.textLabel.text = [NSString stringWithFormat:@"%@(%.2f)",ecarInfo.CardName, ecarInfo.Discount];
        }
        chooseCell.imageView.image = (pro.currentCard.CardID == ecarInfo.CardID ? [UIImage imageNamed:@"icon_Checked"]:[UIImage imageNamed:@"icon_unChecked"]);
        __weak DFTableCell *weakCell = chooseCell;
        chooseCell.layoutBlock = ^{
            weakCell.textLabel.frame = CGRectMake(9.0f, 9.0f, 200.0f, 20.0f);
            weakCell.imageView.frame = CGRectMake(225.0f, 2.0f, 36.0f, 36.0f);
        };
        return chooseCell;
        
    } selectionBlock:^(DFChooseAlertView *alert, NSIndexPath *selectedIndex) {
        EcardInfo *ecarInfo = pro.cardArray[selectedIndex.row];
        pro.currentCard = ecarInfo;
        pro.cardName = ecarInfo.CardName;
        pro.cardID = ecarInfo.CardID;
        if (selectedIndex.row >0 && pro.pro_MarketingPolicy == 2) {//如果促销价改变改 则促销价＊折扣率
            pro.pro_PromotionPrice = [OverallMethods notRounding:(pro.currentCard.Discount * pro.pro_BPrice) afterPoint:2];
            pro.pro_CalculatePrice = pro.pro_PromotionPrice;
            pro.pro_TotalCalcPrice = [OverallMethods notRounding:(pro.pro_PromotionPrice * pro.pro_quantity) afterPoint:2];
        }else {
            pro.pro_PromotionPrice = [OverallMethods notRounding:(pro.currentCard.Discount * pro.pro_Unitprice) afterPoint:2] ;
            pro.pro_CalculatePrice = pro.pro_PromotionPrice;
            pro.pro_TotalCalcPrice = [OverallMethods notRounding:(pro.pro_PromotionPrice * pro.pro_quantity) afterPoint:2] ;
        }
        pro.pro_TotalSaleMoney = pro.pro_TotalCalcPrice;
        
        theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
        theOpportunityDoc.productAndPriceDoc.totalMoney    = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
        [alert animateOut];
        
        pro.pro_IsShowWelfareInfo = NO;
        pro.welfareRes.BenefitID = @"-1";
        pro.welfareRes.PolicyName = @"不使用优惠券";
        pro.welfareRes.PolicyDescription = @"";
        
        [weakSelf.tableView reloadData];
    } buttonsArray:nil andClickButtonIndex:^(DFChooseAlertView *alert, UIButton *button, NSInteger index) {
        
    }];
    
    [alertView show];
}

- (void)choseWelfareAndChangePrice:(ProductDoc *)pro
{
    __weak typeof(self) weakSelf = self;
    DFChooseAlertView *alertView = [DFChooseAlertView DFchooseAlterTitle:@"选择优惠券" numberOfRow:_welfareDatas.count ChooseCells:^UITableViewCell *(DFChooseAlertView *alert, NSIndexPath *indexPath) {
        static NSString *cardCell = @"cardCell";
        DFTableCell *chooseCell = [alert.table dequeueReusableCellWithIdentifier:cardCell];
        if (!chooseCell) {
            chooseCell = [[DFTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cardCell];
            chooseCell.textLabel.font = kFont_Light_18;
            chooseCell.selectionStyle = UITableViewCellSelectionStyleNone;
            chooseCell.textLabel.textColor = kColor_Black;
        }
        WelfareRes *welfareRes =_welfareDatas[indexPath.row];
        chooseCell.textLabel.text = welfareRes.PolicyName;
        chooseCell.imageView.image = [welfareRes.BenefitID isEqualToString:pro.welfareRes.BenefitID] ? [UIImage imageNamed:@"icon_Checked"]:[UIImage imageNamed:@"icon_unChecked"];
        __weak DFTableCell *weakCell = chooseCell;
        chooseCell.layoutBlock = ^{
            weakCell.textLabel.frame = CGRectMake(9.0f, 9.0f, 200.0f, 20.0f);
            weakCell.imageView.frame = CGRectMake(225.0f, 2.0f, 36.0f, 36.0f);
        };
        return chooseCell;
        
    } selectionBlock:^(DFChooseAlertView *alert, NSIndexPath *selectedIndex) {
        WelfareRes *welfare =_welfareDatas[selectedIndex.row];
        pro.welfareRes = welfare;
        if ([ pro.welfareRes.BenefitID isEqualToString:@"-1"]) {
            pro.pro_IsShowWelfareInfo = NO;
            pro.pro_TotalSaleMoney = pro.pro_TotalCalcPrice;
        }else{
            pro.pro_IsShowWelfareInfo = YES;
//            pro.pro_CalculatePrice = pro.pro_PromotionPrice;
            pro.pro_TotalSaleMoney =  pro.pro_TotalCalcPrice -  pro.welfareRes.PRValue2.doubleValue;
        }
        
        //        pro.currentCard = ecarInfo;
        //        pro.cardName = ecarInfo.CardName;
        //        pro.cardID = ecarInfo.CardID;
        //        if (selectedIndex.row >0 && pro.pro_MarketingPolicy == 2) {//如果促销价改变改 则促销价＊折扣率
        //            pro.pro_PromotionPrice = [OverallMethods notRounding:(pro.currentCard.Discount * pro.pro_BPrice) afterPoint:2];
        //            pro.pro_CalculatePrice = pro.pro_PromotionPrice;
        //            pro.pro_TotalCalcPrice = [OverallMethods notRounding:(pro.pro_PromotionPrice * pro.pro_quantity) afterPoint:2];
        //        }else {
        //
        //            pro.pro_PromotionPrice = [OverallMethods notRounding:(pro.currentCard.Discount * pro.pro_Unitprice) afterPoint:2] ;
        //            pro.pro_CalculatePrice = pro.pro_PromotionPrice;
        //            pro.pro_TotalCalcPrice = [OverallMethods notRounding:(pro.pro_PromotionPrice * pro.pro_quantity) afterPoint:2] ;
        //        }
        //
        //        pro.pro_TotalSaleMoney = pro.pro_TotalCalcPrice;
        //
        //        theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
        //        theOpportunityDoc.productAndPriceDoc.totalMoney    = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
        [alert animateOut];
        [weakSelf.tableView reloadData];
        
    } buttonsArray:nil andClickButtonIndex:^(DFChooseAlertView *alert, UIButton *button, NSInteger index) {
        
    }];
    
    [alertView show];
}
#pragma mark -
#pragma mark - NumberEditCellDelegate
//GPB-922 begin
// 数量减少
- (void)chickLeftButton:(NumberEditCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _deleteIndexPath = [indexPath copy];
    
    if (indexPath.section == 0) {
        return;
    }
    [self.view endEditing:YES];
    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];

    NSString *title;
    if (productDoc.pro_Type == 0) {
        title = productDoc.orderConfirmServerDatas[indexPath.row];
    }else{
        title = productDoc.orderConfirmProductDatas[indexPath.row];
    }
    if ([title isEqualToString:@"数量"]) {
        [self quantityLeftRightButton:productDoc indexPath:indexPath type:0];
    }else if ([title isEqualToString:@"服务次数"]) {
        [self  CourseFrequencyLeftRightButton:productDoc indexPath:indexPath type:0];
    }else if ([title isEqualToString:@"完成次数"]) {
        [self  finishCountLeftRightButton:productDoc indexPath:indexPath type:0];
    }
}

/*
 *
// 数量减少
- (void)chickLeftButton:(NumberEditCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _deleteIndexPath = [indexPath copy];
    
    if (indexPath.section == 0) {
        return;
    }
    [self.view endEditing:YES];
    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
    
    int row = [self getTheProductCellInfo:productDoc indexPath:indexPath];
    
    if (row == 3) {
        [self quantityLeftRightButton:productDoc indexPath:indexPath type:0];
    } else if (row == 4) {
        [self  CourseFrequencyLeftRightButton:productDoc indexPath:indexPath type:0];
    } else if (row == 11) {
        [self  finishCountLeftRightButton:productDoc indexPath:indexPath type:0];
    }
    
}
*/
/**
 *
//GPB-922 end
// 数量增加
- (void)chickRightButton:(NumberEditCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (indexPath.section == 0) {
        return;
    }
    [self.view endEditing:YES];
    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
    int row = [self getTheProductCellInfo:productDoc indexPath:indexPath];

    if (row == 3) {
        [self quantityLeftRightButton:productDoc indexPath:indexPath type:1];
    } else if (row == 4) {
        [self  CourseFrequencyLeftRightButton:productDoc indexPath:indexPath type:1];
//    } else if (row == 11) {
    } else if (row == 14) {
        [self  finishCountLeftRightButton:productDoc indexPath:indexPath type:1];
    }
}
*/
// 数量增加
- (void)chickRightButton:(NumberEditCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (indexPath.section == 0) {
        return;
    }
    [self.view endEditing:YES];
    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
    NSString *title;
    if (productDoc.pro_Type == 0) {
        title = productDoc.orderConfirmServerDatas[indexPath.row];
    }else{
        title = productDoc.orderConfirmProductDatas[indexPath.row];
    }
    if ([title isEqualToString:@"数量"]) {
        [self quantityLeftRightButton:productDoc indexPath:indexPath type:1];
    }else if ([title isEqualToString:@"服务次数"]) {
        [self  CourseFrequencyLeftRightButton:productDoc indexPath:indexPath type:1];
    }else if ([title isEqualToString:@"完成次数"]) {
        [self  finishCountLeftRightButton:productDoc indexPath:indexPath type:1];
    }
}


//数量控制
- (void)quantityLeftRightButton:(ProductDoc *)pro indexPath:(NSIndexPath *)indexPath type:(int)type
{
    if (type == 0) {
        if (pro.pro_quantity > 0) {
            pro.pro_quantity--;
            if(pro.pro_quantity == 0 )
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认要删除该商品或服务吗？" message:nil delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                [alertView show];
            }
            if(pro.pro_quantity > 0)
                [self refreshPrice:pro];
        }
    } else {
        if(pro.pro_Type == 0 && pro.pro_quantity < 99)
            pro.pro_quantity ++;
        else if(pro.pro_Type == 1 && pro.pro_quantity < 9999)
            pro.pro_quantity ++;
        pro.courseCount = pro.pro_quantity * pro.pro_UnitCourseCount;
        [self refreshPriceAndCount:pro reloadIndexPath:indexPath ];
    }
}

//服务次数控制
- (void)CourseFrequencyLeftRightButton:(ProductDoc *)pro indexPath:(NSIndexPath *)indexPath type:(int)type
{
    if (type == 0) {
        if (pro.courseCount > 1) {
            --pro.courseCount;
        }
    } else {
        ++pro.courseCount;
    }
    [self.tableView reloadData];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

//过去完成次数控制
- (void)finishCountLeftRightButton:(ProductDoc *)pro indexPath:(NSIndexPath *)indexPath type:(int)type
{
    if (type == 0) {
        if (pro.TgPastCount > 0) {
            --pro.TgPastCount;
        }
    } else {
        NSLog(@"pastCount =%ld",(long)pro.TgPastCount);
        if ((pro.TgPastCount >= pro.courseCount) && pro.pro_UnitCourseCount != 0) {
            [SVProgressHUD showErrorWithStatus2:@"过去完成次数不应该超过商品数量!" touchEventHandle:^{}];
//            pro.TgPastCount = 1;
        } else {
            ++pro.TgPastCount;
        }
    }
    [self.tableView reloadData];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshPriceAndCount:(ProductDoc *)productDoc reloadIndexPath:(NSIndexPath *)indexPath
{
    productDoc.pro_TotalMoney     = productDoc.pro_quantity * productDoc.pro_Unitprice;
#warning add折扣价
    productDoc.pro_TotalCalcPrice = productDoc.pro_quantity * productDoc.pro_PromotionPrice;
    productDoc.pro_TotalSaleMoney = productDoc.pro_quantity * productDoc.pro_CalculatePrice;
    
    if(productDoc.pro_MarketingPolicy == 2 && productDoc.cardID ==0) // 促销 无卡
    {
        productDoc.pro_TotalCalcPrice = productDoc.pro_quantity * productDoc.pro_Unitprice;
        productDoc.pro_TotalSaleMoney =  productDoc.pro_quantity * productDoc.pro_Unitprice;
    }
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    if ([theOpportunityDoc.productAndPriceDoc.productArray count] > 1) {
        theOpportunityDoc.productAndPriceDoc.totalMoney = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
        theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
        [indexSet addIndex:[theOpportunityDoc.productAndPriceDoc.productArray count] + 1];
    }
    [indexSet addIndex:indexPath.section];
    productDoc.pro_IsShowWelfareInfo = NO;
    productDoc.pro_IsShowDiscountMoney = NO;
    productDoc.welfareRes.BenefitID = @"-1";
    productDoc.welfareRes.PolicyName = @"不使用优惠券";
    productDoc.welfareRes.PolicyDescription = @"";
//    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    [_tableView reloadData];
}
-(void)refreshPrice:(ProductDoc *) productDoc
{
    productDoc.pro_TotalMoney     = productDoc.pro_quantity * productDoc.pro_Unitprice;
#warning add折扣价
    productDoc.pro_TotalCalcPrice = productDoc.pro_quantity * productDoc.pro_PromotionPrice;
    productDoc.pro_TotalSaleMoney = productDoc.pro_quantity * productDoc.pro_CalculatePrice;
    
    if(productDoc.pro_MarketingPolicy == 2 && productDoc.cardID ==0) // 促销 无卡
    {
        productDoc.pro_TotalCalcPrice = productDoc.pro_quantity * productDoc.pro_Unitprice;
        productDoc.pro_TotalSaleMoney =  productDoc.pro_quantity * productDoc.pro_Unitprice;
    }
    productDoc.courseCount = productDoc.pro_quantity * productDoc.pro_UnitCourseCount;

    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    if ([theOpportunityDoc.productAndPriceDoc.productArray count] > 1) {
        theOpportunityDoc.productAndPriceDoc.totalMoney = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
        theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
        [indexSet addIndex:[theOpportunityDoc.productAndPriceDoc.productArray count] + 1];
    }
    [indexSet addIndex:_deleteIndexPath.section];
    
    productDoc.pro_IsShowWelfareInfo = NO;
    productDoc.pro_IsShowDiscountMoney = NO;
    productDoc.welfareRes.BenefitID = @"-1";
    productDoc.welfareRes.PolicyName = @"不使用优惠券";
    productDoc.welfareRes.PolicyDescription = @"";
    [_tableView reloadData];
    
//    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:_deleteIndexPath.section - 1];
        [self refreshPrice:productDoc];
        
        NSMutableArray *serviceArray    = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected;
        NSMutableArray *commodityArray  = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected;
        if (productDoc.pro_Type == 1 ) {
            
            for(int i = 0 ; i < [commodityArray count] ; i++)
            {
                CommodityDoc *item = [commodityArray objectAtIndex:i];
                //if(item.comm_Code == productDoc.pro_Code) //2014.9.9
                if(item.comm_ID == productDoc.pro_ID)
                    [commodityArray removeObjectAtIndex:i];
            }
        }
        else
        {
            for(int i = 0 ; i < [serviceArray count] ; i++)
            {
                ServiceDoc *item = [serviceArray objectAtIndex:i];
                //if(item.service_Code == productDoc.pro_Code) //2014.9.9
                if(item.service_ID == productDoc.pro_ID)
                    [serviceArray removeObjectAtIndex:i];
            }
        }
        [theOpportunityDoc.productAndPriceDoc.productArray removeObjectAtIndex:_deleteIndexPath.section -1];
        _deleteIndexPath = nil;
        [_tableView reloadData];
    }
    else
    {
        ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:_deleteIndexPath.section - 1];
        if (productDoc.pro_quantity == 0)
            productDoc.pro_quantity ++;
        [self refreshPrice:productDoc];
        _deleteIndexPath = nil;
        [_tableView reloadData];
    }
}

#pragma mark - 美丽顾问选择 & 日期选择
- (void)chooseAccount:(id) sender
{
    [_textField_Editing resignFirstResponder];
    [self.textView_Selected resignFirstResponder];

    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)[[button superview] superview];
    } else if (IOS6 || IOS8) {
        cell = (UITableViewCell *)[button superview];
    }
    _index = [_tableView indexPathForCell:cell];

    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:_index.section - 1];
    
    UserDoc *tmpUserDoc = [[UserDoc alloc] init];
    if (productDoc.pro_ResponsiblePersonID) {
        tmpUserDoc.user_Name = productDoc.pro_ResponsiblePersonName;
        tmpUserDoc.user_Id = productDoc.pro_ResponsiblePersonID;
    } else {
        tmpUserDoc.user_Id = 0;
        tmpUserDoc.user_Name = @"";
    }

    SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    [selectCustomer setSelectModel:0 userType:1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:@[tmpUserDoc]];
    selectCustomer.customerId = theOpportunityDoc.customerId;
    selectCustomer.delegate = self;
    selectCustomer.navigationTitle = @"选择美丽顾问";
    selectCustomer.personType = CustomePersonGroup;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

- (void)chooseSales:(id)sender
{
    [_textField_Editing resignFirstResponder];
    [self.textView_Selected resignFirstResponder];

    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)[[button superview] superview];
    } else if (IOS6 || IOS8) {
        cell = (UITableViewCell *)[button superview];
    }
    _index = [_tableView indexPathForCell:cell];
    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:_index.section - 1];
    
    UserDoc *tmpUserDoc = [[UserDoc alloc] init];
    if (productDoc.pro_SalesID) {
        tmpUserDoc.user_Name = productDoc.pro_SalesName;
        tmpUserDoc.user_Id = productDoc.pro_SalesID;
    } else {
        tmpUserDoc.user_Id = 0;
        tmpUserDoc.user_Name = @"";
    }

    SelectCustomersViewController *selectSales = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    [selectSales setSelectModel:0 userType:2 customerRange:CUSTOMEROFMINE defaultSelectedUsers:@[tmpUserDoc]];
    selectSales.customerId = theOpportunityDoc.customerId;
    selectSales.delegate = self;
    selectSales.navigationTitle = @"选择销售顾问";
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectSales];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    userDoc = [userArray firstObject];
    if (!_index)
        return;
    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:_index.section - 1];
    if (userDoc == nil) {
        userDoc = [[UserDoc alloc] init];
        userDoc.user_Name = @"";
    }
    productDoc.pro_ResponsiblePersonName = userDoc.user_Name;
    productDoc.pro_ResponsiblePersonID = userDoc.user_Id;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:_index.section]] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"meiliguwen is %@",userDoc.user_Name);
}

//销售顾问 更新
- (void)dismissViewControllerWithSelectedSales:(NSArray *)userArray
{
    userDoc = [userArray firstObject];
    if (!_index)
        return;
    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:_index.section - 1];
    if (userDoc == nil) {
        userDoc = [[UserDoc alloc] init];
        userDoc.user_Name = @"";
    }
    productDoc.pro_SalesName = userDoc.user_Name;
    productDoc.pro_SalesID = userDoc.user_Id;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:_index.section]] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"xiaoshouguwen is %@",userDoc.user_Name);
}

-(void)chooseDate:(id)sender
{
    [self.view endEditing:YES];
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)[[button superview] superview];
        
    } else if (IOS6 || IOS8) {
        cell = (UITableViewCell *)[button superview];
    }
    _index = [_tableView indexPathForCell:cell];
    _textField_Editing = ((NormalEditCell*)cell).valueText;
    [self scrollToTextField:_textField_Editing withOption:UITableViewScrollPositionTop];
    [self initialKeyboard];
}
#pragma mark - Initial Keyboard

- (void)initialKeyboard
{
    if(IOS7 || IOS6){
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [_actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    }
    if(!datePicker) {
        datePicker = [[UIDatePicker alloc] init];
        if (IOS8)
            datePicker.frame = CGRectMake(-8, 30, kSCREN_BOUNDS.size.width, 380);
        else
            datePicker.frame = CGRectMake(0, 20, kSCREN_BOUNDS.size.width, 390);
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:_index.section - 1];
    NSDate *theDate = [NSDate stringToDate:[[NSDate date].description substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
    if (theDate != nil && ![theDate  isEqual: @""]) {
        [datePicker setDate:theDate];
        _oldDate = [NSDate stringToDate:[productDoc.pro_ExpirationTime substringToIndex:10] dateFormat:@"yyyy-MM-dd"];;
    }
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        if(IOS8)
            [inputAccessoryView setFrame:CGRectMake(-8, 0, kSCREN_BOUNDS.size.width, 35)];
        else
            inputAccessoryView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, 35);
//        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
//        [doneBtn setTintColor:kColor_White];
//        
//        UIBarButtonItem *clearBtn =[[UIBarButtonItem alloc] initWithTitle:@"无有效期" style:UIBarButtonItemStyleDone target:self action:@selector(clear:)];
//        [clearBtn setTintColor:kColor_White];
//        
//        UIBarButtonItem *cancelBtn =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
//        [cancelBtn setTintColor:kColor_White];
//        
//        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft,clearBtn, cancelBtn ,doneBtn, nil];
//        [inputAccessoryView setItems:array];
        CGFloat width = kSCREN_BOUNDS.size.width / 3;
        UIButton *doneBtn = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(done:) frame:CGRectMake(0, 0, width, 35) titleColor:kColor_White backgroudColor:nil];
        UIButton *clearBtn = [UIButton buttonWithTitle:@"无有效期" target:self selector:@selector(clear:) frame:CGRectMake(0, 0, width, 35) titleColor:kColor_White backgroudColor:nil];
        UIButton *canceBtn = [UIButton buttonWithTitle:@"取消" target:self selector:@selector(cancel:) frame:CGRectMake(0, 0, width, 35) titleColor:kColor_White backgroudColor:nil];
        UIBarButtonItem *itemDoneBtn= [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
        UIBarButtonItem *itemClearBtn = [[UIBarButtonItem alloc]initWithCustomView:clearBtn];
        UIBarButtonItem *itemCanceBtn = [[UIBarButtonItem alloc]initWithCustomView:canceBtn];
        NSArray *array = @[itemClearBtn,itemCanceBtn,itemDoneBtn];
        [inputAccessoryView setItems:array];
    }
    if(IOS8){
        UIAlertController *alertCtrlr =[UIAlertController  alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(-8, 30, kSCREN_BOUNDS.size.width , 400)];
        view.backgroundColor = [UIColor whiteColor];
        [alertCtrlr.view addSubview:view];
        [alertCtrlr.view addSubview:inputAccessoryView];
        [alertCtrlr.view addSubview:datePicker];
        [self presentViewController:alertCtrlr animated:YES completion:nil];
    }else{
        [_actionSheet addSubview:datePicker];
        [_actionSheet addSubview:inputAccessoryView];
        
        [_actionSheet showInView:self.view];
        [_actionSheet setBounds:CGRectMake(0, 0, 320, 430)];
        [_actionSheet setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)dateChanged:(id)sender
{
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([datePicker.date timeIntervalSinceReferenceDate]  + 8*3600)];
    NSMutableString *dateString =[NSMutableString stringWithString: [newDate.description substringToIndex:10]];
    NSLog(@"%@", dateString);
    [dateString replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
    [dateString replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    }
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    newDate = [dateFormatter dateFromString:dateString];
    currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]]; //取出日期比较
    NSIndexPath *index = [_tableView indexPathForCell:cell];
    ProductDoc *product = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:index.section - 1];
    if([newDate compare:currentDate] == NSOrderedDescending || [newDate compare:currentDate] == NSOrderedSame){
        [_textField_Editing setText:[NSString stringWithFormat:@"%@", dateString]];
        product.pro_ExpirationTime = _textField_Editing.text;
    } else {
        return;
    }
}

- (void)done:(id)sender
{
    //[self dateChanged:nil];
    NSDate *newDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([datePicker.date timeIntervalSinceReferenceDate])+8*3600];
    NSMutableString *dateString =[NSMutableString stringWithString: [newDate.description substringToIndex:10]];
    NSLog(@"%@", dateString);
    [dateString replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
    [dateString replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]];
    newDate = [dateFormatter dateFromString:[newDate.description substringToIndex:10]];
    if ([newDate compare:currentDate] == NSOrderedAscending) {
        inputAccessoryView = nil;
        if(IOS8){
            datePicker = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }else
            [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"所选日期不能在今天之前" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
    }else{
        inputAccessoryView = nil;
        UITableViewCell *cell = nil;
        if (IOS7) {
            cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
        } else {
            cell = (UITableViewCell *)_textField_Editing.superview.superview;
        }
        NSIndexPath *index = [_tableView indexPathForCell:cell];
        ProductDoc *product = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:index.section - 1];
        [_textField_Editing setText:[NSString stringWithFormat:@"%@", dateString]];
        product.pro_ExpirationTime = _textField_Editing.text;
        if(IOS8){
            datePicker = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }else
            [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void)clear:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *furtureDate = [dateFormatter dateFromString:@"2099-12-31"];
    _textField_Editing.text = [dateFormatter stringFromDate:furtureDate];
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    }
    NSIndexPath *index = [_tableView indexPathForCell:cell];
    ProductDoc *product = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:index.section - 1];
    [datePicker setDate:furtureDate animated:YES];
    product.pro_ExpirationTime = [NSString stringWithString: _textField_Editing.text];
}

-(void)cancel:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    }
    NSIndexPath *index = [_tableView indexPathForCell:cell];
    ProductDoc *product = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:index.section - 1];
    _textField_Editing.text = [dateFormatter stringFromDate:_oldDate];
    product.pro_ExpirationTime =[NSString stringWithString: _textField_Editing.text];
    _oldDate = nil;
    inputAccessoryView = nil;
    if(IOS8){
        datePicker = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }else
        [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}
#pragma mark -
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = nil;

    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    
    NSIndexPath *index = [_tableView indexPathForCell:cell];
    textField.text = @"";
    _textField_Editing = textField;
    _textField_Editing.tag = TAG(index);
    [self scrollToTextField:textField withOption:UITableViewScrollPositionMiddle];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    
    if([((NumberEditCell *)cell).titleLabel.text isEqualToString:@"数量"]) //编辑数量
    {
        NSIndexPath *index = [_tableView indexPathForCell:cell];
        ProductDoc *product = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:index.section - 1];
        if(product.pro_Type == 0){
            if ([textField.text length] > 1 && ![string isEqualToString:@""])
                return NO;
        }else {
            if ([textField.text length] > 3 && ![string isEqualToString:@""])
                return NO;
        }
#warning ErrorTag
    } else if ([((NormalEditCell  *)cell).titleLabel.text isEqualToString:@"过去交付"]) {
        const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
        if (*ch == 0 ) return YES;
        if (*ch == 32) return NO;
        if ([textField.text length] > 2) {
            return NO;
        }
        
    } else { //修改价格
        const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
        if (*ch == 0 ) return YES;
        if (*ch == 32) return NO;
        
        if ([textField.text length] >= 10) {
            return NO;
        }
        
        if ([textField.text length] == 0 && [string isEqualToString:@"."]) {
            textField.text = @"0.";
            return NO;
        }
        
        if ([textField.text isEqualToString:@"0"] && [string isEqualToString:@"0"]) {
            textField.text = @"0";
            return NO;
        }
        
        NSRange decRange = [textField.text rangeOfString:@"."];
        
        
        if (decRange.length && [string isEqualToString:@"."]) {
            return NO;
        }
        
        return YES;
    }
    return YES;
}


//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    NSLog(@"-------%@", textField.text);
//    UITableViewCell *cell = nil;
//    if (IOS7) {
//        cell = (UITableViewCell *)textField.superview.superview.superview;
//    } else {
//        cell = (UITableViewCell *)textField.superview.superview;
//    }
//    NSIndexPath *index = [_tableView indexPathForCell:cell];
//    if (index.section ==0) {
//        return;
//    }
//    ProductDoc *product = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:index.section - 1];
//    int rowIndex = [self getTheProductCellInfo:product indexPath:index];
//    double money;
//    
//    if ([textField.text isEqual: @""]) {
//        //数量
//        if (rowIndex == 3) {
//            textField.text = [NSString stringWithFormat:@"%ld",(long)product.pro_quantity];
//        } else if (rowIndex == 4) {//服务次数
//            textField.text = [NSString stringWithFormat:@"%ld",(long)product.courseCount];
//        } else if (rowIndex == 8) {//协议价
//            textField.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, product.pro_TotalSaleMoney];
////        } else if (rowIndex == 10) {//过去支付
//        } else if (rowIndex == 13) {//过去支付
//  
//            textField.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, product.pro_HaveToPay];
////        }  else if (rowIndex == 11) {//完成次数
//        }  else if (rowIndex == 14) {//完成次数
//            product.TgPastCount = 1;
//            textField.text = [NSString stringWithFormat:@"%ld", (long)product.TgPastCount];
//        } else {
//            return;
//        }
//    } else {
//        //数量
//        if (rowIndex == 3) {
//            if([textField.text integerValue] == 0){
//                _deleteIndexPath = [index copy];
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认要删除该商品或服务吗？" message:nil delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
//                [alertView show];
//            }else {
//                NSInteger newQuantity = [textField.text integerValue];
//                product.pro_quantity = newQuantity;
//                product.courseCount = product.pro_UnitCourseCount * product.pro_quantity;
//                [self refreshPriceAndCount:product reloadIndexPath:index];
//            }
//        } else if (rowIndex == 4) {
//            NSInteger newCount = [textField.text integerValue];
//            product.courseCount = newCount;
//            [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
//        } else if (rowIndex == 8) { //协议价
//            money = [textField.text doubleValue];
//            NSLog(@"%f", money);
//            if (money < product.pro_HaveToPay && product.isCount) {
//                textField.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, product.pro_TotalSaleMoney];
//                [SVProgressHUD showErrorWithStatus2:@"支付价格不应该超过商品价!" touchEventHandle:^{}];
//            } else {
//                textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, money];
//                /*
//                 *  更新productAndPriceDoc数据
//                 */
//                product.pro_TotalSaleMoney = money;
//                product.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2Lf",product.pro_TotalSaleMoney/product.pro_quantity] doubleValue];
//                
//                theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
//                theOpportunityDoc.productAndPriceDoc.totalMoney    = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
//                
//                if ([theOpportunityDoc.productAndPriceDoc.productArray count] > 1) {
//                    NSMutableIndexSet *indexSetAll = [NSMutableIndexSet indexSet];
//                    [indexSetAll addIndex:(theOpportunityDoc.productAndPriceDoc.productArray.count + 1)];
//                    [_tableView reloadSections:indexSetAll withRowAnimation:UITableViewRowAnimationNone];
//                }
//                _textField_Editing = nil;
//                
//            }
////        } else if (rowIndex == 10) {//过去支付
//        } else if (rowIndex == 13) {//过去支付
//
//            money = [textField.text doubleValue];
//            
//            if (money > product.pro_TotalSaleMoney) {
//                textField.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, product.pro_HaveToPay];
//                [SVProgressHUD showErrorWithStatus2:@"支付价格不应该超过商品价!" touchEventHandle:^{}];
//            } else {
//                product.pro_HaveToPay = money;
//                textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, money];
//            }
//            _textField_Editing = nil;
////        }  else if (rowIndex == 11) {//完成次数
//        }  else if (rowIndex == 14) {//完成次数
//
//            product.TgPastCount = [textField.text integerValue]; //product.pro_TotalCount 无限次订单
//            if ((product.TgPastCount > product.courseCount) && product.pro_UnitCourseCount != 0) {
//                [SVProgressHUD showErrorWithStatus2:@"过去完成次数不应该超过商品数量!" touchEventHandle:^{}];
//                product.TgPastCount = 1;
//                textField.text = [NSString stringWithFormat:@"%ld", (long)product.TgPastCount];
//                
//            }
//            _textField_Editing = nil;
//        } else {
//            return;
//        }
//
//        /*
//        if([((NumberEditCell *)cell).titleLabel.text isEqualToString:@"数量"]){
//            
//            if([textField.text integerValue] == 0){
//                _deleteIndexPath = [index copy];
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认要删除该商品或服务吗？" message:nil delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
//                [alertView show];
//            }else {
//                NSInteger newQuantity = [textField.text integerValue];
//                product.pro_TotalSaleMoney = product.pro_TotalSaleMoney/product.pro_quantity * newQuantity;
//                product.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2f",product.pro_TotalSaleMoney/newQuantity] doubleValue];
//                product.pro_TotalMoney = product.pro_TotalMoney / product.pro_quantity * newQuantity;
//                product.pro_quantity = newQuantity;
//                theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
//                theOpportunityDoc.productAndPriceDoc.totalMoney    = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
//                
//                //刷新小计和优惠价
//                NSMutableArray *rowsAtIndexPaths = [NSMutableArray array];
//                [rowsAtIndexPaths addObject:[NSIndexPath indexPathForRow:index.row + 1 inSection:index.section]];
//                [rowsAtIndexPaths addObject:[NSIndexPath indexPathForRow:index.row + 2 inSection:index.section]];
//                [rowsAtIndexPaths addObject:[NSIndexPath indexPathForRow:index.row + 3 inSection:index.section]];
//
//                [_tableView reloadRowsAtIndexPaths:rowsAtIndexPaths withRowAnimation:UITableViewRowAnimationNone];
//                
//                //刷新总价
//                if ([theOpportunityDoc.productAndPriceDoc.productArray count] > 1) {
//                    NSMutableIndexSet *indexSetAll = [NSMutableIndexSet indexSet];
//                    [indexSetAll addIndex:(theOpportunityDoc.productAndPriceDoc.productArray.count + 1)];
//                    [_tableView reloadSections:indexSetAll withRowAnimation:UITableViewRowAnimationNone];
//                }
//            }
//        }else if (rowIndex == 8){
//            money = [textField.text doubleValue];
//            NSLog(@"%f", money);
//            if (money < product.pro_HaveToPay) {
//                textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, product.pro_TotalSaleMoney];
//                [SVProgressHUD showErrorWithStatus2:@"支付价格不应该超过商品价!" touchEventHandle:^{}];
//            } else {
//                textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, money];
//                
//                /*
//                 *  更新productAndPriceDoc数据
//                 */
//         /*
//                product.pro_TotalSaleMoney = money;
//                product.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2f",product.pro_TotalSaleMoney/product.pro_quantity] doubleValue];
//                
//                theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
//                theOpportunityDoc.productAndPriceDoc.totalMoney    = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
//                
//                if ([theOpportunityDoc.productAndPriceDoc.productArray count] > 1) {
//                    NSMutableIndexSet *indexSetAll = [NSMutableIndexSet indexSet];
//                    [indexSetAll addIndex:(theOpportunityDoc.productAndPriceDoc.productArray.count + 1)];
//                    [_tableView reloadSections:indexSetAll withRowAnimation:UITableViewRowAnimationNone];
//                }
//                _textField_Editing = nil;
//
//            }
//        } else if (rowIndex == 11) {
//            product.TgPastCount = [textField.text integerValue]; //product.pro_TotalCount 无限次订单
//            if ((product.TgPastCount > product.pro_quantity) && product.pro_TotalCount != 0) {
//                [SVProgressHUD showErrorWithStatus2:@"过去完成次数不应该超过商品数量!" touchEventHandle:^{}];
//                product.TgPastCount = 1;
//                textField.text = [NSString stringWithFormat:@"%ld", (long)product.TgPastCount];
//
//            }
//            _textField_Editing = nil;
//        
//        } else {
//            money = [textField.text doubleValue];
//
//            if (money > product.pro_TotalSaleMoney) {
//                textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, product.pro_HaveToPay];
//                [SVProgressHUD showErrorWithStatus2:@"支付价格不应该超过商品价!" touchEventHandle:^{}];
//            } else {
//                product.pro_HaveToPay = money;
//                textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, money];
//            }
//            _textField_Editing = nil;
//        }
//*/
//    }
//
//    
////    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
////    
////    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexPath.section - 1];
////    productDoc.pro_TotalSaleMoney = money;
////    productDoc.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2f",productDoc.pro_TotalSaleMoney/productDoc.pro_quantity] doubleValue];
////
////    theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
////    theOpportunityDoc.productAndPriceDoc.totalMoney    = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
////    
////    if ([theOpportunityDoc.productAndPriceDoc.productArray count] > 1) {
////        NSMutableIndexSet *indexSetAll = [NSMutableIndexSet indexSet];
////        [indexSetAll addIndex:(theOpportunityDoc.productAndPriceDoc.productArray.count + 1)];
////        [_tableView reloadSections:indexSetAll withRowAnimation:UITableViewRowAnimationNone];
////    }
////
////    _textField_Editing = nil;
//    
//}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"-------%@", textField.text);
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath *index = [_tableView indexPathForCell:cell];
    if (index.section ==0) {
        return;
    }
    ProductDoc *product = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:index.section - 1];
    NSString *title;
    if (product.pro_Type == 0) {
        title = product.orderConfirmServerDatas[index.row];
    }else{
        title = product.orderConfirmProductDatas[index.row];
    }
    
    double money;
    
    if ([textField.text isEqual: @""]) {
        //数量
        if ([title isEqualToString:@"数量"]) {
            textField.text = [NSString stringWithFormat:@"%ld",(long)product.pro_quantity];
        }else if ([title isEqualToString:@"服务次数"]){
            textField.text = [NSString stringWithFormat:@"%ld",(long)product.courseCount];
        }else if ([title isEqualToString:@"成交价"]){
            textField.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, product.pro_TotalSaleMoney];
        }else if ([title isEqualToString:@"过去支付"]){
            textField.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, product.pro_HaveToPay];
        }else if ([title isEqualToString:@"完成次数"]){
            product.TgPastCount = 1;
            textField.text = [NSString stringWithFormat:@"%ld", (long)product.TgPastCount];
        }else{
            return;
        }
    } else {
        //数量
        if ([title isEqualToString:@"数量"]) {
            if([textField.text integerValue] == 0){
                _deleteIndexPath = [index copy];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认要删除该商品或服务吗？" message:nil delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                [alertView show];
            }else {
                NSInteger newQuantity = [textField.text integerValue];
                product.pro_quantity = newQuantity;
                product.courseCount = product.pro_UnitCourseCount * product.pro_quantity;
                [self refreshPriceAndCount:product reloadIndexPath:index];
            }
        }else if ([title isEqualToString:@"服务次数"]){
            NSInteger newCount = [textField.text integerValue];
            product.courseCount = newCount;
            [self.tableView reloadData];
//            [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        }else if ([title isEqualToString:@"成交价"]){
            money = [textField.text doubleValue];
            NSLog(@"%f", money);
            if (money < product.pro_HaveToPay && product.isCount) {
                textField.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, product.pro_TotalSaleMoney];
                [SVProgressHUD showErrorWithStatus2:@"支付价格不应该超过商品价!" touchEventHandle:^{}];
            }
       else{
           textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, money];
           /*
            *  更新productAndPriceDoc数据
            */
           product.pro_TotalSaleMoney = money;
           product.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2Lf",product.pro_TotalSaleMoney/product.pro_quantity] doubleValue];
           
           theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
           theOpportunityDoc.productAndPriceDoc.totalMoney    = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
           
           if ([theOpportunityDoc.productAndPriceDoc.productArray count] > 1) {
               NSMutableIndexSet *indexSetAll = [NSMutableIndexSet indexSet];
               [indexSetAll addIndex:(theOpportunityDoc.productAndPriceDoc.productArray.count + 1)];
               [_tableView reloadSections:indexSetAll withRowAnimation:UITableViewRowAnimationNone];
           }
           _textField_Editing = nil;
       }
    } else if ([title isEqualToString:@"过去支付"]) {//过去支付
            
            money = [textField.text doubleValue];
            
            if (money > product.pro_TotalSaleMoney) {
                textField.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, product.pro_HaveToPay];
                [SVProgressHUD showErrorWithStatus2:@"支付价格不应该超过商品价!" touchEventHandle:^{}];
            } else {
                product.pro_HaveToPay = money;
                textField.text = [NSString stringWithFormat:@"%@%.2f", MoneyIcon, money];
            }
            _textField_Editing = nil;
        }  else if ([title isEqualToString:@"完成次数"]) {//完成次数
            
            product.TgPastCount = [textField.text integerValue]; //product.pro_TotalCount 无限次订单
            if ((product.TgPastCount > product.courseCount) && product.pro_UnitCourseCount != 0) {
                [SVProgressHUD showErrorWithStatus2:@"过去完成次数不应该超过商品数量!" touchEventHandle:^{}];
                product.TgPastCount = 1;
                textField.text = [NSString stringWithFormat:@"%ld", (long)product.TgPastCount];
                
            }
            _textField_Editing = nil;
        } else {
            return;
        }
     }
}

#pragma mark - 备注输入代理
- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    contentText.returnKeyType = UIReturnKeyDefault;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    self.textView_Selected = textView;
    [self scrollToTextView:self.textView_Selected];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:textView];
}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 300) {
                textView.text = [toBeString substringToIndex:300];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 300) {
            textView.text = [toBeString substringToIndex:300];
        }
    }
    
    NSIndexPath *indexText = INDEX(textView.tag);
    ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexText.section - 1];
    productDoc.pro_Remark = textView.text;

}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [self.textView_Selected resignFirstResponder];
//    [cell textViewDidChange:textView];  //修正超过300字后多余空白 但会引起崩溃

    self.textView_Selected = nil;
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
//    [self scrollToTextView:contentText];

    NSIndexPath *indexRemark = [_tableView indexPathForCell:cell];

    if (indexRemark.section >= 1 && indexRemark.section <= theOpportunityDoc.productAndPriceDoc.productArray.count) {
        ProductDoc *productDoc = [theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:indexRemark.section - 1];
        productDoc.pro_Remark = contentText.text;
        productDoc.pro_RemarkHeight = height;

        [_tableView scrollToRowAtIndexPath:indexRemark atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [_tableView beginUpdates];
        [_tableView endUpdates];
    }
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView:(UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [_tableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        _prevCaretRect = newCursorRect;
        [self.tableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(300.0f, 500.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    if (textViewSize.width < 300) {
        textViewSize.width = 300;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
//    [_tableView beginUpdates];
//    [_tableView endUpdates];
}

- (NSIndexPath *)indexPathForCellWithTextFiled:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)[[[textField superview] superview] superview];
    } else if (IOS6 || IOS8) {
        cell = (UITableViewCell *)[[textField superview] superview];
    }
    return [_tableView indexPathForCell:cell];
}

#pragma mark UIScrollViewDelegate

//只要滚动了就会触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [_textField_Editing resignFirstResponder];
}

#pragma mark -
#pragma mark - Submit

- (void)confirmOrderAction
{
    [self.view endEditing:YES];
    
    if([theOpportunityDoc.productAndPriceDoc.productArray count] == 0){
         [SVProgressHUD showErrorWithStatus2:@"请先选择商品或服务！" touchEventHandle:^{}];
        return;
    }
    // 总服务次数
    NSInteger courseCountTotal= 0;
    // 过去完成次数
    NSInteger TgPastCountTotal= 0;
    // 总应付金额
    long double priceTotal = 0.00;
    // 总已支付金额
    long double pricePastTotal = 0.00;
    // 服务数量
    NSInteger serviceKindNum = 0;
    // 商品数量
    NSInteger goodKindNum = 0;
    // 多开标志
    Boolean multipleFlg = NO;
    if ([theOpportunityDoc.productAndPriceDoc.productArray count] > 1) {
        multipleFlg = YES;
    }
    for (ProductDoc *productDoc in theOpportunityDoc.productAndPriceDoc.productArray) {
        if (productDoc.pro_ResponsiblePersonID <=0 && productDoc.pro_Type ==1 ) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"商品单美丽顾问不能为空！"]];
            return;
        }
        switch (productDoc.pro_Type) {
            case 0:
                // 服务
                serviceKindNum++;
                break;
            case 1:
                // 商品
                goodKindNum++;
                break;
            default:
                break;
        }
        courseCountTotal += productDoc.courseCount;
        TgPastCountTotal += productDoc.TgPastCount;
        priceTotal += productDoc.pro_TotalSaleMoney;
        pricePastTotal += productDoc.pro_HaveToPay;
    }
    [self appendJSONString:1];
#warning xigai
    if (serviceKindNum > 0) {
        // 服务
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"内容" preferredStyle:UIAlertControllerStyleAlert];
        // UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        NSString *tmp;
        NSString *content = @"";
        content = [content stringByAppendingString:@"待结账金额"];
        NSInteger lenPos1 = [content length];
        tmp = [NSString stringWithFormat:@"%.2Lf",  priceTotal - pricePastTotal > 0.00 ? priceTotal - pricePastTotal : 0.00];
        NSInteger len1 = [tmp length];
        content = [content stringByAppendingString:tmp];
        content = [content stringByAppendingString:@"元"];
        
        content = [content stringByAppendingFormat:@"\n%@" , @"未服务次数"];
        NSInteger lenPos2 = [content length];
        tmp = [NSString stringWithFormat:@"%ld",  (long)(courseCountTotal - TgPastCountTotal > 0 ? courseCountTotal - TgPastCountTotal : 0)];
        NSInteger len2 = [tmp length];
        content = [content stringByAppendingString:tmp];
        content = [content stringByAppendingString:@"次"];
        
        NSInteger lenPos3 = -1;
        NSInteger len3 = -1;
        NSInteger lenPos4 = -1;
        NSInteger len4 = -1;
        tmp = @"";
        if (multipleFlg) {
            content = [content stringByAppendingFormat:@"\n%@" , @"此单共开:"];
            // 服务
            if (serviceKindNum > 0) {
                lenPos3 = [content length];
                tmp = [NSString stringWithFormat:@"%ld", (long)(serviceKindNum > 0 ? serviceKindNum : 0)];
                len3 = [tmp length];
                content = [content stringByAppendingString:tmp];
                content = [content stringByAppendingString:@"种服务"];
                tmp = @"/";
            }
            // 商品
            if (goodKindNum > 0) {
                content =[content stringByAppendingString:tmp];
                lenPos4 = [content length];
                tmp = [NSString stringWithFormat:@"%ld",  (long)(goodKindNum > 0 ? goodKindNum : 0)];
                len4 = [tmp length];
                content = [content stringByAppendingString:tmp];
                content = [content stringByAppendingString:@"种商品"];
            }
        }
        
        NSInteger length  = [content  length];
        content = [content stringByAppendingFormat:@"\n%@" , @"提醒:\n待结账金额=成交价-过去支付金额\n未服务次数=总服务次数-过去完成次数"];
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString: content];
    //    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:70/255.0 green:130/255.0 blue:200/255.0 alpha:1.0] range:NSMakeRange(0, length)];
    //    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, length)];
    //    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, length)];
        NSDictionary * attriBute3 = @{NSForegroundColorAttributeName:[UIColor colorWithRed:70/255.0 green:130/255.0 blue:200/255.0 alpha:1.0] ,NSFontAttributeName:[UIFont systemFontOfSize:17]};
        [alertControllerMessageStr addAttributes:attriBute3 range:NSMakeRange(0, length)];
        NSDictionary * attriBute = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:12]};
        [alertControllerMessageStr addAttributes:attriBute range:NSMakeRange(length, [content length] - length)];
        NSDictionary * attriBute2 = @{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:17]};
        [alertControllerMessageStr addAttributes:attriBute2 range:NSMakeRange(lenPos1, len1)];
        [alertControllerMessageStr addAttributes:attriBute2 range:NSMakeRange(lenPos2, len2)];
        if (lenPos3 != -1 && len3 != -1) {
            [alertControllerMessageStr addAttributes:attriBute2 range:NSMakeRange(lenPos3, len3)];
        }
        if (lenPos4 != -1 && len4 != -1) {
            [alertControllerMessageStr addAttributes:attriBute2 range:NSMakeRange(lenPos4, len4)];
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineSpacing = 10; // 调整行间距
        // paragraphStyle.firstLineHeadIndent = 4;//首行缩进
        NSRange range = NSMakeRange(0, [content length]);
        [alertControllerMessageStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        [alertVc setValue:alertControllerMessageStr forKey:@"attributedMessage"];
        
        //默认只有标题 没有操作的按钮:添加操作的按钮 UIAlertAction
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // 返回
        }];
        //添加确定
        UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull   action) {
            // 确定
            [self requestAddNewOrder];
        }];
        //设置`确定`按钮的颜色
        [sureBtn setValue:[UIColor redColor] forKey:@"titleTextColor"];
        //将action添加到控制器
        [alertVc addAction:cancelBtn];
        [alertVc addAction:sureBtn];
        // 展示
        [self presentViewController:alertVc animated:YES completion:nil];
    } else {
        [self requestAddNewOrder];
    }
    // [self requestAddNewOrder];
//    [self requestAddOrder];
}

#pragma mark OppStepVC Delegate
- (void)oppStepVCDidFinishChooseOppStep {
    [self appendJSONString:0];
    [self requestAddOppuratity];

}
// 拼接json字符串

-(void)appendJSONString:(NSInteger)branch
{
    NSMutableString *productString = [[NSMutableString alloc]init];
    //[productString appendString:@"\"OrderList\":["];
    self.payedOrderIndexSet = [NSMutableIndexSet indexSet];
    int index = 0;
    for (ProductDoc *productDoc in theOpportunityDoc.productAndPriceDoc.productArray) {
        //test
        if ([productDoc isKindOfClass:[ProductDoc class]]) {
            [productString appendFormat:@"{\"ProductID\":%ld,",(long)productDoc.pro_ID];
            [productString appendFormat:@"\"ProductCode\":%lld,",(long long)productDoc.pro_Code];
            [productString appendFormat:@"\"TaskID\":%lld,",(long  long)self.taskID];
            if (branch == 1) {
                [productString appendFormat:@"\"BranchID\":%ld,",(long)ACC_BRANCHID];
            } else {
                [productString appendFormat:@"\"StepID\":%ld,",(long)productDoc.oppStep.StepID];
            }
#warning addCard
            [productString appendFormat:@"\"CardID\":%ld,",(long)productDoc.cardID];
#warning addTGTotalCount
            [productString appendFormat:@"\"TGTotalCount\":%ld,",(long)productDoc.courseCount];
            
            //       [productString appendFormat:@"\"ProductName\":\"%@\",",productDoc.pro_Name];
            [productString appendFormat:@"\"Quantity\":%ld,",(long)productDoc.pro_quantity];
            //        [productString appendFormat:@"\"TotalPrice\":\"%.2f\",",productDoc.pro_TotalMoney];
            
            //是否计入统计
            [productString appendFormat:@"\"IsPast\":%d,",productDoc.isCount];
            
//            if (![productDoc.welfareRes.BenefitID isEqualToString:@"-1"]) {
//                [productString appendFormat:@"\"BenefitID\":%@,",productDoc.welfareRes.BenefitID];
//                [productString appendFormat:@"\"PRValue2\":%.2Lf,",productDoc.welfareRes.PRValue2.doubleValue];
//            }
            
            [productString appendFormat:@"\"TotalOrigPrice\":%.2Lf,",productDoc.pro_TotalMoney];
            
            [productString appendFormat:@"\"TotalCalcPrice\":%.2Lf,", productDoc.pro_TotalCalcPrice];
            
            if (productDoc.pro_TotalCalcPrice - productDoc.pro_TotalSaleMoney < 0.0001 && productDoc.pro_TotalCalcPrice - productDoc.pro_TotalSaleMoney > -0.0001 )
                [productString appendFormat:@"\"TotalSalePrice\":%d,",-1];
            else
                [productString appendFormat:@"\"TotalSalePrice\":%.2Lf,",productDoc.pro_TotalSaleMoney];
            if (productDoc.isCount && productDoc.pro_HaveToPay > 0) {
                [productString appendFormat:@"\"PaidPrice\":%.2Lf,", productDoc.pro_HaveToPay];
                if (productDoc.pro_HaveToPay == productDoc.pro_TotalSaleMoney) {
                    [self.payedOrderIndexSet  addIndex:index];
                }
            }
            
            if (productDoc.welfareRes.BenefitID && ![productDoc.welfareRes.BenefitID isEqualToString:@"-1"]) {
//                [productString appendFormat:@"\"BenefitID\":\"%@\"",productDoc.welfareRes.BenefitID];
                [productString appendFormat:@"\"BenefitID\":\"%@\",",productDoc.welfareRes.BenefitID];
                double PRValue2 = productDoc.welfareRes.PRValue2.doubleValue;
                [productString appendFormat:@"\"PRValue2\":%ld,",(long)PRValue2];
            }
            
            if (productDoc.isCount) {
                [productString appendFormat:@"\"TGPastCount\":%ld,", (long)productDoc.TgPastCount];
            }
            //0元订单
            if (productDoc.pro_TotalSaleMoney == 0) {
                [self.payedOrderIndexSet addIndex:index];
            }
            index++;
            
            [productString appendFormat:@"\"ProductType\":%ld,",(long)productDoc.pro_Type];
            [productString appendFormat:@"\"ResponsiblePersonID\":%ld,",(long)productDoc.pro_ResponsiblePersonID];
            if (productDoc.pro_SalesID != productDoc.pro_ResponsiblePersonID) {
                [productString appendFormat:@"\"SalesID\":%ld,",(long)productDoc.pro_SalesID];
            }
            [productString appendFormat:@"\"OpportunityID\":%ld,",(long)theOpportunityDoc.opp_ID];
            
           
            if (productDoc.pro_Type == 0 && productDoc.pro_ExpirationTime) {
                [productString appendFormat:@"\"ExpirationTime\":\"%@\",",productDoc.pro_ExpirationTime];
            }
            if(productDoc.pro_Remark == nil)
                productDoc.pro_Remark = @"";
            if (productDoc == [theOpportunityDoc.productAndPriceDoc.productArray lastObject])
                [productString appendFormat:@"\"Remark\":\"%@\"}",productDoc.pro_Remark];
            else
                [productString appendFormat:@"\"Remark\":\"%@\"},",productDoc.pro_Remark];
        }
    }
    theOpportunityDoc.strProductDetail = productString;
}

#pragma mark -
#pragma mark - 接口
- (void)requestProductInfoCustomerID:(NSInteger)customerID andJSON:(NSString *)jsondata
{
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"ProductCode\":%@}", (long)customerID, jsondata];

    _requestProductPaid = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Commodity/getProductInfoList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSMutableArray *tmpArray = [NSMutableArray array];
            for (NSDictionary *dic in (NSArray *)data ) {
                ProductDoc *pro = [[ProductDoc alloc] init];
                pro.pro_ID = [[dic objectForKey:@"ID"] integerValue];
                pro.pro_Code = [[dic objectForKey:@"Code"] longLongValue];
                pro.pro_Name = [dic objectForKey:@"Name"];
                pro.pro_Type = [[dic objectForKey:@"ProductType"] integerValue];
                pro.pro_Unitprice = [[dic objectForKey:@"UnitPrice"] doubleValue];
                if (pro.pro_Type == 0) {
                    pro.pro_ExpirationTime = [[dic objectForKey:@"ExpirationDate"] substringToIndex:10];
                    pro.pro_UnitCourseCount = [[dic objectForKey:@"CourseFrequency"] integerValue];
                    pro.courseCount = pro.pro_UnitCourseCount;
                }
                pro.pro_MarketingPolicy = [[dic objectForKey:@"MarketingPolicy"] integerValue];
                pro.pro_PromotionPrice = [[dic objectForKey:@"PromotionPrice"] doubleValue];
                pro.pro_BPrice = [[dic objectForKey:@"PromotionPrice"] doubleValue];

                
                pro.cardID = [[dic objectForKey:@"CardID"] integerValue];
                if ([[dic objectForKey:@"CardName"] isKindOfClass:[NSNull class]] ||[[dic objectForKey:@"CardName"] length] == 0 ) {
                    pro.cardName = @"不使用e账户";
                    pro.pro_CalculatePrice = pro.pro_Unitprice;
                } else {
                    pro.cardName = [dic objectForKey:@"CardName"];
                }
                EcardInfo *ecarInfo = [[EcardInfo alloc] initWithDictionary:@{@"CardID":@(pro.cardID),@"CardName":pro.cardName}];
                pro.currentCard = ecarInfo;
            
//                if (pro.pro_MarketingPolicy == 0) {
//                    pro.pro_CalculatePrice = pro.pro_Unitprice;
//                } else if (pro.pro_MarketingPolicy == 1) {
//#warning dis折扣价格~~~~
//                    pro.pro_CalculatePrice = pro.pro_PromotionPrice;
//                } else if (pro.pro_MarketingPolicy == 2) {
//                    pro.pro_CalculatePrice = pro.pro_PromotionPrice;
//                }
                if (pro.pro_MarketingPolicy == 0) {
                    pro.pro_CalculatePrice = pro.pro_Unitprice;
                } else if (pro.pro_MarketingPolicy == 1 || pro.pro_MarketingPolicy == 2) {
                    pro.pro_CalculatePrice = pro.pro_PromotionPrice;
                }
                
                pro.pro_quantity = 1;
                pro.TgPastCount = 0;
                pro.pro_TotalMoney     =  pro.pro_quantity * pro.pro_Unitprice;
                pro.pro_TotalCalcPrice = pro.pro_quantity *pro.pro_PromotionPrice;
                pro.pro_TotalSaleMoney =  pro.pro_quantity * pro.pro_PromotionPrice;
                if(pro.pro_MarketingPolicy == 2 && pro.cardID ==0)
                {
                    pro.pro_TotalCalcPrice = pro.pro_quantity * pro.pro_Unitprice;
                    pro.pro_TotalSaleMoney =  pro.pro_quantity * pro.pro_Unitprice;
                }
                //统计初始化为yes 修改为过去支付选项 默认为no
                pro.isCount = NO;
                pro.pro_IsShowDiscountMoney = NO;
                pro.pro_IsShowWelfareInfo = NO;

                if (self.userDic) {
                    pro.pro_ResponsiblePersonID = [self.userDic[@"AccID"] integerValue];
                    pro.pro_ResponsiblePersonName = self.userDic[@"AccName"];
                }
                
                [tmpArray addObject:pro];
                
            }
            NSSortDescriptor *desc = [[NSSortDescriptor alloc]initWithKey:@"pro_Type" ascending:YES];
            NSArray *array =  [tmpArray sortedArrayUsingDescriptors:@[desc]];
            theOpportunityDoc.productAndPriceDoc.productArray =[array mutableCopy];
            theOpportunityDoc.productAndPriceDoc.totalMoney    = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
            theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
            [theOpportunityDoc.productAndPriceDoc initIsShowDiscountMoney];
            
            /*
             *将老订单添加到商品订单数组
             */
            [theOpportunityDoc.productAndPriceDoc.productArray addObjectsFromArray:[self.pastOrderArray copy]];
            if (theOpportunityDoc.productAndPriceDoc.productArray.count == 1) { //单订单
                ProductDoc *pro = theOpportunityDoc.productAndPriceDoc.productArray.firstObject;
                pro.welfareRes = [[WelfareRes alloc]init];
                pro.welfareRes.BenefitID = @"-1";
                pro.welfareRes.PolicyName = @"不使用优惠券";
                self.isUseWelfare = YES;
            }else{
                self.isUseWelfare = NO;
            }
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}
- (NSMutableArray *)pastOrderArray
{
    if (_pastOrderArray == nil) {
        _pastOrderArray = [[NSMutableArray alloc] init];
    }
    return _pastOrderArray;
}

- (void)requestAddNewOrder
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
//    /Order/AddNewOrder 增加参数
//    OrderList数组对象中 增加所需属性
//    string BenefitID
//    decimal PRValue2
    
    NSArray *array = [self.pastOrderArray valueForKeyPath:@"@unionOfObjects.OrderID"];
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"OldOrderIDs\":[%@],\"OrderList\":[%@]}", (long)theOpportunityDoc.customerId, [array componentsJoinedByString:@","], theOpportunityDoc.strProductDetail];

    _requestAddOrderOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/AddNewOrder" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected removeAllObjects];
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected   removeAllObjects];
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityOrServiceArray_Selected   removeAllObjects];
            [self.pastOrderArray removeAllObjects];
            [self.favouritestList removeAllObjects];
            NSMutableString *strOrderID = [NSMutableString string];
            for (NSString *tmp in data) {
                [strOrderID appendFormat:@"%@,", tmp];
            }
            SubOrderViewController *subOrder = [[SubOrderViewController alloc] init];
            subOrder.orderList = [strOrderID substringToIndex:(strOrderID.length-1)];
            subOrder.customerName = theOpportunityDoc.customerName;
            subOrder.customerID = theOpportunityDoc.customerId;
            if (self.taskID >0) {
                subOrder.backMode = SubOrderViewBackOrderList;
            }else{
                subOrder.backMode = SubOrderViewBackOrderMain;
            }
            [self.navigationController pushViewController:subOrder animated:YES];
        } failure:^(NSInteger code, NSString *error) {
            [self handleErrorCode:code message:error];
        }];
    } failure:^(NSError *error) {
        
    }];
}


- (void)handleErrorCode:(NSInteger)errorCode message:(NSString *)errorMesag
{
    /*
     {"Data":null,"Code":"0","Message":"订单添加失败"}
     {"Data":[1,2,3],"Code":"1","Message":"订单添加成功"}
     {"Data":null,"Code":"2","Message":"订单添加失败)
     {"Data":null,"Code":"4","Message":"库存不足"}
     {"Data":null,"Code":"5","Message":"有购物车已转为订单"}
     {"Data":null,"Code":"6","Message":"操作失败"}
     {"Data":null,"Code":"-2","Message":"价格已变化"}
     */
    
    if (errorCode == -2) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMesag delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self initData];
            }
        }];
    } else {
        [SVProgressHUD showErrorWithStatus2:errorMesag touchEventHandle:^{}];
    }
    
}

#pragma mark --订单商机等功能取消

- (void)confirmOppAction
{
    [_textField_Editing resignFirstResponder];
    [self.textView_Selected resignFirstResponder];
    
    if([theOpportunityDoc.productAndPriceDoc.productArray count] == 0){
        [SVProgressHUD showErrorWithStatus2:@"请先选择商品或服务！" touchEventHandle:^{}];
        return;
    }
    
    for (ProductDoc *productDoc in theOpportunityDoc.productAndPriceDoc.productArray) {
        if (productDoc.pro_ResponsiblePersonID == 0 || [productDoc.pro_ResponsiblePersonName isEqualToString:@""])
        {
            [SVProgressHUD showErrorWithStatus2:@"服务或者商品的美丽顾问为空，不能暂存!" touchEventHandle:^{}];
            return;
        }
    }
    
//    
    [self chooseOppEnum];
}

- (void)chooseOppEnum {
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Opportunity/GetStepList" andParameters:nil failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if ([data count] > 1) {
                NSMutableArray *tmp = [NSMutableArray array];
                [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [tmp addObject:[[OppStepObject alloc] initWithDictionary:obj]];
                }];
                
                OppStepViewController *stepVC = [[OppStepViewController alloc] init];
                stepVC.stepArray = [tmp mutableCopy];
                stepVC.prodArray = theOpportunityDoc.productAndPriceDoc.productArray;
                stepVC.delegate = self;
                [self.navigationController pushViewController:stepVC animated:YES];
                
            } else {
                OppStepObject *oppStepObj = [[OppStepObject alloc] initWithDictionary:[data firstObject]];
                [theOpportunityDoc.productAndPriceDoc.productArray enumerateObjectsUsingBlock:^(ProductDoc *obj, NSUInteger idx, BOOL *stop) {
                    obj.oppStep = oppStepObj;
                }];
                [self appendJSONString:0];
                [self requestAddOppuratity];
                
            }
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestProductInfoOppCustomerID:(NSInteger)customerID andJSON:(NSString *)jsondata
{
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"ProductCode\":%@}", (long)customerID, jsondata];

    
    _requestProductPaid = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Commodity/getProductInfoList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            for (NSDictionary *dic in (NSArray *)data ) {
                theOpportunityDoc.productAndPriceDoc.productDoc.pro_ID = [[dic objectForKey:@"ID"] integerValue];
                theOpportunityDoc.productAndPriceDoc.productDoc.pro_Code = [[dic objectForKey:@"Code"] longLongValue];
                theOpportunityDoc.productAndPriceDoc.productDoc.pro_Name = [dic objectForKey:@"Name"];
                theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type = [[dic objectForKey:@"ProductType"] integerValue];
                theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice = [[dic objectForKey:@"UnitPrice"] doubleValue];
                if (theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type == 0) {
                    theOpportunityDoc.productAndPriceDoc.productDoc.pro_ExpirationTime = [[dic objectForKey:@"ExpirationDate"] substringToIndex:10];
                }
                
                theOpportunityDoc.productAndPriceDoc.productDoc.isCount = NO;
//                if ([dic objectForKey:@"IsAddUp"] == nil) {
//                    theOpportunityDoc.productAndPriceDoc.productDoc.isCount = NO;
//                } else {
//                    theOpportunityDoc.productAndPriceDoc.productDoc.isCount = [[dic objectForKey:@"IsAddUp"]boolValue];
//                }
                
                
                theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy = [[dic objectForKey:@"MarketingPolicy"] integerValue];
                theOpportunityDoc.productAndPriceDoc.productDoc.pro_PromotionPrice = [[dic objectForKey:@"PromotionPrice"] doubleValue];
                
                theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney     =  theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice * theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity;
            }
            if (refresh) {
                if (theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy == 0) {
                    theOpportunityDoc.productAndPriceDoc.productDoc.pro_CalculatePrice = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice;
                } else if (theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy == 1) {
                    theOpportunityDoc.productAndPriceDoc.productDoc.pro_CalculatePrice = theOpportunityDoc.productAndPriceDoc.productDoc.pro_PromotionPrice;
                } else if (theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy == 2) {
                    theOpportunityDoc.productAndPriceDoc.productDoc.pro_CalculatePrice = theOpportunityDoc.productAndPriceDoc.productDoc.pro_PromotionPrice;
                }
                theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney =  theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity * theOpportunityDoc.productAndPriceDoc.productDoc.pro_CalculatePrice;
            }
            
            theOpportunityDoc.productAndPriceDoc.productArray = [NSMutableArray arrayWithObjects:theOpportunityDoc.productAndPriceDoc.productDoc, nil];
            
            theOpportunityDoc.productAndPriceDoc.totalMoney    = [theOpportunityDoc.productAndPriceDoc retTotalMoney];
            theOpportunityDoc.productAndPriceDoc.discountMoney = [theOpportunityDoc.productAndPriceDoc retDiscountMoney];
            [theOpportunityDoc.productAndPriceDoc initIsShowDiscountMoney];
            
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}


- (void)requestAddOppuratity
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"CustomerID\":%ld,\"Discount\":%.2f,\"ProductList\":[%@]}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)theOpportunityDoc.customerId, theOpportunityDoc.discount, theOpportunityDoc.strProductDetail];
    
    _requestAddOrderOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Opportunity/AddOpportunity" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        NSString *data = [json objectForKey:@"Code"];
        if ((NSNull *)data == [NSNull null]) {
            return;
        }
        if([data integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus2:@"新增商机成功！" touchEventHandle:^{}];
        } else {
            [SVProgressHUD showErrorWithStatus2:@"新增商机失败！" touchEventHandle:^{}];
            return;
        }
        
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected removeAllObjects];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected   removeAllObjects];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityOrServiceArray_Selected   removeAllObjects];
        
        [SVProgressHUD showSuccessWithStatus2:[json objectForKey:@"Message"] duration:kSvhudtimer touchEventHandle:^{
            [self performSelector:@selector(goToFirstpageView) withObject:self afterDelay:0.3f];
        }];

    } failure:^(NSError *error) {
        
    }];
}

// 添加order
- (void)requestAddOrder
{
    [SVProgressHUD showWithStatus:@"Loading"];

    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":\"%ld\",\"CustomerID\":\"%ld\",\"CreatorID\":\"%ld\",\"UpdaterID\":\"%ld\",\"OrderList\":[%@]}", (long)ACC_COMPANTID, (long)theOpportunityDoc.customerId, (long)ACC_ACCOUNTID, (long)ACC_ACCOUNTID, theOpportunityDoc.strProductDetail];

    _requestAddOrderOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/addOrder" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (data == nil) {
                [SVProgressHUD showErrorWithStatus2:message touchEventHandle:^{}];
            } else {
                //跳转到详情页数据准备
                NSInteger productType = 0;
                NSInteger commCount = 0;
                NSInteger serviceCount = 0;
                NSInteger productZeroCount = 0;
                NSInteger serviceZeroCount = 0;
                for (ProductDoc *product  in theOpportunityDoc.productAndPriceDoc.productArray){
                    
                    if(product.pro_Type == 0 && product.pro_TotalSaleMoney > 0)
                        serviceCount ++;
                    else if(product.pro_Type == 0 && product.pro_TotalSaleMoney == 0)
                        serviceZeroCount ++;
                    
                    if(product.pro_Type == 1 && product.pro_TotalSaleMoney > 0)
                        commCount ++ ;
                    else if(product.pro_Type == 1 && product.pro_TotalSaleMoney == 0)
                        productZeroCount ++;
                }
                if(serviceCount == 1 && commCount == 0)
                    productType = 0;
                else if (serviceCount == 0 && commCount == 1)
                    productType = 1;
                else if (serviceCount == 0 && commCount == 0 && productZeroCount == 1)
                    productType = 1;
                
                [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected removeAllObjects];
                [((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected   removeAllObjects];
                [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityOrServiceArray_Selected   removeAllObjects];
                
                
                if ([[PermissionDoc sharePermission] rule_Payment_Use] && ((theOpportunityDoc.productAndPriceDoc.discountMoney != 0 && self.orderEditMode == OrderEditModeConfirm1) || (theOpportunityDoc.productAndPriceDoc.discountMoney != 0 && self.orderEditMode == OrderEditModeConfirm2))) {
                    
                    NSMutableArray *orderArrays = [NSMutableArray array];
                    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        OrderDoc *orderDoc = [[OrderDoc alloc] init];
                        [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                        orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     = [[obj objectForKey:@"TotalOrigPrice"] doubleValue];
                        orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] doubleValue];
                        [orderArrays addObject:orderDoc];
                    }];
                    
                    NSMutableArray *notPayedOrderArray = [orderArrays mutableCopy];
                    if (self.payedOrderIndexSet.count == orderArrays.count) {
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        CustomerDoc *customer_Selected = appDelegate.customer_Selected;

                        if ([[PermissionDoc sharePermission] rule_Order_Read] && customer_Selected != nil ) {
                            orderList = 1;
                            if (orderArrays.count == 1) {
                                [self gotoOrderDetailViewControllerwithOrderID:[[orderArrays firstObject] order_ID] ProductType:productType andLastView:1];
                            } else if(orderArrays.count > 1) {
                                [self gotoOrderListViewControllerLastView:5 andClearStack:YES];
                            }
                        } else {
                            [self performSelector:@selector(goToTopView) withObject:self afterDelay:0.3f];
                        }
                        return ;
                    }
                    
                    if (self.payedOrderIndexSet.count) {
                        [notPayedOrderArray removeObjectsAtIndexes:self.payedOrderIndexSet];
                    }

                    
                    NSString *mes = @"订单添加成功! 是否立即结账?";
                    NSString *mesre = [mes stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息" message:mesre delegate:nil cancelButtonTitle:@"稍后结账" otherButtonTitles:@"立即结账", nil];
                    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            
                            if (orderEditMode == OrderEditModeConfirm1) { //正常订单
                                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                CustomerDoc *customer_Selected = appDelegate.customer_Selected;
                                if ([[PermissionDoc sharePermission] rule_Order_Read] && customer_Selected != nil) {
                                    orderList = 1;
                                    //[self performSelector:@selector(goToOrderRootView) withObject:self afterDelay:0.3f];
                                    /*
                                    NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                                    for (id obj in data) {
                                        OrderDoc *orderDoc = [[OrderDoc alloc] init];
                                        [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                                        [orderArray addObject:orderDoc];
                                    }
                                     
                                    if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                                        OrderDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
                                        viewController.orderID = [[orderArray objectAtIndex:0] order_ID];
                                        viewController.productType = productType;
                                        viewController.lastView = 1; // 返回到 order root
                                        [self.navigationController pushViewController:viewController animated:YES];
                                    } else if (orderArray.count > 1) {
                                        OrderListViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderListView"];
                                        viewController.lastView = 5; // 返回到 order root
                                        viewController.clearStack = YES;
                                        [self.navigationController pushViewController:viewController animated:YES];
                                    }
                                    */
                                    if (orderArrays.count == 1) {
                                        [self gotoOrderDetailViewControllerwithOrderID:[[orderArrays firstObject] order_ID] ProductType:productType andLastView:1];
                                    } else if (orderArrays.count > 1) {
                                        [self gotoOrderListViewControllerLastView:5 andClearStack:YES];
                                    }

                                } else
                                    [self performSelector:@selector(goToTopView) withObject:self afterDelay:0.3f];
                            } else { //商机转订单
                                /*
                                NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                                for (id obj in data) {
                                    OrderDoc *orderDoc = [[OrderDoc alloc] init];
                                    [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                                    [orderArray addObject:orderDoc];
                                }
                                if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                                    OrderDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
                                    viewController.orderID = [[orderArray objectAtIndex:0] order_ID];
                                    viewController.productType = productType;
                                    viewController.lastView = 2; //跳转到与我相关的订单
                                    [self.navigationController pushViewController:viewController animated:YES];
                                }else if (orderArray.count > 1)
                                    [self performSelector:@selector(goToMyOrderView) withObject:self afterDelay:0.3f];
                                */
                                if (orderArrays.count == 1) {
                                    [self gotoOrderDetailViewControllerwithOrderID:[[orderArrays firstObject] order_ID] ProductType:productType andLastView:2];
                                } else if (orderArrays.count > 1) {
                                    [self performSelector:@selector(goToMyOrderView) withObject:self afterDelay:0.3f];
                                }
                            }
                        } else { //立即结账
                            
                            /*
                            NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                            for (id obj in data) {
                                
                                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                                [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                                orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     = [[obj objectForKey:@"TotalOrigPrice"] floatValue];
                                orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] floatValue];
                                if (orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney > 0)
                                    [orderArray addObject:orderDoc];
                            }
                            
                            double totalPrice = 0.0f;
                            double totalSalePrice = 0.0f;
                            
                            for (OrderDoc *orderDoc in orderArray) {
                                ProductAndPriceDoc *productAndPriceDoc = orderDoc.productAndPriceDoc;
                                totalPrice += productAndPriceDoc.productDoc.pro_TotalMoney;
                                totalSalePrice += productAndPriceDoc.productDoc.pro_TotalSaleMoney;
                            }
                            */
                            double totalPrice = 0.0f;
                            double totalSalePrice = 0.0f;

                            for (OrderDoc *orderDoc in notPayedOrderArray) {
                                ProductAndPriceDoc *product = orderDoc.productAndPriceDoc;
                                totalPrice += product.productDoc.pro_TotalMoney;
                                totalSalePrice += product.productDoc.pro_TotalSaleMoney;
                            }
                            
                            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"];
                            
                            PayInfoViewController *payInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"PayInfoViewController"];
                            payInfoController.orderNumbers = [notPayedOrderArray count];
                            payInfoController.paymentOrderArray = notPayedOrderArray;
                            payInfoController.makeStateComplete = 1;
                            
                            if(orderEditMode == OrderEditModeConfirm1){ //正常生产的订单
                                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                CustomerDoc *customer_Selected = appDelegate.customer_Selected;
                                payInfoController.customerId = customer_Selected.cus_ID;
                                payInfoController.pageToGo = 1;
                                if(notPayedOrderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                                    payInfoController.pageToGo = 3; //结账后跳转到详情页
                                    payInfoController.orderId = [[notPayedOrderArray firstObject] order_ID];
                                    payInfoController.productType = productType;
                                }else if (notPayedOrderArray.count > 1) {
                                    payInfoController.pageToGo = 5; //结账后跳转到order root
                                }
                            }else{ //商机转订单
                                payInfoController.customerId = theOpportunityDoc.customerId;
                                payInfoController.pageToGo = 2;
                                if(notPayedOrderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                                    payInfoController.pageToGo = 2; //结账后跳转到详情页
                                    payInfoController.orderId = [[notPayedOrderArray firstObject] order_ID];
                                    payInfoController.productType = productType;
                                }
                            }
                            [self.navigationController pushViewController:payInfoController animated:YES];
                        }
                    }];
                } else {
                    if (orderEditMode == OrderEditModeConfirm1) { //正常订单
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        CustomerDoc *customer_Selected = appDelegate.customer_Selected;
                        if ([[PermissionDoc sharePermission] rule_Order_Read] && customer_Selected != nil) {
                            orderList = 1;
                            // [self performSelector:@selector(goToOrderRootView) withObject:self afterDelay:0.3f];
                            NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                            for (id obj in data) {
                                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                                [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                                [orderArray addObject:orderDoc];
                            }
                            if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                                OrderDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
                                viewController.orderID = [[orderArray objectAtIndex:0] order_ID];
                                viewController.productType = productType;
                                viewController.lastView = 1;
                                [self.navigationController pushViewController:viewController animated:YES];
                            }else if (orderArray.count > 1) {
                                OrderListViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderListView"];
                                viewController.lastView = 5; // 返回到 order root
                                viewController.clearStack = YES;
                                [self.navigationController pushViewController:viewController animated:YES];
                            }
                        } else {
                            [self performSelector:@selector(goToTopView) withObject:self afterDelay:0.3f];
                        }
                    } else { //商机转订单
                        NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                        for (id obj in data) {
                            OrderDoc *orderDoc = [[OrderDoc alloc] init];
                            [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                            [orderArray addObject:orderDoc];
                        }
                        if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                            OrderDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
                            viewController.orderID = [[orderArray objectAtIndex:0] order_ID];
                            viewController.productType = productType;
                            viewController.lastView = 2; //跳转到与我相关的订单
                            [self.navigationController pushViewController:viewController animated:YES];
                        }else if (orderArray.count > 1)
                            [self performSelector:@selector(goToMyOrderView) withObject:self afterDelay:0.3f];
                    }
                }

            }
        } failure:^(NSInteger code, NSString *error) {
            if (code == -2) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        if (orderEditMode == OrderEditModeConfirm2) {
                            refresh = YES;
                        }
                        [self initData];
                    }
                    
                }];
            } else {
                [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
            }
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _requestAddOrderOperation = [[GPHTTPClient shareClient] requestAddOrderNew:theOpportunityDoc oppIdStr:oppStr success:^(id xml) {
        [SVProgressHUD dismiss];
        
        NSString *origalString = (NSString*)xml;
        NSString *regexString = @"[{*}]";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
        if(!array || [array count] < 2)
            return;
        origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];

        NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
        
        
        NSInteger code = [[dataDic objectForKey:@"Code"] integerValue];
        if (code == -2) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[dataDic objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    if (orderEditMode == OrderEditModeConfirm2) {
                        refresh = YES;
                    }
                    [self initData];
                }

            }];
            return;
        }

        NSArray *data = [dataDic objectForKey:@"Data"];
        if ((NSNull *)data == [NSNull null] || data.count == 0) {
            [SVProgressHUD showErrorWithStatus2:[dataDic objectForKey:@"Message"] touchEventHandle:^{}];
            return;
        }
        
        
        
        //跳转到详情页数据准备
        NSInteger productType = 0;
        NSInteger commCount = 0;
        NSInteger serviceCount = 0;
        NSInteger productZeroCount = 0;
        NSInteger serviceZeroCount = 0;
        for (ProductDoc *product  in theOpportunityDoc.productAndPriceDoc.productArray){
            
            if(product.pro_Type == 0 && product.pro_TotalSaleMoney > 0)
                serviceCount ++;
            else if(product.pro_Type == 0 && product.pro_TotalSaleMoney == 0)
                serviceZeroCount ++;
            
            if(product.pro_Type == 1 && product.pro_TotalSaleMoney > 0)
                commCount ++ ;
            else if(product.pro_Type == 1 && product.pro_TotalSaleMoney == 0)
                productZeroCount ++;
        }
        if(serviceCount == 1 && commCount == 0)
            productType = 0;
        else if (serviceCount == 0 && commCount == 1)
            productType = 1;
        else if (serviceCount == 0 && commCount == 0 && productZeroCount == 1)
            productType = 1;
        
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected removeAllObjects];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected   removeAllObjects];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityOrServiceArray_Selected   removeAllObjects];
        
        if ([[PermissionDoc sharePermission] rule_Payment_Use] && ((theOpportunityDoc.productAndPriceDoc.discountMoney != 0 && self.orderEditMode == OrderEditModeConfirm1) || (theOpportunityDoc.productAndPriceDoc.discountMoney != 0 && self.orderEditMode == OrderEditModeConfirm2))) {
            NSString *mes = @"订单添加成功! 是否立即结账?";
            NSString *mesre = [mes stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息" message:mesre delegate:nil cancelButtonTitle:@"稍后结账" otherButtonTitles:@"立即结账", nil];
            [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    if (orderEditMode == OrderEditModeConfirm1) { //正常订单
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        CustomerDoc *customer_Selected = appDelegate.customer_Selected;
                        if ([[PermissionDoc sharePermission] rule_Order_Read] && customer_Selected != nil) {
                            orderList = 1;
                            //[self performSelector:@selector(goToOrderRootView) withObject:self afterDelay:0.3f];
                            NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                            for (id obj in data) {
                                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                                [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                                [orderArray addObject:orderDoc];
                            }
                            if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                                OrderDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
                                viewController.orderID = [[orderArray objectAtIndex:0] order_ID];
                                viewController.productType = productType;
                                viewController.lastView = 1; // 返回到 order root
                                [self.navigationController pushViewController:viewController animated:YES];
                            } else if (orderArray.count > 1) {
                                OrderListViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderListView"];
                                viewController.lastView = 5; // 返回到 order root
                                viewController.clearStack = YES;
                                [self.navigationController pushViewController:viewController animated:YES];
                            }
                        } else
                            [self performSelector:@selector(goToTopView) withObject:self afterDelay:0.3f];
                    } else { //商机转订单
                        NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                        for (id obj in data) {
                            OrderDoc *orderDoc = [[OrderDoc alloc] init];
                            [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                            [orderArray addObject:orderDoc];
                        }
                        if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                            OrderDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
                            viewController.orderID = [[orderArray objectAtIndex:0] order_ID];
                            viewController.productType = productType;
                            viewController.lastView = 2; //跳转到与我相关的订单
                            [self.navigationController pushViewController:viewController animated:YES];
                        }else if (orderArray.count > 1)
                            [self performSelector:@selector(goToMyOrderView) withObject:self afterDelay:0.3f];
                    }
                } else { //立即结账
                    NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                    for (id obj in data) {

                        OrderDoc *orderDoc = [[OrderDoc alloc] init];
                        [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                        orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     = [[obj objectForKey:@"TotalOrigPrice"] floatValue];
                        orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] floatValue];
                        if (orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney > 0)
                            [orderArray addObject:orderDoc];
                    }
                        
                    double totalPrice = 0.0f;
                    double totalSalePrice = 0.0f;
                        
                    for (OrderDoc *orderDoc in orderArray) {
                        ProductAndPriceDoc *productAndPriceDoc = orderDoc.productAndPriceDoc;
                        totalPrice += productAndPriceDoc.productDoc.pro_TotalMoney;
                        totalSalePrice += productAndPriceDoc.productDoc.pro_TotalSaleMoney;
                    }
                        
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"];
                        
                    PayInfoViewController *payInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"PayInfoViewController"];
                    payInfoController.totalMoney = totalPrice;
                    payInfoController.favorable = totalSalePrice;
                    payInfoController.orderNumbers = [orderArray count];
                    payInfoController.paymentOrderArray = orderArray;
                    payInfoController.makeStateComplete = 1;
                    
                    if(orderEditMode == OrderEditModeConfirm1){ //正常生产的订单
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        CustomerDoc *customer_Selected = appDelegate.customer_Selected;
                        payInfoController.balance = customer_Selected.cus_Balance;
                        payInfoController.customerId = customer_Selected.cus_ID;
                        payInfoController.pageToGo = 1;
                        if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                            payInfoController.pageToGo = 3; //结账后跳转到详情页
                            payInfoController.orderId = [[orderArray objectAtIndex:0] order_ID];
                            payInfoController.productType = productType;
                        }else if (orderArray.count > 1) {
                            payInfoController.pageToGo = 5; //结账后跳转到order root
                        }
                    }else{ //商机转订单
                        payInfoController.customerId = theOpportunityDoc.customerId;
                        payInfoController.pageToGo = 2;
                        if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                            payInfoController.pageToGo = 2; //结账后跳转到详情页
                            payInfoController.orderId = [[orderArray objectAtIndex:0] order_ID];
                            payInfoController.productType = productType;
                        }
                    }
                    [self.navigationController pushViewController:payInfoController animated:YES];
                }
            }];
        } else {
            if (orderEditMode == OrderEditModeConfirm1) { //正常订单
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                CustomerDoc *customer_Selected = appDelegate.customer_Selected;
                if ([[PermissionDoc sharePermission] rule_Order_Read] && customer_Selected != nil) {
                    orderList = 1;
                   // [self performSelector:@selector(goToOrderRootView) withObject:self afterDelay:0.3f];
                    NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                    for (id obj in data) {
                        OrderDoc *orderDoc = [[OrderDoc alloc] init];
                        [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                        [orderArray addObject:orderDoc];
                    }
                    if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                        OrderDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
                        viewController.orderID = [[orderArray objectAtIndex:0] order_ID];
                        viewController.productType = productType;
                        viewController.lastView = 1;
                        [self.navigationController pushViewController:viewController animated:YES];
                    }else if (orderArray.count > 1) {
                        OrderListViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderListView"];
                        viewController.lastView = 5; // 返回到 order root
                        viewController.clearStack = YES;
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                } else {
                    [self performSelector:@selector(goToTopView) withObject:self afterDelay:0.3f];
                }
            } else { //商机转订单
                NSMutableArray *orderArray = [[NSMutableArray alloc] init];
                for (id obj in data) {
                    OrderDoc *orderDoc = [[OrderDoc alloc] init];
                    [orderDoc setOrder_ID:[(NSString*)[obj objectForKey:@"OrderID"] integerValue]];
                    [orderArray addObject:orderDoc];
                }
                if(orderArray.count == 1) {  //如果只有一个商品或者服务，跳转到详情
                    OrderDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
                    viewController.orderID = [[orderArray objectAtIndex:0] order_ID];
                    viewController.productType = productType;
                    viewController.lastView = 2; //跳转到与我相关的订单
                    [self.navigationController pushViewController:viewController animated:YES];
                }else if (orderArray.count > 1)
                    [self performSelector:@selector(goToMyOrderView) withObject:self afterDelay:0.3f];
            }
        }
        */
        /*
            [SVProgressHUD showSuccessWithStatus2:resultMsg touchEventHandle:^{
                if (orderEditMode == OrderEditModeConfirm1)
                    [self performSelector:@selector(goToOrderRootView) withObject:self afterDelay:0.3f];
                else
                    [self performSelector:@selector(goToFirstpageView) withObject:self afterDelay:0.3f];
            }];*/
        
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}

- (void)gotoOrderDetailViewControllerwithOrderID:(NSInteger)orderID ProductType:(NSInteger)type andLastView:(NSInteger)lastView
{
    OrderDetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
    viewController.orderID = orderID;
    viewController.productType = type;
    viewController.lastView = lastView; // 返回到 order roo
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)gotoOrderListViewControllerLastView:(NSInteger)lastView andClearStack:(BOOL)isClear
{
    OrderListViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderListView"];
    viewController.lastView = lastView;
    viewController.clearStack = isClear;
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void)goToFirstpageView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"ACCOUNT_MENU_TYPE"];

    UIViewController *topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OpportunityNavigation"];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = topViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (void)goToOrderRootView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"ACCOUNT_MENU_TYPE"];
    if (orderList == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"GO_TO_CUSTOMER"];
    }

    UIViewController *topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderNavigation"];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = topViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (void)goToCustomerView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"ACCOUNT_MENU_TYPE"];
    OrderListViewController *customerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderListView"];
    customerViewController.lastView = 1;
    customerViewController.requestType = -1;
    customerViewController.requestStatus = -1;
    customerViewController.requestIsPaid = -1;

    [self.navigationController pushViewController:customerViewController animated:YES];
}

- (void)goToMyOrderView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"ACCOUNT_MENU_TYPE"];
    
    UIViewController *topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyOrderNavigation"];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = topViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (void)goToTopView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"ACCOUNT_MENU_TYPE"];
    
    UIViewController *topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstNavigation"];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = topViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}


@end

