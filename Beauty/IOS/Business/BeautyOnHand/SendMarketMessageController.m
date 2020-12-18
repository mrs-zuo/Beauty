//
//  SendMarketMessageController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-24.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "SendMarketMessageController.h"
#import "NSDate+Convert.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "TemplateDoc.h"
#import "MessageDoc.h"
#import "DEFINE.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"

#import "UserDoc.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "UIButton+InitButton.h"
#import "GPBHTTPClient.h"

#define ACC_ACCOUNTID [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_USERID"] integerValue]

@interface SendMarketMessageController ()
@property (nonatomic) NSString *currentDateStr;
@property (nonatomic) NSArray *receiverArray;

@property (nonatomic, strong) UITextView *selected_TextView;
@property (nonatomic) MessageDoc *theMessage;
@property (nonatomic) CGRect prevCaretRect;
@property (nonatomic, assign) CGFloat initialTVHeight;
@end

@implementation SendMarketMessageController
@synthesize currentDateStr;
@synthesize receiverArray;
@synthesize theMessage;
@synthesize prevCaretRect;
@synthesize selected_TextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:selected_TextView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentDateStr = [NSDate dateToString:[NSDate date]];
    
    theMessage = [[MessageDoc alloc] init];
    theMessage.mesg_SendTime = currentDateStr;

    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"发送营销信息"];
    [self.view addSubview:navigationView];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake(-5.0f, 35.0f, 330.0f, kSCREN_BOUNDS.size.height - 20.0f - 44.0f);
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"addFavourite"] submitTitle:@"确定" submitAction:@selector(submitAction)];
    [footerView showInTableView:_tableView];
    _initialTVHeight = _tableView.frame.size.height;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:selected_TextView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Method

- (void)submitAction
{
    NSLog(@"submitAction");
    [self.view endEditing:YES];
    [theMessage setMesg_FromUserID:ACC_ACCOUNTID];
    [theMessage setMesg_MessageType:1];
    [theMessage setMesg_GroupFlag:1];
    [self requestAddMsgByOneToOne:theMessage];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goTemplateViewFromSendMessageView"]) {
        TemplateViewController *templateViewController = segue.destinationViewController;
        templateViewController.templateType = TemplateTypePublic;
        templateViewController.delegate = self;
    }
}

#pragma mark - TemplateViewControllerDelegate

- (void)returnTemplate:(TemplateDoc *)theTemplateDoc
{
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:1 inSection:2];
    ContentEditCell *cell = (ContentEditCell *)[_tableView cellForRowAtIndexPath:indexpath];
      theMessage.mesg_MessageContent = theTemplateDoc.TemplateContent;
    [cell setContentText:theTemplateDoc.TemplateContent];
    [cell textViewDidChange:cell.contentEditText];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            NSString *cellIndentity = @"NormalEditCell_Date";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentity];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentity];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.titleLabel.text = @"时间";
            cell.valueText.text = currentDateStr;
            [cell setAccessoryText:@""];
            [cell.valueText setTextColor:[UIColor blackColor]];
            [cell.valueText setUserInteractionEnabled:NO];
             [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;
        case 1:
        {
            NSString *cellIndentity = @"NormalEditCell_Receiver";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentity];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentity];
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow - 12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [cell.contentView addSubview:arrowsImage];
            }
            [cell.valueText setTextColor:kColor_Editable];
            [cell.valueText setUserInteractionEnabled:NO];
            [cell setAccessoryText:@" "];
            
            CGRect valueFrame = cell.valueText.frame;
            
            valueFrame.origin.x = 90.0f;
            
            cell.valueText.frame = valueFrame;
            
            NSMutableString *strNames = [NSMutableString string];
            for (int i=0; i<[receiverArray count]&& i<2; i++ ) {
                UserDoc *user = [receiverArray objectAtIndex:i];
                if (i == [receiverArray count] - 1 || i == 1) {
                    [strNames appendString:user.user_Name];
                } else {
                    [strNames appendFormat:@"%@,", user.user_Name];
                }
            }
            if ([strNames length] > 0) {
                [strNames appendFormat:@"等%lu人", (unsigned long)[receiverArray count]];
            }
            cell.titleLabel.text = @"接收人";
            cell.valueText.text = strNames;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {
                NSString *cellIndentity = @"NormalEditCell_content";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentity];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentity];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                cell.titleLabel.text = @"内容";
                cell.valueText.text = @" ";
                cell.valueText.enabled = NO;
               
                UIButton *templateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [templateBtn setBackgroundImage:[UIImage imageNamed:@"chat_MsgTemplate.png"] forState:UIControlStateNormal];
                [templateBtn setFrame:CGRectMake(275, 4, 30.0f, 30.0f)];
                [templateBtn addTarget:self action:@selector(goToTemplateView) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:templateBtn];
                
                return cell;

            } else {
               NSString *cellIdentity = @"ContentCell";
                ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
                if (cell == nil) {
                    cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
                }
                cell.delegate = self;
                cell.contentEditText.returnKeyType = UIReturnKeyDefault;
                cell.contentEditText.placeholder = @"请输入内容";
                cell.contentEditText.font = kFont_Light_16;
                [cell setContentText:theMessage.mesg_MessageContent];
                 [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
        }
            break;
        default:
            return nil;
            break;
    }
}

