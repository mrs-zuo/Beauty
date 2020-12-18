//
//  AccountIntegralRecharge_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/6/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AccountIntegralRecharge_ViewController.h"
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
#import "GPBHTTPClient.h"
#import "NSData+Base64.h"
#import "SelectCustomersViewController.h"
#import "PayThirdForWeiXin_ViewController.h"

typedef NS_ENUM(NSInteger, COUNSELORTYPE) {
    COUNSELORPERSON = 0,
    COUNSELORSLAVE = 1
};
@interface AccountIntegralRecharge_ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate,SelectCustomersViewControllerDelegate,UIScrollViewDelegate>
{
    
}
@property (weak, nonatomic) AFHTTPRequestOperation *requestRechargeOperation;
@property(nonatomic,strong) UITableView * integralRechargeTableView;
@property (assign, nonatomic) long double rechargeMoney;
@property (assign, nonatomic) long double presentedMoney;
@property (nonatomic, assign) NSInteger cusCount;
@property (strong, nonatomic) NSString *rechargeRemark;
@property (strong, nonatomic) UserDoc *userDoc;
@property (nonatomic, strong) NSArray *rechargeArray;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (nonatomic, assign) COUNSELORTYPE type;
@property (nonatomic, strong) NSMutableArray *slaveArray;
@property (nonatomic, strong) NSMutableString *slaveNames;
@property (nonatomic, strong) NSMutableString *slaveID;
@property (assign, nonatomic) long double eCardBalance;
@property (assign,nonatomic)NSString * accountTitle;
@property (assign,nonatomic)NSInteger rechargeWay;

@end

@implementation AccountIntegralRecharge_ViewController
@synthesize integralRechargeTableView;
@synthesize eCardBalance;
@synthesize presentedMoney;
@synthesize rechargeMoney, rechargeRemark, userDoc;
@synthesize cusCount;
@synthesize rechargeArray,rechargeWay;
@synthesize type;
@synthesize slaveArray;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
    
}

- (void)keyboardDidShown:(NSNotification *)obj
{
//    NSLog(@"keyboardDidShown:");
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    
    if (_requestRechargeOperation || [_requestRechargeOperation isExecuting]) {
        [_requestRechargeOperation cancel];
        _requestRechargeOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [[[UIApplication sharedApplication] keyWindow] bounds];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (self.accountType== 2) {
        _accountTitle = @"积分";
    }else{  _accountTitle = @"现金券";  }
    
    [self initTableView];
    [self initData];
}
- (void)initTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:[NSString stringWithFormat:@"%@充值",_accountTitle]];
    [self.view addSubview:navigationView];
    integralRechargeTableView = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f) style:UITableViewStyleGrouped];
    integralRechargeTableView.backgroundColor = [UIColor clearColor];
    integralRechargeTableView.backgroundView  = nil;
    integralRechargeTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    integralRechargeTableView.separatorColor = kTableView_LineColor;
    integralRechargeTableView.showsHorizontalScrollIndicator = NO;
    integralRechargeTableView.showsVerticalScrollIndicator = NO;
    integralRechargeTableView.autoresizingMask = UIViewAutoresizingNone;
    integralRechargeTableView.delegate = self;
    integralRechargeTableView.dataSource = self;
    [self.view addSubview:integralRechargeTableView];
    
    if (IOS7 || IOS8) {
        integralRechargeTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        integralRechargeTableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        integralRechargeTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(requestRecharge)];
    [footerView showInTableView:integralRechargeTableView];
    
    _initialTVHeight = integralRechargeTableView.frame.size.height;
}

- (void)initData
{
    self.rechargeArray = @[@"直冲", @"余额转入"];
    rechargeWay = 1;//1 直冲  2 余额转入
    cusCount = 1;
    rechargeMoney = 0.00f;
    presentedMoney = 0.00f;
    rechargeRemark = @"";
    userDoc = [[UserDoc alloc] init];
    userDoc.user_Id = ACC_ACCOUNTID;
    userDoc.user_Name = ACC_ACCOUNTName;
    userDoc.user_SelectedState = YES;
    self.slaveArray = [NSMutableArray arrayWithObject:userDoc];
    self.slaveNames = [NSMutableString string];
    self.slaveID = [NSMutableString string];
}

