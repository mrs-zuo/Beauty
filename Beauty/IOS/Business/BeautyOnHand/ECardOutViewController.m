//
//  ECardOutViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-8-27.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ECardOutViewController.h"
#import "WAmountConverter.h"
#import "DEFINE.h"
#import "UITextField+InitTextField.h"
#import "UIPlaceHolderTextView.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "UILabel+InitLabel.h"
#import "AppDelegate.h"
#import "GPHTTPClient.h"
#import "InitialSlidingViewController.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "NavigationView.h"
#import "UIButton+InitButton.h"
#import "FooterView.h"
#import "UserDoc.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "NormalEditCell.h"
#import "NumTextField.h"
#import "GPBHTTPClient.h"
#import "NSData+Base64.h"
#import "SelectCustomersViewController.h"
#import "PerformanceTableViewCell.h"

@interface ECardOutViewController ()<SelectCustomersViewControllerDelegate,PerformanceTableViewCellDelegate>

@property (nonatomic, weak) AFHTTPRequestOperation *requestRechargeOutOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetBasicInfoOperation;
@property (nonatomic, strong) UITableView *outtableView;

@property (strong, nonatomic) UITextView *selected_TextView;
@property (strong, nonatomic) NSArray *pickerData;
@property (nonatomic, assign) NSInteger outWay;

@property (strong, nonatomic) NSString *outmoneyRemark;

@property (assign, nonatomic) CGFloat initialTVHeight;
@property (assign, nonatomic) long double outMoney;
@property (assign, nonatomic) CGRect prevCaretRect;

@property (nonatomic, strong) NSMutableArray *slaveArray;
//@property (nonatomic, strong) NSMutableString *slaveNames;
//@property (nonatomic, strong) NSMutableString *slaveID;

@end

@implementation ECardOutViewController
@synthesize eCardBalance;
@synthesize outtableView;
@synthesize outMoney;
@synthesize outmoneyRemark;
@synthesize pickerData;
@synthesize outWay;
@synthesize selected_TextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)   name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.baseEditing = YES;
    
    pickerData = [NSArray arrayWithObjects:@"直扣", @"退款", nil];
    
    outMoney = 0.0f;
    outWay = 0;
    outmoneyRemark = @"";
    
    UserDoc *userDoc = [[UserDoc alloc] init];
    userDoc.user_Id = ACC_ACCOUNTID;
    userDoc.user_Name = ACC_ACCOUNTName;
    userDoc.user_SelectedState = YES;

    self.slaveArray = [[NSMutableArray alloc] init];
//    self.slaveNames = [NSMutableString string];
//    self.slaveID = [NSMutableString string];

    [self initTableView];
    [self requesCustomertList];
}

//- (NSString *)slaveNames
//{
//    NSMutableArray *nameArray = [NSMutableArray array];
//    if (self.slaveArray.count) {
//        for (UserDoc *user in self.slaveArray) {
//            [nameArray addObject:user.user_Name];
//        }
//    }
//    NSLog(@"the nameArray is %@", [nameArray componentsJoinedByString:@"、"]);
//    return [nameArray componentsJoinedByString:@"、"];
//}
//
//
//- (NSArray *)slaveID
//{
//    NSMutableArray *slaveIdArray = [NSMutableArray array];
//    NSMutableString *str = [NSMutableString string];
//    if (self.slaveArray.count) {
//        for (UserDoc *user in self.slaveArray) {
//            [slaveIdArray addObject:@(user.user_Id)];
//        }
//        NSString *tmpIds = [slaveIdArray componentsJoinedByString:@","];
//        [str appendString:[NSString stringWithFormat:@"[%@]", tmpIds]];
//    } else {
//        [str appendString:@""];
//    }
//    NSLog(@"str is %@", str);
//    return slaveIdArray;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    if (_requestRechargeOutOperation || [_requestRechargeOutOperation isExecuting]) {
        [_requestRechargeOutOperation cancel];
        _requestRechargeOutOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

}

