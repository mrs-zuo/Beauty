//
//  ProfessionEditViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-11-26.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ProfessionEditViewController.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "CustomerDoc.h"
#import "DEFINE.h"
#import "GDataXMLNode.h"
#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "QuestionDoc.h"
#import "UITextField+InitTextField.h"
#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "OverallMethods.h"
#import "GPNavigationController.h"
#import "UIPlaceHolderTextView.h"
#import "GPBHTTPClient.h"

#define TAG(indexPath)    ((indexPath).section * 20 + (indexPath).row)

@interface ProfessionEditViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateDetailInfoOperation;
@property (assign, nonatomic) CGFloat tableView_Height;
@property (nonatomic) UITextView *textView_Selected;
@end

@implementation ProfessionEditViewController
@synthesize customer;
@synthesize tableView_Height;
@synthesize textView_Selected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    for (int i = 0; i < [customer.cus_Answers count]; i++) {
        NSString *initString = @"";
        if ([[[customer.cus_Answers objectAtIndex:i] question_Answer] isEqualToString:@""] && [[customer.cus_Answers objectAtIndex:i] question_Type] != 0) {
            for (int j = 0; j < [[customer.cus_Answers objectAtIndex:i] question_OptionNumber]; j++) {
                initString = [initString stringByAppendingString:@"0"];
                if (j != [[customer.cus_Answers objectAtIndex:i] question_OptionNumber] - 1) {
                    initString = [initString stringByAppendingString:@"|"];
                }
            }
            [[customer.cus_Answers objectAtIndex:i] setQuestion_Answer:initString];
        }
    }
}

- (void)initTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"编辑专业信息"];
    [self.view addSubview:navigationView];
    ((GPNavigationController*)self.navigationController).canDragBack = YES;
    
    _tableView.allowsSelection = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView  = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }    tableView_Height = _tableView.frame.size.height;
    
    FooterView *footView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确  定" submitAction:@selector(requestUpdateCustomerdetailInfo)];
    [footView showInTableView:_tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_requestUpdateDetailInfoOperation) {
        _requestUpdateDetailInfoOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)requestUpdateCustomerdetailInfo
{
    [textView_Selected resignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    double delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSMutableArray *oldAnswer = [[NSMutableArray alloc] initWithArray:customer.cus_oldAnswer];
        NSMutableArray *newAnswer = [[NSMutableArray alloc] initWithArray:customer.cus_Answers];
        NSMutableString *sendJson = [NSMutableString string];
        [sendJson appendFormat:@"["];
        NSMutableArray *tmpJson = [NSMutableArray array];
        for (int i = 0; i <[oldAnswer count]; i++) {
            if (![[[oldAnswer objectAtIndex:i] question_Answer] isEqualToString:[[newAnswer objectAtIndex:i] question_Answer]]) {
                NSString *sendString = [NSString stringWithFormat:@"{\"QuestionID\":%ld,\"AnswerContent\":\"%@\",\"AnswerID\":%ld}", (long)[[newAnswer objectAtIndex:i] question_ID], [[newAnswer objectAtIndex:i] question_Answer], (long)[[newAnswer objectAtIndex:i] question_AnswerID]];
                [tmpJson addObject:sendString];
            }
        }
        NSString *str = [tmpJson componentsJoinedByString:@","];
        
        customer.cus_AnswerSend = str;
        [self requestUpdateDetailInfo:customer];
    });
}

#pragma mark - Custom Method