- (void)goToTemplateView
{
    [self performSegueWithIdentifier:@"goTemplateViewFromSendMessageView" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 1) {
        return MAX(kTableView_HeightOfRow, theMessage.mesg_MarHeight);
    } else {
        return kTableView_HeightOfRow;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
        
        [selectCustomer setSelectModel:1 userType:0 customerRange:CUSTOMEROFMINE defaultSelectedUsers:receiverArray];
        [selectCustomer setDelegate:self];
        [selectCustomer setNavigationTitle:@"选择顾客"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navigationController animated:YES completion:^{}];
    }
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
//    self.textView_Selected = contentText;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
//    [self scrollToCursorForTextView:textView];
    [self scrollToTextView:textView];
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [cell textViewDidChange:textView];
//    [_tableView beginUpdates];
//    [_tableView endUpdates];
}
- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
//    [self scrollToCursorForTextView:contentText];

    NSLog(@"contentText font is %@",contentText.font);
    theMessage.mesg_MarHeight = height;
    theMessage.mesg_MessageContent = contentText.text;
    
//    [_tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [_tableView beginUpdates];
    [_tableView endUpdates];
    

 
}

#pragma mark 输入字数统计
-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    
    UITableViewCell *cell = nil;
    if (IOS6 || IOS8) {
        cell = (UITableViewCell *)textView.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    }
    
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
    theMessage.mesg_MessageContent = textView.text;
}




- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
    _tableView.frame = tvFrame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _tableView.frame = tvFrame;

}

- (void)scrollToTextView:(UITextView *)textView
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview;
    }
    NSIndexPath* path = [_tableView indexPathForCell:cell];
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
#pragma mark - SelectCustomersViewControllerDelegate

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    receiverArray = userArray;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -

//发送message时的接口，单发和群发已经合并
- (void)requestAddMsgByOneToOne:(MessageDoc *)messageDoc
{

    if ([receiverArray count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择接收人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if ([theMessage.mesg_MessageContent length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入营销内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    NSMutableString *toUserIdsStr = [NSMutableString string];
    for (UserDoc *userDoc in receiverArray) {
        [toUserIdsStr appendFormat:@"%ld,", (long)userDoc.user_Id];
    }
    
     _tableView.tableFooterView.userInteractionEnabled = NO;
    
    [messageDoc setMesg_ToUserIDString:toUserIdsStr];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"FromUserID\":%ld,\"ToUserIDs\":\"%@\",\"MessageContent\":\"%@\",\"MessageType\":%ld,\"GroupFlag\":%ld}", (long)messageDoc.mesg_FromUserID, messageDoc.mesg_ToUserIDString, [OverallMethods EscapingString:messageDoc.mesg_MessageContent], (long)messageDoc.mesg_MessageType, (long)messageDoc.mesg_GroupFlag];
    
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/addMessage" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        _tableView.tableFooterView.userInteractionEnabled = YES;
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"发送成功!" duration:kSvhudtimer   touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:@"发送失败!" touchEventHandle:^{}];
        }];
        
    } failure:^(NSError *error) {
        _tableView.tableFooterView.userInteractionEnabled = YES;
        
    }];

    
    
    
    /*
    
    [[GPHTTPClient shareClient] requestSendMessageByOneToOneWithMessage:messageDoc Success:^(id xml) {
        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml encoding:NSUTF8StringEncoding error:0];
        GDataXMLElement *items = [[document nodesForXPath:@"//Result" error:nil] objectAtIndex:0];
        NSInteger flag = [[[[items elementsForName:@"Flag"] objectAtIndex:0] stringValue] intValue];
        if (flag > 0) {
            [SVProgressHUD showSuccessWithStatus2:@"发送成功!" touchEventHandle:^{}];
            _tableView.tableFooterView.userInteractionEnabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus2:@"发送失败!" touchEventHandle:^{}];
            _tableView.tableFooterView.userInteractionEnabled = YES;
        }
    } failure:^(NSError *error) {
        _tableView.tableFooterView.userInteractionEnabled = YES;
    }];
     */
}

@end
