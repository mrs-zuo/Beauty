//
//  SalesProcessViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "ProgressEditViewController.h"
#import "GPHTTPClient.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "SVProgressHUD.h"
#import "ProgressDoc.h"
#import "ProductAndPriceView.h"
#import "OrderConfirmViewController.h"
#import "NavigationView.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "DEFINE.h"
#import "GDataXMLNode.h"
#import "FooterView.h"
#import "AppDelegate.h"
#import "OppTabBarController.h"
#import "OpportunityDoc.h"
#import "NSDate+Convert.h"
#import "SalesProgressViewController.h"
#import "ProgressHistoryViewController.h"
#import "ProgressDoc.h"
#import "GPBHTTPClient.h"

@interface ProgressEditViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetProgressDetailOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddProgressOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateProgressOperation;

@property (strong, nonatomic) ProductAndPriceView *productAndPriceView;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (assign, nonatomic) BOOL canSelectRowInProductAndPriceView;  // ProductAndPriceView中的TableView didSelectRow事件是否可用(该事件与UITapGestureRecognizer事件冲突)
@property (assign, nonatomic) BOOL isShowDiscount;
@end

@implementation ProgressEditViewController
@synthesize theOpportunityDoc;
@synthesize progressID;
@synthesize productType;
@synthesize fromType;

@synthesize productAndPriceView;
@synthesize prevCaretRect;
@synthesize canSelectRowInProductAndPriceView;
@synthesize progressDoc;

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
    
    if (_requestAddProgressOperation && [_requestAddProgressOperation isExecuting]) {
        [_requestAddProgressOperation cancel];
    }
    
    if (_requestUpdateProgressOperation && [_requestUpdateProgressOperation isExecuting]) {
        [_requestUpdateProgressOperation cancel];
    }
    
    if (_requestGetProgressDetailOperation && [_requestGetProgressDetailOperation isExecuting]) {
        [_requestGetProgressDetailOperation cancel];
    }
    
    _requestAddProgressOperation = nil;
    _requestUpdateProgressOperation = nil;
    _requestGetProgressDetailOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.baseEditing = YES;
    canSelectRowInProductAndPriceView = YES;
    
    if (fromType == FromTypeProgressHistoryView) {
        [self requestGetProgressDetail];
    }
    
    [self initLayout];
}