- (void)dismissKeyBoard
{
    CGRect rect = _tableView.frame;
    if (rect.size.height != tableView_Height) {
        rect.size.height = tableView_Height;
        _tableView.frame = rect;
    }
    
    [textView_Selected resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect;
    NSValue *keyboardValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    [keyboardValue getValue:&keyboardRect];
    
    
    NSValue *animationDurationValue = [notification userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    float off_Y = tableView_Height - keyboardRect.size.height + 10;
    CGRect rect = _tableView.frame;
    rect.size.height = off_Y;
    
    [UIView beginAnimations:@"showKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    _tableView.frame = rect;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
    CGRect rect = _tableView.frame;
    rect.size.height = tableView_Height;
    _tableView.frame = rect;
    [UIView beginAnimations:@"hideKeyboard" context:nil];
    [UIView setAnimationDuration:0.3];
    _tableView.frame = rect;
    [UIView commitAnimations];

    
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
    NSLog(@"scrollToTextView%ld     %ld", (long)path.section, (long)path.row);
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    if (IOS6 || IOS8) {
        if ([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
            return NO;
        }
    }else {
        if ([touch.view.superview.superview isKindOfClass:[UITableViewCell class]]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[customer.cus_Answers objectAtIndex:section] question_Type] == 0){
        return 2;
    } else {
        return [[customer.cus_Answers objectAtIndex:section] question_OptionNumber] + 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [customer.cus_Answers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *cellIdentifier = @"DetailTitleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
        }
        [cell setSelected:NO];
        UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
        titleLable.numberOfLines = 0;
        [titleLable setFont:kFont_Light_16];
        [titleLable setTextColor:kColor_DarkBlue];
        [titleLable setFrame:CGRectMake(10.0f, 4.0f, 290.0f, [[customer.cus_Answers objectAtIndex:indexPath.section] question_Height] - 8)];
        [titleLable setText:[[customer.cus_Answers objectAtIndex:indexPath.section ] question_Name]];
        return cell;
    } else {
        if ([[customer.cus_Answers objectAtIndex:indexPath.section ] question_Type] == 0) {
            static NSString *cellIdentifier = @"DetailWriteCellTwo";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor whiteColor];
                UIPlaceHolderTextView   *contentText = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(5, 0, 300, 120)];
                contentText.scrollEnabled = YES;
                contentText.backgroundColor = [UIColor whiteColor];
                contentText.placeholder = @"请输入答案";
                contentText.placeholderColor = kColor_Editable;
                [contentText setTextColor:kColor_Editable];
                [contentText setFont:kFont_Light_16];
                contentText.tag = 100;
                [cell.contentView addSubview:contentText];
                if (IOS6) {
                    cell.backgroundColor = [UIColor whiteColor];
                }
            }
            [cell setSelected:NO];
            UIPlaceHolderTextView *contentTextView = (UIPlaceHolderTextView *)[cell viewWithTag:100];
            [contentTextView setText:[[customer.cus_Answers objectAtIndex:indexPath.section ] question_Answer]];
            [contentTextView setDelegate:self];
            NSLog(@"the content view tag is %ld",(long)contentTextView.tag);
            NSLog(@"the index is %ld %ld",(long)indexPath.section,(long)indexPath.row);
            return cell;
        } else {
            NSArray *optionArray = [[[customer.cus_Answers objectAtIndex:indexPath.section] question_Content] componentsSeparatedByString:@"|"];
            NSArray *selectArray = [[[customer.cus_Answers objectAtIndex:indexPath.section] question_Answer] componentsSeparatedByString:@"|"];
            
            if (optionArray.count != selectArray.count) {
                return nil;
            }
            
            static NSString *cellIdentifier = @"DetailAnswerCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor whiteColor];
            }
            UILabel *selectLable = (UILabel *)[cell viewWithTag:100];
            UIImageView *selectStateImageView = (UIImageView *)[cell viewWithTag:101];
            [selectLable setTextColor:kColor_Editable];
            [selectLable setFont:kFont_Light_16];
            [selectLable setText:[optionArray objectAtIndex:(indexPath.row - 1)]];
            if ([[selectArray objectAtIndex:(indexPath.row - 1)] integerValue] == 0) {
                [selectStateImageView setImage:[UIImage imageNamed:@"icon_unChecked"]];
            } else {
                [selectStateImageView setImage:[UIImage imageNamed:@"icon_Checked"]];
            }
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [[customer.cus_Answers objectAtIndex:indexPath.section] question_Height];
    }else {
        if ([[customer.cus_Answers objectAtIndex:indexPath.section] question_Type] == 0) {
            return 130.0f;
        } else {
            return kTableView_HeightOfRow;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != 0) {
        NSArray  *selectArray = [[[customer.cus_Answers objectAtIndex:indexPath.section] question_Answer] componentsSeparatedByString:@"|"];
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([[customer.cus_Answers objectAtIndex:indexPath.section] question_Type] == 0) {
            return;
        } else if ([[customer.cus_Answers objectAtIndex:indexPath.section] question_Type] == 1){
            UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:101];
            
            if ([[selectArray objectAtIndex:(indexPath.row - 1)] integerValue] == 0) {// 检测被点击项答案的状态 0未选择 1已选择
                for (int i = 1; i <= selectArray.count; i++) {
                    if ([[selectArray objectAtIndex:(i-1)] integerValue] == 1) {
                        UITableViewCell *cellFor = (UITableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                        UIImageView *imageFor = (UIImageView *)[cellFor.contentView viewWithTag:101];
                        [imageFor setImage:[UIImage imageNamed:@"icon_unChecked"]];
                        NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:selectArray];
                        [mArray replaceObjectAtIndex:(i-1) withObject:@"0"];
                        NSString *end = [mArray componentsJoinedByString:@"|"];
                        [[customer.cus_Answers objectAtIndex:indexPath.section] setQuestion_Answer:end];

                    }
                }
                
                [image setImage:[UIImage imageNamed:@"icon_Checked"]];
                NSArray  *selectArrayFor = [[[customer.cus_Answers objectAtIndex:indexPath.section] question_Answer] componentsSeparatedByString:@"|"];
                [self changeAnswerStateWithArray:selectArrayFor andRowNumber:(indexPath.row - 1) andSectionNumber:indexPath.section andNowState:@"1"];
            }else {
                [image setImage:[UIImage imageNamed:@"icon_unChecked"]];
                [self changeAnswerStateWithArray:selectArray andRowNumber:(indexPath.row - 1) andSectionNumber:indexPath.section andNowState:@"0"];
            }
        } else {
            UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:101];
            if ([[selectArray objectAtIndex:(indexPath.row - 1)] integerValue] == 0) {
                [image setImage:[UIImage imageNamed:@"icon_Checked"]];
                [self changeAnswerStateWithArray:selectArray andRowNumber:(indexPath.row - 1) andSectionNumber:indexPath.section andNowState:@"1"];
            }else {
                [image setImage:[UIImage imageNamed:@"icon_unChecked"]];
                [self changeAnswerStateWithArray:selectArray andRowNumber:(indexPath.row - 1) andSectionNumber:indexPath.section andNowState:@"0"];
            }
        }
    }
}