#pragma mark initTable
- (void)initTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"账户支出"];
    [self.view addSubview:navigationView];
    
    outtableView = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    outtableView.backgroundColor = [UIColor clearColor];
    outtableView.backgroundView = nil;
    outtableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    outtableView.separatorColor = kTableView_LineColor;
    outtableView.showsHorizontalScrollIndicator = NO;
    outtableView.showsVerticalScrollIndicator = NO;
    outtableView.autoresizingMask = UIViewAutoresizingNone;
    outtableView.sectionFooterHeight = 5.0f;
    outtableView.delegate = self;
    outtableView.dataSource = self;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        outtableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
        outtableView.sectionFooterHeight = 0;
        outtableView.sectionHeaderHeight = 10;
    }
    if (IOS7 || IOS8) {
        outtableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        outtableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        outtableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(requestOutRecharge)];
    [footerView showInTableView:outtableView];
    
    
    _initialTVHeight = outtableView.frame.size.height;
    [self.view addSubview:outtableView];
    
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return  (2 + self.slaveArray.count);
    }else if (section == 2 || section == 3) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = [NSString stringWithFormat:@"CellNotEditing%@",indexPath];
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.textColor = [UIColor blackColor];
    cell.valueText.userInteractionEnabled = NO;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
            cell.titleLabel.text = @"顾客";
            cell.valueText.text = customer.cus_Name;
            return cell;
        } else  if(indexPath.row == 1) {
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [cell.contentView  addSubview:arrowsImage];
            cell.valueText.frame = CGRectMake(105.0f, kTableView_HeightOfRow/2 - 30.0f/2, 185, 30.0f);
            cell.titleLabel.text = @"业绩参与";
            cell.valueText.textColor = kColor_Editable;
            cell.valueText.text = @"请选择业绩参与者  ";
//            cell.valueText.text = ([self.slaveNames isEqualToString:@""] ? @"请选择业绩参与者  ": self.slaveNames);
            return cell;
        }else{
            return [self configPerformanceProportionCell:tableView indexPath:indexPath];
        }
    }
    
    if (indexPath.section == 1) {
        cell.titleLabel.text = @"余额";
        cell.valueText.text = MoneyFormat(eCardBalance);
        return cell;
    }
    
    if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
            {
                cell.titleLabel.text = @"支出方式";
                cell.valueText.textColor = kColor_Black;
                cell.valueText.text = [pickerData objectAtIndex:outWay];
                return cell;
            }
            case 1:
            {
                static NSString *dentiFer = @"dentiFer";
                NormalEditCell *cell = [outtableView dequeueReusableCellWithIdentifier:dentiFer];
                if (!cell) {
//                    cell = [[NormalEditCell alloc] initWithStyleEditNum:UITableViewCellStyleDefault reuseIdentifier:dentiFer];
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dentiFer];
                    cell.valueText.delegate = self;
                    cell.valueText.placeholder = @"请输入金额";
                    cell.valueText.clearsOnBeginEditing = YES;
                    cell.valueText.userInteractionEnabled = YES;
                    cell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.titleLabel.text = @"支出金额";
                cell.valueText.tag = TAG(indexPath);
                cell.valueText.text =  outMoney == 0 ? @"" : [NSString stringWithFormat:@"%.2Lf", outMoney];
//                 ECardOutViewController *__weak weakSelf = self;
//                cell.numText.startBlock = ^(NumTextField *textField){
//                    int64_t delayInSeconds = 0.6;
//                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                        [self scrollToTextField:textField];
//                    });
//                };
//                cell.numText.endBlock = ^(NumTextField *textField){
//                    self.outMoney = [textField.text doubleValue];
//                    if (self.outMoney > self.eCardBalance) {
//                        [SVProgressHUD showErrorWithStatus2:@"支出金额超出!" touchEventHandle:^{}];
//                        self.outMoney = 0.0f;
//                    }
//                    textField.text =  self.outMoney == 0 ? @"" : [NSString stringWithFormat:@"%.2f", weakSelf.outMoney];
//                };
                return cell;
            }
        }
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"备注";
            cell.valueText.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            
            UILabel *accessoryLabel = [UILabel initNormalLabelWithFrame:CGRectMake(200.0f, 75.0f, 100.0f, 15.0f) title:[NSString stringWithFormat:@"%lu/200", (unsigned long)[outmoneyRemark length]]];
            accessoryLabel.textColor = [UIColor blackColor];
            accessoryLabel.font = kFont_Light_14;
            accessoryLabel.textAlignment = NSTextAlignmentRight;
            accessoryLabel.tag = 101;
            
            static NSString *cellIdentity = @"ss";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
            cell.backgroundColor = [UIColor whiteColor];
            
            UIPlaceHolderTextView *textView = [UIPlaceHolderTextView initNormalTextViewWithFrame:CGRectMake(5.0f, 0.0f, 300.0f, 75.0f)
                                                                                            text:@""
                                                                                     placeHolder:@""];
            textView.tag = 102;
            textView.delegate = self;
            textView.text = outmoneyRemark;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
                [cell.contentView addSubview:accessoryLabel];
                [cell.contentView addSubview:textView];
            }
            return cell;
        }
}
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 && indexPath.row == 1) {
        return 90.0f;
    } else {
        return kTableView_HeightOfRow;
    }
}