- (void)initLayout
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"编辑销售进度"];
    [self.view addSubview:navigationView];
    
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.allowsSelection = NO;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _isShowDiscount = YES;
    
    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f  -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(saveProgressAction)];
    [footerView showInTableView:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (void)saveProgressAction
{
    if (fromType == FromTypeSaleProgressView) {
        [self requestAddProgress];
    } else if (fromType == FromTypeProgressHistoryView) {
        [self requestUpdateProgress];
    }
}

#pragma mark - overwrite

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (canSelectRowInProductAndPriceView) {
        return NO;
    }
    return  [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    canSelectRowInProductAndPriceView = NO;
    [super keyboardWillShow:notification];
    //弹出键盘时滚动到固定位置
    int i = 0;
    if (self.textView_Selected) {
        i = 1;
    }
    NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:i];
    [_tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    canSelectRowInProductAndPriceView = YES;
    [super keyboardWillHide:notification];
}

- (void)dismissKeyBoard
{
    [super dismissKeyBoard];
    [productAndPriceView dismissKeyboard];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0)) {
        static NSString *cellIndentify = @"ProperyEditCell";
        NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.titleLabel.text = @"时间";
            
            if (fromType == FromTypeSaleProgressView) {
               cell.valueText.text = [NSDate dateToString:[NSDate date] dateFormat:@"yyyy-MM-dd HH:mm"];
            } else {
                cell.valueText.text = progressDoc.prg_UpdateTime;
            }
//            else if (fromType == FromTypeProgressHistoryView)
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            cell.titleLabel.text = @"最新进度";
            cell.valueText.text = theOpportunityDoc.opp_ProgressStr;
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            cell.titleLabel.text = @"描述";
            cell.valueText.text = @"";
        }
        cell.valueText.userInteractionEnabled = NO;
        cell.valueText.textColor = [UIColor blackColor];
        [cell setAccessoryText:@""];
        
        return cell;
    } else {
        ContentEditCell *contentEditCell  = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DescibleEditCell"];
        contentEditCell.accessoryType = UITableViewCellAccessoryNone;
        contentEditCell.selectionStyle = UITableViewCellSelectionStyleNone;
        contentEditCell.contentEditText.returnKeyType = UIReturnKeyDefault;
        contentEditCell.contentEditText.placeholder = @"请填写描述内容";
       [contentEditCell setContentText:theOpportunityDoc.opp_Describe];
        contentEditCell.delegate = self;
        return contentEditCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
       return  theOpportunityDoc.height_Prg_Describle;
    }
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    /*theOpportunityDoc.productAndPriceDoc.productArray 中会初始化设置pro_IsShowDiscountMoney的值，不需要再次判断
    ProductDoc *productDoc =  (ProductDoc*)[theOpportunityDoc.productAndPriceDoc.productArray objectAtIndex:0];
    if((productDoc.pro_TotalMoney - productDoc.pro_TotalSaleMoney < -0.0001f ||  productDoc.pro_TotalMoney - productDoc.pro_TotalSaleMoney > 0.0001f) && _isShowDiscount){
        productDoc.pro_IsShowDiscountMoney = YES;
        _isShowDiscount = NO;
    }
     */
    
    if (section == 0 && theOpportunityDoc.productAndPriceDoc) {
        return theOpportunityDoc.productAndPriceDoc.table_Height;
    }
    return kTableView_Margin_Bottom;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        if (theOpportunityDoc.productAndPriceDoc) {
            productAndPriceView = [[ProductAndPriceView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 330.0f, theOpportunityDoc.productAndPriceDoc.table_Height)];
            [productAndPriceView setTheProductAndPriceDoc:theOpportunityDoc.productAndPriceDoc];
            [productAndPriceView setCanEditeQuantityAndPrice:YES];
            [productAndPriceView setDelegate:self];
            return productAndPriceView;
        }
   }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ProductAndPriceViewDelegate

- (void)changeHeightOfProductAndPriceView
{
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char *ch = [text cStringUsingEncoding:NSUTF8StringEncoding];
    if (ch == 0) return YES;
    
    if ([textView.text length] > 300) {
        return NO;
    }
    return YES;
}

#pragma mark - ContentEditCellDelegate

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    self.textView_Selected = contentText;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
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
}


- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    self.textView_Selected = nil;
    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    if ([contentText.text length] > 300) return NO;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
    
   theOpportunityDoc.opp_Describe = contentText.text;
   theOpportunityDoc.height_Prg_Describle = height;
    
    [_tableView beginUpdates];
    [_tableView endUpdates];
}
- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];
    [cell textViewDidChange:textView];
    
}

- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [_tableView convertRect:cursorRect fromView:textView];
    
    if (prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        prevCaretRect = newCursorRect;
        [self.tableView scrollRectToVisible:newCursorRect animated:YES];
    }
}

#pragma mark -- 接口