- (NSString *)slaveNames
{
    NSMutableArray *nameArray = [NSMutableArray array];
    if (self.slaveArray.count) {
        for (UserDoc *user in self.slaveArray) {
            [nameArray addObject:user.user_Name];
        }
    }
    NSLog(@"the nameArray is %@", [nameArray componentsJoinedByString:@"、"]);
    return [nameArray componentsJoinedByString:@"、"];
}

- (NSString *)slaveID
{
    NSMutableArray *slaveIdArray = [NSMutableArray array];
    NSMutableString *str = [NSMutableString string];
    if (self.slaveArray.count) {
        for (UserDoc *user in self.slaveArray) {
            [slaveIdArray addObject:@(user.user_Id)];
        }
        NSString *tmpIds = [slaveIdArray componentsJoinedByString:@","];
        [str appendString:[NSString stringWithFormat:@"%@", tmpIds]];
    } else {
        [str appendString:@"\"\""];
    }
    NSLog(@"str is %@", str);
    return str;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if(section==0)
      return 1;
    else if(section ==1)
        return 1;
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"NormalEditCell_NotEditing";
    NormalEditCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.valueText.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.textColor = [UIColor blackColor];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
                cell.titleLabel.text = @"顾客";
                cell.valueText.text = customer.cus_Name;
            }
                return cell;
                break;
            case 1:
                cell.titleLabel.text = @"美丽顾问";
                cell.valueText.textColor = kColor_Editable;
                cell.valueText.text = (userDoc.user_Name.length <= 0 ? @"请选择美丽顾问" : userDoc.user_Name);
                cell.valueText.frame = CGRectMake(110.0f, kTableView_HeightOfRow/2 - 30.0f/2, 180, 30.0f);
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [cell.contentView  addSubview:arrowsImage];
                return cell;
                break;
        }
        return cell;
    }
    
    static NSString *editIdentity = @"NormalEditCell_Editing";
    NormalEditCell *editCell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:editIdentity];
    if (editCell == nil) {
        editCell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        editCell.valueText.delegate = self;
        editCell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
        editCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section ==1) {
        cell.titleLabel.text =[NSString stringWithFormat:@"剩余%@",_accountTitle];
        if ([_accountTitle isEqualToString:@"积分"]) {
             cell.valueText.text = [NSString stringWithFormat:@"%.2f",self.Balance];
        }else
        {
             cell.valueText.text = [NSString stringWithFormat:@"%@ %.2f",MoneyIcon,self.Balance];
        }
       
    }
    if (indexPath.section == 2) {
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text =@"充值方式";
                    cell.valueText.textColor = kColor_Editable;
                    cell.valueText.text = [self.rechargeArray objectAtIndex:self.rechargeWay-1];
                    return cell;
                    break;
                case 1:
                    editCell.titleLabel.text = [NSString stringWithFormat:@"充值%@",_accountTitle];
                    editCell.valueText.text =  rechargeMoney == 0 ? @"" : [NSString stringWithFormat:@"%.2Lf", rechargeMoney];
                    editCell.valueText.placeholder =[NSString stringWithFormat:@"请输入充值%@",_accountTitle];
                    editCell.valueText.tag = 1000 + TAG(indexPath);
                    if ((IOS7 || IOS8)) {
                        [editCell.valueText setTintColor:[UIColor blueColor]];
                    }
                    return editCell;
                    break;
            }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"备注";
            cell.valueText.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            
            UILabel *accessoryLabel = [UILabel initNormalLabelWithFrame:CGRectMake(200.0f, 75.0f, 100.0f, 15.0f) title:[NSString stringWithFormat:@"%lu/200", (unsigned long)[rechargeRemark length]]];
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
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
                [cell.contentView addSubview:accessoryLabel];
                [cell.contentView addSubview:textView];
            }
            return cell;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        self.type = COUNSELORPERSON;
        [self chosePersion:COUNSELORPERSON];
    }else if (indexPath.section == 0 && indexPath.row == 2) {
        self.type = COUNSELORSLAVE;
        [self chosePersion:COUNSELORSLAVE];
    }else if(indexPath.section == 2 &&indexPath.row==0)
    {
        [self selectionEcardWay];
    }
    
}