#pragma mark - didSelectRowAtIndexPath
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self chosePersion];
    }
//    if (indexPath.section == 2 && indexPath.row == 0) {
//        [self chosePayWay:indexPath];
//    }
}
#pragma mark -  配置cell
//业绩参与人比例
- (PerformanceTableViewCell *)configPerformanceProportionCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier =[NSString stringWithFormat:@"PerformanceCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.delegate = self;
    UserDoc *userdoc;
    if (self.slaveArray.count > 0) {
        userdoc= self.slaveArray[indexPath.row - 2];
        performanceCell.nameLab.text = userdoc.user_Name;
        performanceCell.numText.text = userdoc.user_ProfitPct;
    }
    return performanceCell;
}
#pragma mark - PerformanceTableViewCellDelegate
-(void)PerformanceTableViewCellWithDidEndEditing:(UITextField *)textField
{
    PerformanceTableViewCell *cell;
    if (IOS7) {
        cell = (PerformanceTableViewCell *)textField.superview.superview.superview;
    }else{
        cell = (PerformanceTableViewCell *)textField.superview.superview;
    }
//    PerformanceTableViewCell *cell = (PerformanceTableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [self.outtableView indexPathForCell:cell];
    NSLog(@"indexPath.row  == %ld",(long)indexPath.row);
    if (indexPath.row > 0) {
        UserDoc *user =self.slaveArray[indexPath.row - 2];
        user.user_ProfitPct = textField.text;
    }
    //    [textField resignFirstResponder];
    //    [myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 选择业绩参与者
- (void)chosePersion
{
    SelectCustomersViewController *selectCustomer = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    [selectCustomer setSelectModel:1 userType:1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:self.slaveArray];
    selectCustomer.navigationTitle = @"选择业绩参与者";
    selectCustomer.personType = CustomePersonDefault;
    selectCustomer.delegate = self;
    selectCustomer.customerId = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

#pragma mark - SelectCustomersViewControllerDelegate
- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    self.slaveArray = [NSMutableArray arrayWithArray:userArray];
    [self.outtableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}



- (void)chosePayWay:(NSIndexPath *)inPath
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"支出方式" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"直扣",@"退款", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        NSLog(@"the buttonIndex is %ld --- title %@", (long)buttonIndex, [alertView buttonTitleAtIndex:buttonIndex]);
        if (buttonIndex != 0) {
            outWay = buttonIndex - 1;
            [self.outtableView reloadRowsAtIndexPaths:@[inPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    int64_t delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self scrollToTextField:textField];
    });
}

//add begin by zhangwei map GPB-918
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    if([textField text])
    {
        if(textField.text.length > 10)
            textField.text = [NSString stringWithString:[textField.text substringToIndex:10]];
    }
}
//add end by zhangwei map GPB-918
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    NSRange decRange = [textField.text rangeOfString:@"."];
    if (decRange.length && (textField.text.length - decRange.location > 2 || [string isEqualToString:@"."])) {
        return NO;
    }
    
    static NSCharacterSet *charSet = nil;
    if (charSet == nil) {
        charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    }
    __block BOOL result = YES;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([substring rangeOfCharacterFromSet:charSet].location == NSNotFound) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.outMoney = [textField.text doubleValue];
    if (self.outMoney > self.eCardBalance) {
        [SVProgressHUD showErrorWithStatus2:@"支出金额超出!" touchEventHandle:^{}];
        self.outMoney = 0.0f;
    }
    textField.text = (self.outMoney == 0 ? @"" : [NSString stringWithFormat:@"%.2Lf", self.outMoney]);
}

