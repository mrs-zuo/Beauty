//
//  TemplateEditViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-19.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "TemplateEditViewController.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GDataXMLNode.h"
#import "TemplateDoc.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "GPBHTTPClient.h"

@interface TemplateEditViewController ()
@property (assign, nonatomic) AFHTTPRequestOperation *requestUpdateTemplateOperation;
@property (assign, nonatomic) AFHTTPRequestOperation *requestAddTemplateOperation;
@property (assign, nonatomic) AFHTTPRequestOperation *requestDeleteTemplateOperation;

@property (strong, nonatomic) UIPickerView *typePickerView;
@property (strong, nonatomic) UIToolbar *accessoryInputView;

@property (assign, nonatomic) CGRect prevCaretRect;

@property (strong, nonatomic) UITextView *textView_Selected;
@property (strong, nonatomic) UITextField *textField_Selected;

@end

@implementation TemplateEditViewController
@synthesize theTemplateDoc;
@synthesize typePickerView;
@synthesize accessoryInputView;
@synthesize isEditing;
@synthesize prevCaretRect;
@synthesize textField_Selected;
@synthesize textView_Selected;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.baseEditing = YES;
    
    NSString *titleString = @"";
    if (isEditing) {
        titleString = @"编辑模板信息";
        theTemplateDoc.tmp_UpdaterID = ACC_ACCOUNTID;
    }else {
        titleString = @"添加模板信息";
        theTemplateDoc = [[TemplateDoc alloc] init];
        theTemplateDoc.tmp_CreatorID = ACC_ACCOUNTID;
    }
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:titleString];
    [self.view addSubview:navigationView];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.autoresizingMask = UIViewAutoresizingNone;

    [_tableView setTableFooterView:[[UIView alloc] init]];
    [_tableView setAllowsSelection:NO];
    [_tableView setSeparatorColor:kTableView_LineColor];
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (navigationView.frame.size.height + 5.0f) - 64.0f -  5.0f);
         _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (navigationView.frame.size.height + 5.0f) - 64.0f - 5.0f);
    }
    
    if (isEditing) {
        FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:nil submitAction:@selector(updateOrAddTemplateAction) deleteImg:nil deleteAction:@selector(deleteTemplateAction)];
        [footerView showInTableView:_tableView];
    } else {
        FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:nil submitTitle:@"确定" submitAction:@selector(updateOrAddTemplateAction)];
        [footerView showInTableView:_tableView];
    }

}

- (void)initializeKeyboard
{
    if (typePickerView == nil) {
        typePickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [typePickerView setShowsSelectionIndicator:YES];
        [typePickerView setDelegate:self];
        [typePickerView setDataSource:self];
        typePickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    if (accessoryInputView == nil) {
        accessoryInputView  = [[UIToolbar alloc] init];
        accessoryInputView.barStyle = UIBarStyleBlackTranslucent;
        accessoryInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [accessoryInputView sizeToFit];
        CGRect frame1 = accessoryInputView.frame;
        frame1.size.height = 44.0f;
        accessoryInputView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [accessoryInputView setItems:array];
    }
}

- (void)done
{
    [self.textField_Selected resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *cellIndentify = @"TemplateSubjectCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        }
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.font = kFont_Light_16;
        
        UITextField *contentView = (UITextField *)[cell viewWithTag:101];
        contentView.textColor = kColor_Editable;
        contentView.font = kFont_Light_16;
        contentView.delegate = self;
        contentView.returnKeyType = UIReturnKeyDone;
        contentView.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentCenter;
        if (indexPath.row == 0) {
            [titleLabel setText:@"主题"];
            if(theTemplateDoc.Subject && ![theTemplateDoc.Subject isEqualToString:@""])
                [contentView setText:theTemplateDoc.Subject];
            else{
                contentView.text = @"";
                contentView.placeholder = @"请输入模板主题";
            }
            NSLog(@"subject is :%@",theTemplateDoc.Subject);
        } else if (indexPath.row == 1) {
            [titleLabel setText:@"消息类型"];
            [contentView setText:theTemplateDoc.TemplateType == 0 ? @"公用" : @"个人"];
            contentView.inputView = typePickerView;
        }
        return cell;
    } else {
        if (indexPath.row == 0) {
            static NSString *cellIndentify = @"Temp_ConentTitle_Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
                cell.backgroundColor = [UIColor whiteColor];
            }
            cell.tag = 102;
            cell.textLabel.text = @"内容";;
            cell.textLabel.textColor = kColor_DarkBlue;
            cell.textLabel.font = kFont_Light_16;
            return cell;
        } else {
            
            static NSString *cellIndentify = @"Temp_Conent_Cell";
            ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                cell.backgroundColor = [UIColor whiteColor];
            }
            cell.delegate = self;
            cell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [cell setContentText:theTemplateDoc.TemplateContent];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return theTemplateDoc.height_Tmp_TemplateContent;
    } else  {
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


#pragma mark - UIPickerViewDataSource && UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    NSString *valueStr =  (row == 0 ? @"公用" : @"个人");
    [label setText:valueStr];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:20.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UITableViewCell *theSecondCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UILabel *typeLabel = (UILabel *)[theSecondCell viewWithTag:101];
    [typeLabel setText:(row == 0 ? @"公用" : @"个人")];
    theTemplateDoc.TemplateType = row;

}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.textView_Selected = textView;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char * ch=[text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if ([textView.text length] > 49) return NO;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSIndexPath *indexPath ;
    if (IOS6 || IOS8) {
        UITableViewCell *cell = (UITableViewCell *)textView.superview.superview;
        indexPath = [_tableView indexPathForCell:cell];
    } else {
        UITableViewCell *cell = (UITableViewCell *)textView.superview.superview.superview;
        indexPath = [_tableView indexPathForCell:cell];
    }
    if (indexPath && indexPath.row == 0 && indexPath.section == 0) theTemplateDoc.Subject = textView.text;
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath ;
    if (IOS6 || IOS8) {
        UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
        indexPath = [_tableView indexPathForCell:cell];
    } else {
        UITableViewCell *cell = (UITableViewCell *)textField.superview.superview.superview;
        indexPath = [_tableView indexPathForCell:cell];
    }
    
    if (indexPath.row == 1) {  //  模板类型
        [self initializeKeyboard];
        textField.inputView = typePickerView;
        textField.inputAccessoryView = accessoryInputView;
        
        [typePickerView selectRow:theTemplateDoc.TemplateType inComponent:0 animated:NO];
    }
    textField.returnKeyType = UIReturnKeyDone;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textField_Selected = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath ;
    if (IOS6 || IOS8) {
        UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
        indexPath = [_tableView indexPathForCell:cell];
    } else {
        UITableViewCell *cell = (UITableViewCell *)textField.superview.superview.superview;
        indexPath = [_tableView indexPathForCell:cell];
    }
    if (indexPath && indexPath.row == 0 && indexPath.section == 0)
        theTemplateDoc.Subject = textField.text;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"textField : %@",textField.text);
    const char *ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    
    if ([textField.text length] >= 20) {
        return NO;
    }
    return YES;
}

