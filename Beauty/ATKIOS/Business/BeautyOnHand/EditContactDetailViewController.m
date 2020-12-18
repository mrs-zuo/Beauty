//
//  EditContactDetailViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "EditContactDetailViewController.h"
#import "DEFINE.h"
#import "UILabel+InitLabel.h"
#import "ContactDoc.h"
#import "ScheduleDoc.h"
#import "GPHTTPClient.h"
#import "InitialSlidingViewController.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "ContactDetailViewController.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "GPBHTTPClient.h"

@interface EditContactDetailViewController ()
@property (nonatomic) UITextView *textView_selected;
@property (assign, nonatomic) CGFloat tableView_Height;

@property (assign, nonatomic) CGRect prevCaretRect;
@property (weak, nonatomic) AFHTTPRequestOperation *updateContactOperation;
@end

@implementation EditContactDetailViewController
@synthesize myTableview;
@synthesize textView_selected;
@synthesize tableView_Height;
@synthesize contactDoc;
@synthesize delegate;
@synthesize prevCaretRect;

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
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"编辑联系治"];
    [self.view addSubview:navigationView];
    
    myTableview.showsHorizontalScrollIndicator = NO;
    myTableview.showsVerticalScrollIndicator = NO;
    tableView_Height = myTableview.frame.size.height;
    myTableview.separatorColor = kTableView_LineColor;
    myTableview.backgroundColor = [UIColor clearColor];
    myTableview.backgroundView = nil;
    myTableview.autoresizesSubviews = UIViewAutoresizingNone;
    if (IOS6)  {
        myTableview.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - 64.0f - navigationView.frame.size.height - 5.0f);
    } else {
        myTableview.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - navigationView.frame.size.height - 5.0f);
         myTableview.separatorInset = UIEdgeInsetsZero;
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定"submitAction:@selector(updateContactInfo)];
    [footerView showInTableView:myTableview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *cellIndentify = @"timeCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = @"时间";
            cell.valueText.text = contactDoc.cont_Schedule.sch_ScheduleTime;
            cell.valueText.enabled = NO;
            cell.valueText.tag = 100;
            cell.valueText.textColor = [UIColor blackColor];
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        } else {
            static NSString *cellIndentify = @"stateCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = @"状态";
            cell.valueText.enabled = NO;
            cell.valueText.textColor = [UIColor blackColor];
            
            UISwitch *offSwitch = [[UISwitch alloc] init];
            if (contactDoc.cont_Schedule.sch_Completed == 0) {
                offSwitch.on = NO;
            }else {
                offSwitch.on = YES;
            }
            [offSwitch addTarget:self action:@selector(changeBrowseType:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = offSwitch;
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }
    }else {
        if (indexPath.row == 0) {
            static NSString *cellIndentify = @"contactRecordCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = @"联系记录";
            cell.valueText.enabled = NO;
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }else {
            static NSString *cellIndentify = @"contactContentCell";
            ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
            }
            cell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [cell setContentText:contactDoc.cont_Remark];
            [[cell contentEditText] setPlaceholder:@"输入联系记录"];
            [cell setDelegate:self];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return contactDoc.height_cont_Remark;
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

#pragma mark - Switch

- (void)changeBrowseType:(id)sender
{
    UISwitch *ctlSh = (UISwitch *)sender;
    if (ctlSh.on == true) {
        contactDoc.cont_Schedule.sch_Completed = 1;
    }else {
        contactDoc.cont_Schedule.sch_Completed = 0;
    }
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
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    
    contactDoc.cont_Remark = contentText.text;
    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([contentText.text length] > 300) return NO;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
    contactDoc.cont_Remark = contentText.text;
    contactDoc.height_cont_Remark = height;
    [myTableview beginUpdates];
    [myTableview endUpdates];
}

- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [myTableview convertRect:cursorRect fromView:textView];
    
    if (prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        prevCaretRect = newCursorRect;
        [myTableview scrollRectToVisible:newCursorRect animated:YES];
    }
}

#pragma mark - 接口

- (void)updateContactInfo
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"ContactID\":%ld,\"Status\":%ld,\"ScheduleID\":%ld,\"Remark\":\"%@\"}", (long)ACC_ACCOUNTID, (long)contactDoc.cont_ID, (long)contactDoc.cont_Schedule.sch_Completed, (long)contactDoc.cont_Schedule.sch_ID, contactDoc.cont_Remark];

    _updateContactOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/updateContact" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                if ([delegate respondsToSelector:@selector(editSuccessWithContactDoc:)]) {
                    [delegate editSuccessWithContactDoc:contactDoc];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    /*
    _updateContactOperation = [[GPHTTPClient shareClient] requestUpdateContactDetailInfoWith:contactDoc success:^(id xml) {
        
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if ([delegate respondsToSelector:@selector(editSuccessWithContactDoc:)]) {
                [delegate editSuccessWithContactDoc:contactDoc];
            }
        } failure:^{}];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        DLOG(@"Error:%@ address:%s", error.description, __FUNCTION__);
    } ];
   */
}



@end