#pragma 备注字数统计
-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;

    outmoneyRemark = textView.text;
    UITableViewCell *cell = nil;
    if (IOS6 || IOS8) {
        cell = (UITableViewCell *)textView.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    }
    UILabel *label = (UILabel *)[cell viewWithTag:101];

    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 200) {
                textView.text = [toBeString substringToIndex:200];
                outmoneyRemark = textView.text;
            }
            label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)outmoneyRemark.length];
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 200) {
            textView.text = [toBeString substringToIndex:200];
            outmoneyRemark = textView.text;
        }
        label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)outmoneyRemark.length];
    }
}

#pragma mark -  UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.textView_Selected = textView;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    selected_TextView = textView;
    [self scrollToTextView:selected_TextView];

}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.textView_Selected = nil;
}
#pragma mark - Keyboard Notification

-(void)keyboardDidShow:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = outtableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
    outtableView.frame = tvFrame;
    [UIView commitAnimations];
    if (self.textView_Selected) {
        [self scrollToTextView:self.textView_Selected];
    }
}

-(void)keyboardDidHidden:(NSNotification*)notification
{
    CGRect tvFrame = outtableView.frame;
    tvFrame.size.height = _initialTVHeight;
    outtableView.frame = tvFrame;
}

- (void)scrollToTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath* path = [outtableView indexPathForCell:cell];
    [outtableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)scrollToTextView:(UITextView *)textView
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:3];
    [outtableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [outtableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        _prevCaretRect = newCursorRect;
        [self.outtableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(290.0f, 200.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
    [outtableView beginUpdates];
    [outtableView endUpdates];
}

#pragma mark UIScrollViewDelegate
//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark - 大小写转换

- (NSString *)convertByPayTotal:(CGFloat)paytotal
{
    NSString *str = [NSString stringWithFormat:@"%.2f",paytotal];
    if (paytotal < 1) {
        NSString *number1 = [str substringWithRange:NSMakeRange(2, 1)];
        NSString *number2 = [str substringWithRange:NSMakeRange(3, 1)];
        
        NSString *cNumber1 = [self convert:number1];
        NSString *cNumber2 = [self convert:number2];
        
        return [NSString stringWithFormat:@"零元%@角%@分", cNumber1, cNumber2];
    } else {
        NSArray *array = [str componentsSeparatedByString:@"."];
        
        NSMutableString *retStr = [NSMutableString string];
        [retStr appendString:convert(array[0])];
        
        if ([array[1] isEqualToString:@"00"] ) {
            [retStr appendString:@"元整"];
        }else {
            CGFloat decimals = paytotal - (int)paytotal;
            NSString *str1 = [NSString stringWithFormat:@"%.2f",decimals];
            
            NSString *number3 = [str1 substringWithRange:NSMakeRange(2, 1)];
            NSString *number4 = [str1 substringWithRange:NSMakeRange(3, 1)];
            
            NSString *cNumber3 = [self convert:number3];
            NSString *cNumber4 = [self convert:number4];
            
            [retStr appendString:[NSString stringWithFormat:@"元%@角%@分", cNumber3, cNumber4]];
        }
        return retStr;
    }
}

- (NSString *)convert:(NSString *)number
{
    switch ([number integerValue]) {
        case 0: return @"零"; break;
        case 1: return @"壹"; break;
        case 2: return @"贰"; break;
        case 3: return @"叁"; break;
        case 4: return @"肆"; break;
        case 5: return @"伍"; break;
        case 6: return @"陆"; break;
        case 7: return @"柒"; break;
        case 8: return @"捌"; break;
        case 9: return @"玖"; break;
        default:break;
    }
    return nil;
}
#pragma mark - 组装Slavers
-(NSMutableArray *)gettingSlavers
{
    NSMutableArray *tempsArrs = [NSMutableArray array];
    if (self.slaveArray.count >0) {
        for (int i = 0; i < self.slaveArray.count ; i ++) {
            UserDoc *user = self.slaveArray[i];
            if (user.user_ProfitPct == nil) {
                user.user_ProfitPct = @"0";
            }
            NSLog(@"user.user_ProfitPct == %@ user_Id == %ld",user.user_ProfitPct,(long)user.user_Id);
            NSDictionary *dic = @{@"SlaveID":@(user.user_Id),@"ProfitPct":@((user.user_ProfitPct.doubleValue / 100))};
            [tempsArrs addObject:dic];
        }
    }
    return tempsArrs;
}

#pragma mark -  接口
- (void)requestOutRecharge
{
    if (outmoneyRemark == nil) {
        outmoneyRemark = @" ";
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerID = appDelegate.customer_Selected.cus_ID;
    
    if (kMenu_Type == 1 && customerID == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNoChooserCustomerNotification object:nil];
        return;
    }

    if ((![[PermissionDoc sharePermission]rule_DirectExpend]) && (outWay == 0)) {
        [SVProgressHUD showErrorWithStatus2:@"您没有直扣权限，无法操作。" touchEventHandle:^{}];
        return;
    }
    
    if (outMoney == 0 ) {
        [SVProgressHUD showErrorWithStatus2: (outWay ? @"请输入退款金额!" : @"请输入转出金额!")touchEventHandle:^{}];
        return;
    }
    
    if (outMoney > eCardBalance) {
        [SVProgressHUD showErrorWithStatus2:@"支出金额超出!" touchEventHandle:^{}];
        return;
    }
    NSLog(@"%@", outmoneyRemark);
    
    NSString *showMes = @"";
    if (outWay == 0) {
        showMes = [NSString stringWithFormat:@"本次转出合计%@%.2Lf，%@。", MoneyIcon, outMoney, [self convertByPayTotal:outMoney]];
    } else {
        showMes = [NSString stringWithFormat:@"本次退款合计%@%.2Lf，%@。", MoneyIcon, outMoney, [self convertByPayTotal:outMoney]];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:showMes delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [SVProgressHUD showWithStatus:@"Loading"];
            
            int changeType = (outWay==0?5:9);
//            NSDictionary * par =@{@"ChangeType":@(changeType),
//                                  @"CardType":@1,
//                                  @"DepositMode":@0,
//                                  @"UserCardNo":self.ecardOutCardId,
//                                  @"CustomerID":@((long)customerID),
//                                  @"Amount":@((double)outMoney),
//                                  @"Remark":[OverallMethods EscapingString:outmoneyRemark],
//                                  @"SlaveID":self.slaveID
//                                  };
            NSDictionary * par =@{@"ChangeType":@(changeType),
                                  @"CardType":@1,
                                  @"DepositMode":@0,
                                  @"UserCardNo":self.ecardOutCardId,
                                  @"CustomerID":@((long)customerID),
                                  @"Amount":@((double)outMoney),
                                  @"Remark":[OverallMethods EscapingString:outmoneyRemark],
                                  @"Slavers":[self gettingSlavers]
                                  };
            
            _requestRechargeOutOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/CardRecharge" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
                [SVProgressHUD dismiss];
                [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
                    NSLog(@"账户支出 =%@",data);
                    [SVProgressHUD showSuccessWithStatus2:message  duration:kSvhudtimer touchEventHandle:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                } failure:^(NSInteger code, NSString *error) {
                }];
            } failure:^(NSError *error) {
                
            }];
        }
    }];

}


- (void)requesCustomertList
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    
    if (customerId == 0 && kMenu_Type == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择顾客" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)customerId];
    
    _requestGetBasicInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/getCustomerBasic" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            [self.slaveArray removeAllObjects];
            
            NSArray *tempArr = [data objectForKey:@"SalesList"];
            if (![tempArr isKindOfClass:[NSNull class]] && tempArr.count > 0) {
                for (NSDictionary * dic in [data objectForKey:@"SalesList"]) {
                    UserDoc * user = [[UserDoc alloc] init];
                    
                    user.user_Name = [dic objectForKey:@"SalesName"];
                    user.user_Id = [[dic objectForKey:@"SalesPersonID"] integerValue];
                    
                    [self.slaveArray addObject:user];
                    
                }
            }
            [self.outtableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}



@end