- (void)selectionEcardWay
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值方式" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"直冲", nil];
    if([[PermissionDoc sharePermission] rule_BalanceCharge]){
        [alertView addButtonWithTitle: @"余额转入"];
    }
    
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex !=0) {
            rechargeWay = buttonIndex;
        }
        NSLog(@"the buttonIndex is %ld", (long)buttonIndex);
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:2];
        [integralRechargeTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)chosePersion:(COUNSELORTYPE)choseType
{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    [selectCustomer setSelectModel:self.type userType: (choseType == COUNSELORPERSON) ? 3 : 1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:(self.type == COUNSELORPERSON ? @[userDoc]:self.slaveArray)];
    selectCustomer.navigationTitle = (choseType == COUNSELORPERSON ? @"选择美丽顾问" : @"选择业绩参与者");
    selectCustomer.personType = (choseType == COUNSELORPERSON ? CustomePersonGroup : CustomePersonDefault);
    selectCustomer.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

#pragma mark - SelectCustomersViewControllerDelegate
- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    if (self.type == COUNSELORPERSON) {
        userDoc = [userArray firstObject];
        if (userDoc == nil)
            userDoc = [[UserDoc alloc] init];
    } else {
        self.slaveArray = [NSMutableArray arrayWithArray:userArray];
    }
    [integralRechargeTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
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
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textField.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    }
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    if (textField.tag > 2000) {
        indexPath = INDEX((textField.tag % 2000));
    } else if (textField.tag > 1000) {
        indexPath = INDEX((textField.tag % 1000));
    } else {
        indexPath = [integralRechargeTableView indexPathForCell:cell];
    }
    
    
    rechargeMoney = [textField.text doubleValue];
  
//    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:2];
//
//    [integralRechargeTableView reloadRowsAtIndexPaths:@[path, indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [integralRechargeTableView reloadData];
}

#pragma mark -  UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    int64_t delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self scrollToTextView:textView];
    });
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self scrollToTextView:textView];
    
    rechargeRemark = textView.text;
    
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textView.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    }
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)rechargeRemark.length];
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    
    rechargeRemark = textView.text;
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
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
                rechargeRemark = textView.text;
            }
            label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)rechargeRemark.length];
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 200) {
            textView.text = [toBeString substringToIndex:200];
            rechargeRemark = textView.text;
        }
        label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)rechargeRemark.length];
    }
}


#pragma mark - Keyboard Notification
-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = integralRechargeTableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
    integralRechargeTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    CGRect tvFrame = integralRechargeTableView.frame;
    tvFrame.size.height = _initialTVHeight;
    integralRechargeTableView.frame = tvFrame;
}

- (void)scrollToTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath* path = [integralRechargeTableView indexPathForCell:cell];
    [integralRechargeTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)scrollToTextView:(UITextView *)textView
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:3];
    [integralRechargeTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [integralRechargeTableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        _prevCaretRect = newCursorRect;
        [integralRechargeTableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(290.0f, 200.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
    [integralRechargeTableView beginUpdates];
    [integralRechargeTableView endUpdates];
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

#pragma mark - 接口

- (void)requestRecharge
{
    if (rechargeRemark == nil) {
        rechargeRemark = @" ";
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerID = appDelegate.customer_Selected.cus_ID;
    
    if (kMenu_Type == 1 && customerID == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNoChooserCustomerNotification object:nil];
        return;
    }
    
    if (rechargeMoney == 0 ) {
        [SVProgressHUD showErrorWithStatus2:[NSString stringWithFormat:@"请输入充值%@!",_accountTitle] touchEventHandle:^{}];
        return;
    }
    
     NSString *showMes = [NSString stringWithFormat:@"本次充值%@ %.2Lf",_accountTitle,rechargeMoney];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:showMes delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [SVProgressHUD showWithStatus:@"Loading"];
        
            NSDictionary * otherDic =@{@"ChangeType":@3,
                                       @"CardType":@(self.accountType),
                                       @"DepositMode":@(rechargeWay),
                                       @"UserCardNo":self.IntergralRechargeCardId,
                                       @"CustomerID":@((long)customerID),
                                       @"ResponsiblePersonID":@(0),
                                       @"Amount":@((double)rechargeMoney),
                                       @"Remark":rechargeRemark,
                                       };
            
            _requestRechargeOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/CardRecharge" andParameters:otherDic failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
                [SVProgressHUD dismiss];
                [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
                    NSLog(@"cardrecharge =%@",data);
                    [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                } failure:^(NSInteger code, NSString *error) {
                }];
            } failure:^(NSError *error) {
                
            }];

        }
    }];
}

@end
