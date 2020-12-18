//
//  OrderConfirmViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-6.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderConfirmViewController.h"
#import "GDataXMLNode.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "TitleView.h"
#import "OrderDoc.h"
#import "ProductAndPriceDoc.h"
#import "AppDelegate.h"
#import "UIButton+InitButton.h"
#import "noCopyTextField.h"
#import "OrderDetailAboutCommodityViewController.h"
#import "OrderDetailAboutServiceViewController.h"


static CGFloat const kCell_Height = 70;

@interface OrderConfirmViewController ()

@property (weak, nonatomic) AFHTTPRequestOperation *requestForUnfinishTGlist;
@property (weak, nonatomic) AFHTTPRequestOperation *requestPostOrderUnconfirmedListOperation;
@property (strong, nonatomic) NSMutableArray *orderArray;
@property (strong, nonatomic) NSMutableArray *orderArray_Selected;  //提交所需要的参数
@property (nonatomic, retain) UIButton *stateButton;
@end

@implementation OrderConfirmViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"确认服务完成或商品收货";

    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20 - 49.0f);
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = nil;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorColor = kTableView_LineColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    [self.view addSubview:footView];
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    UIButton *add_Button = [UIButton buttonWithTitle:@"确定"
                                              target:self
                                            selector:@selector(confirmAction)
                                               frame:CGRectMake(5,5, kSCREN_BOUNDS.size.width - 10, 39)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    add_Button.backgroundColor  = kColor_BtnBackground;
    add_Button.titleLabel.font=kNormalFont_14;
    [footView addSubview:add_Button];
    
    [self initbgView];
    
    [self getUnfinishTGList];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (_orderArray_Selected) {
        [_orderArray_Selected removeAllObjects];
    }
    
    [_stateButton setSelected:NO];
    [self getUnfinishTGList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if (_requestForUnfinishTGlist || [_requestForUnfinishTGlist isExecuting]) {
        [_requestForUnfinishTGlist cancel];
        _requestForUnfinishTGlist = nil;
    }
    
    if (_requestPostOrderUnconfirmedListOperation || [_requestPostOrderUnconfirmedListOperation isExecuting]) {
        [_requestPostOrderUnconfirmedListOperation cancel];
        _requestPostOrderUnconfirmedListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
- (void)initbgView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"coverView" object:nil];
}

#pragma mark - addAction

- (void)selectAllAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    
    if (button.selected) {
        [_orderArray_Selected removeAllObjects];
        _orderArray_Selected = [_orderArray mutableCopy];
        for (OrderDoc *orderDoc in _orderArray) {
            orderDoc.status = 1;
        }
        [_tableView reloadData];
    } else {
        [_orderArray_Selected removeAllObjects];
        for (OrderDoc *orderDoc in _orderArray) {
            orderDoc.status = 0;
        }
        [_tableView reloadData];
    }
}

- (void)confirmAction
{
    self.hidesBottomBarWhenPushed = YES;
    if (_orderArray_Selected.count != 0) {
        
        NSMutableArray *postArray= [NSMutableArray array];
        
        for (int i = 0; i < _orderArray_Selected.count; i++) {
            OrderDoc *orderDoc = [_orderArray_Selected objectAtIndex:i];
            NSDictionary *dict = @{
                                    @"OrderType":@([orderDoc productType]),
                                    @"OrderID":@([orderDoc orderID]),
                                    @"OrderObjectID":@([[orderDoc orderObjectID] integerValue]),
                                    @"GroupNo":@((long long)[orderDoc groupNo])
                                };
            [postArray addObject:dict];
        }
        
       [self postUnconfirmedOrderWithOrderJson:postArray andPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_LOGIN_CUSTOMPASSWORD"]];
    } else {
        if (_orderArray_Selected.count == 0) {
            [SVProgressHUD showErrorWithStatus2:@"请选择需要确定的订单"];
        }

    }
    [_orderArray_Selected removeAllObjects];
}

#pragma mark - OrderConfirmCellDelegate

- (void)selectedTheOrderConfirmListCell:(OrderConfirmCell *)cell
{
    if (!_orderArray_Selected)
        _orderArray_Selected= [NSMutableArray array];
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    OrderDoc *tmpOrderDoc = [_orderArray objectAtIndex:indexPath.row];
    
    if (![_orderArray_Selected containsObject:tmpOrderDoc]) {
        [_orderArray_Selected addObject:tmpOrderDoc];
        if (_orderArray_Selected.count == _orderArray.count) {
            [_stateButton setSelected:YES];
        }
    } else {
        [_orderArray_Selected removeObject:tmpOrderDoc];
        [_stateButton setSelected:NO];
    }
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    
    if (IOS6) {
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.5];
        CGRect listFrame = CGRectMake(0.0f, -keyboardBounds.size.height, self.view.frame.size.width, self.view.frame.size.height);//处理移动事件，将各视图设置最终要达到的状态
        self.view.frame = listFrame;
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.5];
        CGRect listFrame = CGRectMake(0.0f, -keyboardBounds.size.height + 64, self.view.frame.size.width, self.view.frame.size.height);//处理移动事件，将各视图设置最终要达到的状态
        self.view.frame = listFrame;
        [UIView commitAnimations];
    }
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    if (IOS6) {
        if (self.view.frame.origin.y != 20) {
            [UIView beginAnimations:@"showKeyboard" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.1];
            CGRect rect = self.view.frame;
            rect.origin.y = 0.0f;
            self.view.frame = rect;
            [UIView commitAnimations];
        }
    } else {
        if (self.view.frame.origin.y != 0) {
            [UIView beginAnimations:@"showKeyboard" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.1];
            CGRect rect = self.view.frame;
            rect.origin.y = 0.0f + 64;
            self.view.frame = rect;
            [UIView commitAnimations];
        }
    }
}