// --Progress Detail
- (void)requestGetProgressDetail
{
  [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"ProgressID\":%ld,\"ProductType\":%ld}", (long)progressID, (long)productType];
    _requestGetProgressDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Opportunity/GetProgressDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];

        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            theOpportunityDoc = [[OpportunityDoc alloc] init];
            [theOpportunityDoc setOpp_ID: [((NSString *)[data objectForKey:@"OpportunityID"]) integerValue]];
            [theOpportunityDoc setCustomerId: [((NSString *)[data objectForKey:@"CustomerID"]) integerValue]];
            [theOpportunityDoc setOpp_Progress: [((NSString *)[data objectForKey:@"Progress"]) integerValue]];
            [theOpportunityDoc setOpp_StepContent: (NSString *)[data objectForKey:@"StepContent"]];
            [theOpportunityDoc setOpp_UpdateTime: (NSString *)[data objectForKey:@"CreateTime"]];
            [theOpportunityDoc setOpp_Describe: (NSString *)[data objectForKey:@"Description"]];
            NSArray *stepArray = [theOpportunityDoc.opp_StepContent componentsSeparatedByString:@"|"];
            if([stepArray count] > 0)
                [theOpportunityDoc setOpp_ProgressStr:[stepArray objectAtIndex:theOpportunityDoc.opp_Progress - 1]];
            [theOpportunityDoc setOpp_ProgressID:progressID];
            float discount = [((NSString *)[data objectForKey:@"Progress"]) doubleValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Discount = discount == 0 ? 1.0f : discount;
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy = [((NSString *)[data objectForKey:@"MarketingPolicy"]) integerValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice = [((NSString *)[data objectForKey:@"UnitPrice"]) doubleValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_PromotionPrice = [((NSString *)[data objectForKey:@"PromotionPrice"]) doubleValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney =[((NSString *)[data objectForKey:@"TotalSalePrice"]) doubleValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney =[((NSString *)[data objectForKey:@"TotalOrigPrice"]) doubleValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_ID = [((NSString *)[data objectForKey:@"ProductID"]) integerValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Code = [((NSString *)[data objectForKey:@"ProductCode"]) longLongValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Name = (NSString *)[data objectForKey:@"ProductName"];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type = [((NSString *)[data objectForKey:@"ProductType"]) integerValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity = [((NSString *)[data objectForKey:@"Quantity"]) integerValue];
            ProductDoc *productDoc = theOpportunityDoc.productAndPriceDoc.productDoc;
            productDoc.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2Lf",(productDoc.pro_TotalSaleMoney/productDoc.pro_quantity)] doubleValue];//[theOpportunityDoc.productAndPriceDoc.productDoc retCalculatePrice];
            productDoc.pro_Unitprice = [[NSString stringWithFormat:@"%.2Lf",(productDoc.pro_TotalMoney/productDoc.pro_quantity)] doubleValue];
            
            [theOpportunityDoc.productAndPriceDoc initIsShowDiscountMoney];
            theOpportunityDoc.productAndPriceDoc.productArray = [NSMutableArray arrayWithObject:productDoc]; //GPB-922
            
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            if( code == 0)
            {
                [SVProgressHUD showErrorWithStatus2:@"获取进度详情失败！" touchEventHandle:^{
                }];
            }

        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    /*
  _requestGetProgressDetailOperation = [[GPHTTPClient shareClient] requestGetProgressDetailByJson:progressID productType:productType success:^(id xml) {
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
      NSString *code = [dataDic objectForKey:@"Code"];
      if ((NSNull *)code == [NSNull null]) {
          return;
      }
      if([code integerValue] == 0)
      {
          [SVProgressHUD showErrorWithStatus2:@"获取进度详情失败！" touchEventHandle:^{
          }];
          return;
      }
      NSDictionary *data = [dataDic objectForKey:@"Data"];
      if((NSNull*)data ==  [NSNull null] || data.count == 0){
          [SVProgressHUD showErrorWithStatus2:@"解析数据失败！" touchEventHandle:^{ }];
          return;
      }
       theOpportunityDoc = [[OpportunityDoc alloc] init];
      [theOpportunityDoc setOpp_ID: [((NSString *)[data objectForKey:@"OpportunityID"]) integerValue]];
      [theOpportunityDoc setCustomerId: [((NSString *)[data objectForKey:@"CustomerID"]) integerValue]];
      [theOpportunityDoc setOpp_Progress: [((NSString *)[data objectForKey:@"Progress"]) integerValue]];
      [theOpportunityDoc setOpp_StepContent: (NSString *)[data objectForKey:@"StepContent"]];
      [theOpportunityDoc setOpp_UpdateTime: (NSString *)[data objectForKey:@"CreateTime"]];
      [theOpportunityDoc setOpp_Describe: (NSString *)[data objectForKey:@"Description"]];
      NSArray *stepArray = [theOpportunityDoc.opp_StepContent componentsSeparatedByString:@"|"];
      if([stepArray count] > 0)
         [theOpportunityDoc setOpp_ProgressStr:[stepArray objectAtIndex:theOpportunityDoc.opp_Progress - 1]];
      [theOpportunityDoc setOpp_ProgressID:progressID];
      float discount = [((NSString *)[data objectForKey:@"Progress"]) floatValue];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_Discount = discount == 0 ? 1.0f : discount;
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy = [((NSString *)[data objectForKey:@"MarketingPolicy"]) integerValue];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice = [((NSString *)[data objectForKey:@"UnitPrice"]) floatValue];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_PromotionPrice = [((NSString *)[data objectForKey:@"PromotionPrice"]) floatValue];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney =[((NSString *)[data objectForKey:@"TotalSalePrice"]) floatValue];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney =[((NSString *)[data objectForKey:@"TotalOrigPrice"]) floatValue];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_ID = [((NSString *)[data objectForKey:@"ProductID"]) integerValue];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_Code = [((NSString *)[data objectForKey:@"ProductCode"]) longLongValue];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_Name = (NSString *)[data objectForKey:@"ProductName"];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type = [((NSString *)[data objectForKey:@"ProductType"]) integerValue];
      theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity = [((NSString *)[data objectForKey:@"Quantity"]) integerValue];
      ProductDoc *productDoc = theOpportunityDoc.productAndPriceDoc.productDoc;
      productDoc.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2f",(productDoc.pro_TotalSaleMoney/productDoc.pro_quantity)] floatValue];//[theOpportunityDoc.productAndPriceDoc.productDoc retCalculatePrice];
      productDoc.pro_Unitprice = [[NSString stringWithFormat:@"%.2f",(productDoc.pro_TotalMoney/productDoc.pro_quantity)] floatValue];
      
      [theOpportunityDoc.productAndPriceDoc initIsShowDiscountMoney];
      
      /*  之前价格的计算方法
      [theOpportunityDoc.productAndPriceDoc initIsShowDiscountMoney];
      theOpportunityDoc.productAndPriceDoc.totalMoney = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice * theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity;
      
      if (productDoc.pro_MarketingPolicy == 1)
          theOpportunityDoc.productAndPriceDoc.discountMoney = productDoc.pro_Unitprice * productDoc.pro_Discount * productDoc.pro_quantity;
      else
           theOpportunityDoc.productAndPriceDoc.discountMoney = productDoc.pro_PromotionPrice * productDoc.pro_quantity;
      
      productDoc.pro_TotalMoney = productDoc.pro_Unitprice * productDoc.pro_quantity;
      if (productDoc.pro_MarketingPolicy == 1)
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = productDoc.pro_Unitprice * productDoc.pro_Discount * productDoc.pro_quantity;
      else
          productDoc.pro_TotalSaleMoney = productDoc.pro_PromotionPrice * productDoc.pro_quantity;
      */
      /*
      theOpportunityDoc.productAndPriceDoc.productArray = [NSMutableArray arrayWithObject:productDoc]; //GPB-922
      
      [_tableView reloadData];
      
      /*
      [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
          theOpportunityDoc = [[OpportunityDoc alloc] init];
          [theOpportunityDoc setOpp_ID:[[[[contentData elementsForName:@"OpportunityID"] objectAtIndex:0] stringValue]  integerValue]];
          [theOpportunityDoc setCustomerId:[[[[contentData elementsForName:@"CustomerID"] objectAtIndex:0] stringValue] integerValue]];
          [theOpportunityDoc setOpp_Progress:[[[[contentData elementsForName:@"Progress"] objectAtIndex:0] stringValue] integerValue]];
          [theOpportunityDoc setOpp_StepContent:[[[contentData elementsForName:@"StepContent"] objectAtIndex:0] stringValue]];
          [theOpportunityDoc setOpp_UpdateTime:[[[contentData elementsForName:@"CreateTime"] objectAtIndex:0] stringValue]];
          [theOpportunityDoc setOpp_Describe:[[[contentData elementsForName:@"Description"] objectAtIndex:0] stringValue]];
          [theOpportunityDoc setOpp_ProgressID:progressID];
          
          float discount = [[[[contentData elementsForName:@"Discount"] objectAtIndex:0] stringValue] floatValue];
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_Discount = discount == 0 ? 1.0f : discount;
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy = [[[[contentData elementsForName:@"MarketingPolicy"] objectAtIndex:0] stringValue] integerValue];
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice = [[[[contentData elementsForName:@"UnitPrice"] objectAtIndex:0] stringValue] floatValue];
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_PromotionPrice = [[[[contentData elementsForName:@"PromotionPrice"] objectAtIndex:0] stringValue] floatValue];
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_ID       = [[[[contentData elementsForName:@"ProductID"] objectAtIndex:0] stringValue] integerValue];
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_Code       = [[[[contentData elementsForName:@"ProductCode"] objectAtIndex:0] stringValue] integerValue];
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_Name     = [[[contentData elementsForName:@"ProductName"] objectAtIndex:0] stringValue];
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type     = [[[[contentData elementsForName:@"ProductType"] objectAtIndex:0] stringValue] integerValue];
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity = [[[[contentData elementsForName:@"Quantity"] objectAtIndex:0] stringValue] integerValue];
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_CalculatePrice = [theOpportunityDoc.productAndPriceDoc.productDoc retCalculatePrice];
          [theOpportunityDoc.productAndPriceDoc initIsShowDiscountMoney];
          
          theOpportunityDoc.productAndPriceDoc.totalMoney = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice * theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity;
          if (theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy == 1) {
              theOpportunityDoc.productAndPriceDoc.discountMoney = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice * theOpportunityDoc.productAndPriceDoc.productDoc.pro_Discount * theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity;
          } else {
              theOpportunityDoc.productAndPriceDoc.discountMoney = theOpportunityDoc.productAndPriceDoc.productDoc.pro_PromotionPrice * theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity;
          }
          
          theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice * theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity;;
          if (theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy == 1) {
              theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice * theOpportunityDoc.productAndPriceDoc.productDoc.pro_Discount * theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity;
          } else {
              theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = theOpportunityDoc.productAndPriceDoc.productDoc.pro_PromotionPrice * theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity;
          }
          theOpportunityDoc.productAndPriceDoc.productArray = [NSMutableArray arrayWithObject:theOpportunityDoc.productAndPriceDoc.productDoc]; //GPB-922
          
          [_tableView reloadData];
      } failure:^{}];
*/
      /*
  } failure:^(NSError *error) {
      [SVProgressHUD dismiss];
  }];
       */
}

// --add Progress
- (void)requestAddProgress
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"CreatorID\":%ld,\"OpportunityID\":%ld,\"Progress\":%ld,\"Description\":\"%@\",\"Quantity\":%ld,\"BranchID\":%ld,\"TotalSalePrice\":%.2Lf,\"ProductCode\":%lld,\"ProductType\":%ld,\"CustomerID\":%ld}", (long)ACC_COMPANTID, (long)ACC_ACCOUNTID, (long)theOpportunityDoc.opp_ID, (long)theOpportunityDoc.opp_Progress, theOpportunityDoc.opp_Describe, (long)theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity, (long)ACC_BRANCHID, theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney,theOpportunityDoc.productAndPriceDoc.productDoc.pro_Code,(long)theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type,(long)theOpportunityDoc.customerId];

    _requestAddProgressOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Opportunity/AddProgress" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected removeAllObjects];
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected removeAllObjects];
            
            NSArray *stepContentArray = [theOpportunityDoc.opp_StepContent componentsSeparatedByString:@"|"];
            
            if (theOpportunityDoc.opp_Progress != stepContentArray.count) {
                OppTabBarController *oppTabBarController = (OppTabBarController *)[[self.navigationController viewControllers] objectAtIndex:1];
                [oppTabBarController setSelectedIndex:101];
                SalesProgressViewController *salesProgressVC = (SalesProgressViewController *)[oppTabBarController.viewControllers objectAtIndex:0];
                salesProgressVC.opportunityID = theOpportunityDoc.opp_ID;
                salesProgressVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                
                ProgressHistoryViewController *ProgressHistoryVC = (ProgressHistoryViewController *)[oppTabBarController.viewControllers objectAtIndex:1];
                ProgressHistoryVC.opportunityID = theOpportunityDoc.opp_ID;
                ProgressHistoryVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                [SVProgressHUD showSuccessWithStatus2:@"新增进度成功！" duration:2.0 touchEventHandle:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
            } else if (ACC_BRANCHID == 0 || (theOpportunityDoc.opp_BranchID != ACC_BRANCHID) || !self.oppInvalid || ![[PermissionDoc sharePermission] rule_MyOrder_Write]) {
                OppTabBarController *oppTabBarController = (OppTabBarController *)[[self.navigationController viewControllers] objectAtIndex:1];
                [oppTabBarController setSelectedIndex:101];
                SalesProgressViewController *salesProgressVC = (SalesProgressViewController *)[oppTabBarController.viewControllers objectAtIndex:0];
                salesProgressVC.opportunityID = theOpportunityDoc.opp_ID;
                salesProgressVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                
                ProgressHistoryViewController *ProgressHistoryVC = (ProgressHistoryViewController *)[oppTabBarController.viewControllers objectAtIndex:1];
                ProgressHistoryVC.opportunityID = theOpportunityDoc.opp_ID;
                ProgressHistoryVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                [SVProgressHUD showSuccessWithStatus2:@"新增进度成功！" duration:2.0 touchEventHandle:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否将该需求生成订单?" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
                [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        OrderConfirmViewController *orderConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
                        orderConfirmVC.theOpportunityDoc = theOpportunityDoc;
                        orderConfirmVC.orderEditMode = OrderEditModeConfirm2;
                        [self.navigationController pushViewController:orderConfirmVC animated:YES];
                    } else {
                        OppTabBarController *oppTabBarController = (OppTabBarController *)[[self.navigationController viewControllers] objectAtIndex:1];
                        [oppTabBarController setSelectedIndex:101];
                        SalesProgressViewController *salesProgressVC = (SalesProgressViewController *)[oppTabBarController.viewControllers objectAtIndex:0];
                        salesProgressVC.opportunityID = theOpportunityDoc.opp_ID;
                        salesProgressVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                        
                        ProgressHistoryViewController *ProgressHistoryVC = (ProgressHistoryViewController *)[oppTabBarController.viewControllers objectAtIndex:1];
                        ProgressHistoryVC.opportunityID = theOpportunityDoc.opp_ID;
                        ProgressHistoryVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
        } failure:^(NSInteger code, NSString *error) {
            if (code == 0) {
                [SVProgressHUD showErrorWithStatus2:@"新增进度失败！" touchEventHandle:^{}];
            }
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _requestAddProgressOperation = [[GPHTTPClient shareClient] requestAddProgressByJson:theOpportunityDoc success:^(id xml) {
        [SVProgressHUD dismiss];
//        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
        
        NSString *origalString = (NSString*)xml;
        NSString *regexString = @"[{*}]";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
        if(!array || [array count] < 2)
            return;
        origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
        
        NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
        NSString *data = [dataDic objectForKey:@"Code"];
        if ((NSNull *)data == [NSNull null]) {
            return;
        }
        if([data integerValue] == 0)
        {
            [SVProgressHUD showErrorWithStatus2:@"新增进度失败！" touchEventHandle:^{
            }];
            return;
        }
        
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected removeAllObjects];
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected removeAllObjects];
            
            NSArray *stepContentArray = [theOpportunityDoc.opp_StepContent componentsSeparatedByString:@"|"];
            
            if (theOpportunityDoc.opp_Progress != stepContentArray.count) {
                OppTabBarController *oppTabBarController = (OppTabBarController *)[[self.navigationController viewControllers] objectAtIndex:1];
                [oppTabBarController setSelectedIndex:101];
                SalesProgressViewController *salesProgressVC = (SalesProgressViewController *)[oppTabBarController.viewControllers objectAtIndex:0];
                salesProgressVC.opportunityID = theOpportunityDoc.opp_ID;
                salesProgressVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                
                ProgressHistoryViewController *ProgressHistoryVC = (ProgressHistoryViewController *)[oppTabBarController.viewControllers objectAtIndex:1];
                ProgressHistoryVC.opportunityID = theOpportunityDoc.opp_ID;
                ProgressHistoryVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                [SVProgressHUD showSuccessWithStatus2:@"新增进度成功！" duration:2.0 touchEventHandle:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
            } else if (ACC_BRANCHID == 0 || (theOpportunityDoc.opp_BranchID != ACC_BRANCHID) || !self.oppInvalid ) {
                OppTabBarController *oppTabBarController = (OppTabBarController *)[[self.navigationController viewControllers] objectAtIndex:1];
                [oppTabBarController setSelectedIndex:101];
                SalesProgressViewController *salesProgressVC = (SalesProgressViewController *)[oppTabBarController.viewControllers objectAtIndex:0];
                salesProgressVC.opportunityID = theOpportunityDoc.opp_ID;
                salesProgressVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                
                ProgressHistoryViewController *ProgressHistoryVC = (ProgressHistoryViewController *)[oppTabBarController.viewControllers objectAtIndex:1];
                ProgressHistoryVC.opportunityID = theOpportunityDoc.opp_ID;
                ProgressHistoryVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                [SVProgressHUD showSuccessWithStatus2:@"新增进度成功！" duration:2.0 touchEventHandle:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否将该需求生成订单?" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
                [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        OrderConfirmViewController *orderConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
                        orderConfirmVC.theOpportunityDoc = theOpportunityDoc;
                        orderConfirmVC.orderEditMode = OrderEditModeConfirm2;
                        [self.navigationController pushViewController:orderConfirmVC animated:YES];
                    } else {
                        OppTabBarController *oppTabBarController = (OppTabBarController *)[[self.navigationController viewControllers] objectAtIndex:1];
                        [oppTabBarController setSelectedIndex:101];
                        SalesProgressViewController *salesProgressVC = (SalesProgressViewController *)[oppTabBarController.viewControllers objectAtIndex:0];
                        salesProgressVC.opportunityID = theOpportunityDoc.opp_ID;
                        salesProgressVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                        
                        ProgressHistoryViewController *ProgressHistoryVC = (ProgressHistoryViewController *)[oppTabBarController.viewControllers objectAtIndex:1];
                        ProgressHistoryVC.opportunityID = theOpportunityDoc.opp_ID;
                        ProgressHistoryVC.productType   = theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type;
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];

            }
//        } failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */

}

// --update Progress
#warning change return Code
- (void)requestUpdateProgress
{
    [SVProgressHUD showWithStatus:@"Loading"];
    if (theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney - theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney < 0.0001 && theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney - theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney > -0.0001 )//如果没有自定义价格，TotalSaleMoney = -1
        theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = -1;

    
    NSString *par = [NSString stringWithFormat:@"{\"ProgressID\":%ld,\"AccountID\":%ld,\"Description\":\"%@\",\"Quantity\":%ld,\"UpdaterID\":%ld,\"TotalSalePrice\":%.2Lf}", (long)theOpportunityDoc.opp_ProgressID, (long)ACC_ACCOUNTID, theOpportunityDoc.opp_Describe, (long)theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity, (long)ACC_ACCOUNTID, theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney];

    _requestUpdateProgressOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Opportunity/UpdateProgress" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];

        NSString *code = [json objectForKey:@"Code"];
        if ((NSNull *)code == [NSNull null]) {
            return;
        }
        if([code integerValue] == 1)
        {
            [SVProgressHUD showSuccessWithStatus2:@"更新进度成功！" duration:kSvhudtimer touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else
            [SVProgressHUD showErrorWithStatus2:@"更新进度失败！" touchEventHandle:^{}];

    } failure:^(NSError *error) {
        
    }];
    
    
    /*
    _requestUpdateProgressOperation = [[GPHTTPClient shareClient] requestUpdateProgressByJson:theOpportunityDoc success:^(id xml) {
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
        NSString *code = [dataDic objectForKey:@"Code"];
        if ((NSNull *)code == [NSNull null]) {
            return;
        }
        if([code integerValue] == 0)
        {
            [SVProgressHUD showErrorWithStatus2:@"更新进度失败！" touchEventHandle:^{
            }];
            return;
        }else
            [SVProgressHUD showSuccessWithStatus2:@"更新进度成功！" duration:2.0 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
//         [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {} failure:^{}];
    } failure:^(NSError *error) {
         [SVProgressHUD dismiss];
    }];
     */
}

@end