#pragma mark -WordCheck

- (void)wordCountCheck:(NSNotification *)notiFi
{
    UITextView *textView = (UITextView *)notiFi.object;
    NSString *textContext = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *range = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:range.start offset:0];
        if (!position) {
            if (textView.text.length >= 300) {
                textView.text = [textContext substringToIndex:300];
            }
        }
    } else {
        if (textView.text.length >= 300) {
            textView.text = [textContext substringToIndex:300];
        }
    }
}
#pragma mark - ContentEditCellDelegate

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    self.textView_Selected = contentText;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordCountCheck:) name:UITextViewTextDidChangeNotification object:contentText];
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    theTemplateDoc.TemplateContent = contentText.text;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:contentText];
    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char *ch = [text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch != 0) {
        return YES;
    }else
        return YES;
    //if (*ch == 32)   return NO;

    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *range = [contentText markedTextRange];
        UITextPosition *position = [contentText positionFromPosition:range.start offset:0];
        if (!position) {
            if (contentText.text.length >= 300) {
                return NO;
            }
        }
    } else {
        if (contentText.text.length >= 300) {
            return NO;
        }
    }
    if ([text isEqualToString:@""]) {
        return YES;
    }
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
    
    theTemplateDoc.TemplateContent = contentText.text;
    theTemplateDoc.height_Tmp_TemplateContent = height;
    
    [_tableView beginUpdates];
    [_tableView endUpdates];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark - Custome Action

- (void)updateOrAddTemplateAction
{
    [self.view endEditing:YES];
    if ([theTemplateDoc.Subject length] == 0) {
        [SVProgressHUD showErrorWithStatus2:@"消息主题不能为空！" touchEventHandle:^{}];
        return;
    }
    if ([theTemplateDoc.TemplateContent length] == 0) {
        [SVProgressHUD showErrorWithStatus2:@"消息内容不能为空！" touchEventHandle:^{}];
        return;
    }
    
    if (isEditing) {
        [self requestUpdateTemplate:theTemplateDoc];
    } else {
        [self requestAddTemplate:theTemplateDoc];
    }
}

- (void)deleteTemplateAction
{
    [self requestDeleteTemplate:theTemplateDoc.TemplateID];
}

#pragma mark - 接口

- (void)requestUpdateTemplate:(TemplateDoc *)newTemplateDoc
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSString *par = [NSString stringWithFormat:@"{\"TemplateID\":\"%ld\",\"Subject\":\"%@\",\"TemplateContent\":\"%@\",\"TemplateType\":%ld}", (long)newTemplateDoc.TemplateID, [OverallMethods EscapingString:newTemplateDoc.Subject], [OverallMethods EscapingString:newTemplateDoc.TemplateContent], (long)newTemplateDoc.TemplateType];

    _requestUpdateTemplateOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/template/updateTemplate" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:2.0 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];

    } failure:^(NSError *error) {
        
    }];
    /*
    _requestUpdateTemplateOperation =  [[GPHTTPClient shareClient] requestUpdateTemplateWithTemplate:newTemplateDoc Success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {} failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}

- (void)requestAddTemplate:(TemplateDoc *)newTemplateDoc
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSString *par = [NSString stringWithFormat:@"{\"Subject\":\"%@\",\"TemplateContent\":\"%@\",\"TemplateType\":%ld}", [OverallMethods EscapingString:newTemplateDoc.Subject], [OverallMethods EscapingString:newTemplateDoc.TemplateContent], (long)newTemplateDoc.TemplateType];

    _requestAddTemplateOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/template/addTemplate" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:2.0 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _requestAddTemplateOperation =  [[GPHTTPClient shareClient] requestAddTemplateWithTemplate:newTemplateDoc Success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {} failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
    
}

- (void)requestDeleteTemplate:(NSInteger)templateId
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSString *par = [NSString stringWithFormat:@"{\"TemplateID\":%ld}", (long)templateId];

    _requestUpdateTemplateOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/template/deleteTemplate" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:2.0 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _requestUpdateTemplateOperation =  [[GPHTTPClient shareClient] requestDeleteTemplateWithTemplateID:templateId Success:^(id xml) {
        [SVProgressHUD dismiss];
          [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {} failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}
@end