#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_orderArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCell_Height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"MyCellConfirm";
    OrderConfirmCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderConfirmCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
    }
    OrderDoc *orderDoc = [_orderArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = orderDoc.productName;
    cell.numberLabel.text = orderDoc.accountName;
    cell.dateLabel.text = orderDoc.tGStartTime;
    cell.totalNumberLabel.text = orderDoc.productTypeStatus;
   [cell setDelegate:self];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectButton.hidden = NO;
    
    if ([_orderArray_Selected containsObject:orderDoc]) {
        [cell.selectButton setSelected:YES];
    } else {
        [cell.selectButton setSelected:NO];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
     OrderDoc *orderDoc = [_orderArray objectAtIndex:indexPath.row];
    
    if ([orderDoc productType] ==1) {//商品
        
        OrderDetailAboutCommodityViewController *commod = (OrderDetailAboutCommodityViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailAboutCommodityViewController"];
        commod.orderDoc = orderDoc;
        
        [self.navigationController pushViewController:commod animated:YES];
        
    }else
    {
        OrderDetailAboutServiceViewController *serve =  (OrderDetailAboutServiceViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailAboutServiceViewController"];
        serve.orderDoc = orderDoc;
        [self.navigationController pushViewController:serve animated:YES];
        
    }
}

#pragma mark - textField
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //留用
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= 20){
        return NO;
    }
    return YES;
}
#pragma mark - 接口

-(void)getUnfinishTGList
{
    NSDictionary *para = @{
                           @"Type": @(-1),
                           };
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary *dict = @{@"productName":@"ProductName",
                           @"tGStartTime":@"TGStartTime",
                           @"accountName":@"AccountName",
                           @"accountID":@"AccountID",
                           @"paymentStatus":@"PaymentStatus",
                           @"totalCount":@"TotalCount",
                           @"finisHedCount":@"FinishedCount",
                           @"groupNo":@"GroupNo",
                           @"orderID":@"OrderID",
                           @"orderObjectID":@"OrderObjectID",
                           @"productType":@"ProductType",
                           @"headImageURL":@"HeadImageURL",
                           @"statusNew":@"Status",
                           @"customerName":@"CustomerName",
                           @"customerID":@"CustomerID",
                           @"isDesignated":@"IsDesignated"};
    
    _requestForUnfinishTGlist = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/GetUnconfirmTreatGroup"  showErrorMsg:YES  parameters:para WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _orderArray = [[NSMutableArray alloc]init];
            for (NSDictionary *obj in data){
                
                OrderDoc *orderDoc = [[OrderDoc alloc]init];
                [orderDoc assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                orderDoc.productType = [[obj objectForKey:@"ProductType"] integerValue];
                orderDoc.order_ID  =  [[obj objectForKey:@"OrderID"] integerValue];
                orderDoc.order_ObjectID  =  [[obj objectForKey:@"OrderObjectID"] integerValue];
                orderDoc.order_Type  =  [[obj objectForKey:@"ProductType"] integerValue];
                
                [_orderArray addObject:orderDoc];
                
            }
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)postUnconfirmedOrderWithOrderXml:(NSString *)cXml andPassword:(NSString *)password
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    _requestPostOrderUnconfirmedListOperation = [[GPHTTPClient shareClient] requestPostUnconfirmedOrderListWithOrderXml:cXml andPassword:password Success:^(id xml) {
        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData) {
            _stateButton.selected = NO;
            
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self getUnfinishTGList];
            });
        } failure:^{
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)postUnconfirmedOrderWithOrderJson:(NSArray *)array andPassword:(NSString *)password
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary *para = @{@"CustomerID":@(CUS_CUSTOMERID) ,@"TGDetailList":array};
    
    _requestForUnfinishTGlist = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/ConfirmTreatGroup"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _stateButton.selected = NO;
            [SVProgressHUD showSuccessWithStatus:@"订单确认成功！"];
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self getUnfinishTGList];
            });
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
        }];
        
        [_tableView reloadData];
    } failure:^(NSError *error) {
    }];

}

@end