- (void)changeAnswerStateWithArray:(NSArray *)array andRowNumber:(NSInteger)row andSectionNumber:(NSInteger)section andNowState:(NSString *)state
{
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:array];
    [mArray replaceObjectAtIndex:row withObject:state];
    NSString *end = [mArray componentsJoinedByString:@"|"];
    [[customer.cus_Answers objectAtIndex:section] setQuestion_Answer:end];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:textView];
    textView_Selected = textView;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToTextView:textView];
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
            if (toBeString.length > 200) {
                textView.text = [toBeString substringToIndex:200];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 200) {
            textView.text = [toBeString substringToIndex:200];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char *ch=[text cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"*ch = %d", *ch);
    
    if (*ch == 0) return YES;
    //if (*ch == 32) return NO;
    
    if ([textView.text length] > 200)
        return NO;
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    UITableViewCell *cell;
    if (IOS6 || IOS8) {
        cell = (UITableViewCell *)textView.superview.superview;
    } else if (IOS7) {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    }
    NSIndexPath *index = [_tableView indexPathForCell:cell];

    NSLog(@"%ld   %ld", (long)index.section, (long)index.row);
    if (![textView.text isEqualToString:[[customer.cus_Answers objectAtIndex:index.section] question_Answer]] && [[customer.cus_Answers objectAtIndex:index.section] question_Type] == 0) {
        [[customer.cus_Answers objectAtIndex:index.section] setQuestion_Answer: [OverallMethods EscapingString:textView.text]];
        NSLog(@"customer answers is %@",[customer.cus_Answers[index.section] question_Answer]);
    }

}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark - 接口

- (void)requestUpdateDetailInfo:(CustomerDoc *)new_customer
{
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"AnswerList\":[%@]}", (long)new_customer.cus_ID,new_customer.cus_AnswerSend];

    _requestUpdateDetailInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/updateAnswer" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    /*
    _requestUpdateDetailInfoOperation = [[GPHTTPClient shareClient] requestUpdateProfessionInfoWithCustomer:new_customer success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            
        }failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}


@end


