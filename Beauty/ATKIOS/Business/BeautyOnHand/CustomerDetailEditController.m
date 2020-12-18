//
//  CustomerDetailEditController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CustomerDetailEditController.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "CustomerDoc.h"
#import "DEFINE.h"
#import "GDataXMLNode.h"
#import <QuartzCore/QuartzCore.h>
#import "ContentEditCell.h"
#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "QuestionDoc.h"
#import "UITextField+InitTextField.h"
#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "noCopyTextField.h"
#import "GPBHTTPClient.h"

@interface CustomerDetailEditController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateDetailInfoOperation;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) UIToolbar *twobuttonAccessoryView;
@property (strong, nonatomic) NSArray *pickerData;

@property (strong, nonatomic) NSArray *genderArray;
@property (strong, nonatomic) NSArray *bloodTypeArray;
@property (strong, nonatomic) NSArray *marriageArray;

//--
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (assign, nonatomic) CGRect prevCaretRect;

- (NSUInteger)indexForBloodType:(NSString *)bloodType;
- (NSIndexPath *)indexPathForCellWithTextFiled:(UITextField *)textField;
@end

@implementation CustomerDetailEditController
@synthesize customer;
@synthesize datePicker, pickerView, inputAccessoryView;
@synthesize genderArray, bloodTypeArray, marriageArray, pickerData;
@synthesize twobuttonAccessoryView;

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
    
    if (_requestUpdateDetailInfoOperation && [_requestUpdateDetailInfoOperation isExecuting]) {
        [_requestUpdateDetailInfoOperation cancel];
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    
    genderArray = [NSArray arrayWithObjects:@"未填", @"女", @"男", nil];
    bloodTypeArray = [NSArray arrayWithObjects:@"未填", @"A型", @"B型", @"AB型", @"O型", @"其他", nil];
    marriageArray = [NSArray arrayWithObjects:@"未填", @"未婚", @"已婚", nil];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)initTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"编辑详细信息"];
    [self.view addSubview:navigationView];
    
    _tableView.allowsSelection = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView  = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f - 44.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f - 44.0f );
    }
    
    FooterView *footView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(requestUpdateDetailInfo)];
    footView.frame = CGRectMake(5.0f, _tableView.frame.origin.y + _tableView.frame.size.height, kSCREN_BOUNDS.size.width -10.0f, 44.0f );
    [self.view addSubview:footView];
//    [footView showInTableView:_tableView];
    
    _initialTVHeight = _tableView.frame.size.height;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initial Keyboard

- (void)initialKeyboard
{
    if(!datePicker) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        CGRect frame = self.inputView.frame;
        frame.size = [self.datePicker sizeThatFits:CGSizeZero];
        self.inputView.frame = frame;
        self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    if (!pickerView) {
        pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [pickerView setShowsSelectionIndicator:YES];
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        CGRect frame = self.inputView.frame;
        frame.size = [self.pickerView sizeThatFits:CGSizeZero];
        self.inputView.frame = frame;
        self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [inputAccessoryView sizeToFit];
        CGRect frame1 = inputAccessoryView.frame;
        frame1.size.height = 44.0f;
        inputAccessoryView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:kColor_White];
        [doneBtn setTintColor:kColor_White];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [inputAccessoryView setItems:array];
    }
    if (!twobuttonAccessoryView) {
        twobuttonAccessoryView = [[UIToolbar alloc] init];
        twobuttonAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        twobuttonAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [twobuttonAccessoryView sizeToFit];
        CGRect frame1 = twobuttonAccessoryView.frame;
        frame1.size.height = 44.0f;
        twobuttonAccessoryView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:kColor_White];
        UIBarButtonItem *clearBtn = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStyleDone target:self action:@selector(clear:)];
        [clearBtn setTintColor:kColor_White];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, clearBtn, doneBtn, nil];
        [twobuttonAccessoryView setItems:array];
  
    }
}

- (void)dateChanged:(id)sender
{
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([datePicker.date timeIntervalSinceReferenceDate] + 8*3600)];
    NSLog(@"%@", [datePicker.date.description substringToIndex:10]);
    NSIndexPath *indexPath = [self indexPathForCellWithTextFiled:self.textField_Selected];
    
    //add begin by zhangwei map bug GPB-498
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0) {
            [self.textField_Selected setText:[NSString stringWithFormat:@"%@", [newDate.description substringToIndex:10]]];
        }
    }
    //add end by zhangwei map bug GPB-498
}

- (void)done:(id)sender
{
    NSIndexPath *indexPath = [self indexPathForCellWithTextFiled:self.textField_Selected];
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0) {
//            [self dateChanged:nil];  不用选择日期了
        } else if ( indexPath.row == 3 || indexPath.row == 4){
            NSInteger row = [pickerView selectedRowInComponent:0];
            [self.textField_Selected setText:[pickerData objectAtIndex:row]];
        }
    }
    [self dismissKeyBoard];
}

- (void)clear:(id)sender
{
    NSIndexPath *indexPath = [self indexPathForCellWithTextFiled:self.textField_Selected];
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0) {
            [self dismissKeyBoard];
        }
    }
    customer.cus_BirthDay = @"";
    self.textField_Selected.text = @"";
//    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];


}
#pragma mark - Custom Method

- (NSIndexPath *)indexPathForCellWithTextFiled:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if ((IOS7)) {
        cell = (UITableViewCell *)[[[textField superview] superview] superview];
    } else if (IOS6 || IOS8) {
        cell = (UITableViewCell *)[[textField superview] superview];
    }
    return [_tableView indexPathForCell:cell];
}

- (NSUInteger)indexForBloodType:(NSString *)bloodType
{
    for (int i=0; i < [bloodTypeArray count]; i++) {
        NSString *theBlood = [bloodTypeArray objectAtIndex:i];
        if ([theBlood isEqualToString:theBlood]) {
            return i;
        }
    }
    return [bloodTypeArray count];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }  else {
        return 2;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            NSString *cellIdentifier = @"SexCell";
//            __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            cell.backgroundColor = [UIColor whiteColor];
//            UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
//            [titleLable setFrame:CGRectMake(10.0f, 4.0f, 100.0f, 30.0f)];
//            noCopyTextField *valueText = (noCopyTextField *)[cell viewWithTag:101];
//            [titleLable setFont:kFont_Light_16];
//            [titleLable setTextColor:kColor_DarkBlue];
//            [valueText setFont:kFont_Light_16];
//            [valueText setTextColor:kColor_Editable];
//            [valueText setTextAlignment:NSTextAlignmentRight];
//            if ((IOS7 || IOS8)) {
//                [valueText setTintColor:[UIColor clearColor]];
//            }
//            [valueText setDelegate:self];
//            
//            [titleLable setText:@"性别"];
//            switch (customer.cus_Gender) {
//                case -1:
//                    [valueText setText:[NSString stringWithFormat:@"未填"]];
//                    break;
//                case 0:
//                    [valueText setText:[NSString stringWithFormat:@"女"]];
//                    break;
//                case 1:
//                    [valueText setText:[NSString stringWithFormat:@"男"]];
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//            return cell;
//        } else
            if (indexPath.row == 0) {
            NSString *cellIdentifier = @"BirthCell";
            __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
            [titleLable setFrame:CGRectMake(10.0f, 4.0f, 200.0f, 30.0f)];
                
            noCopyTextField *valueText = (noCopyTextField *)[cell viewWithTag:101];
            [titleLable setFont:kFont_Light_16];
            [titleLable setTextColor:kColor_DarkBlue];
            [valueText setFont:kFont_Light_16];
            [valueText setTextColor:kColor_Editable];
            [valueText setTextAlignment:NSTextAlignmentRight];
//            if ((IOS7 || IOS8)) {
//                [valueText setTintColor:[UIColor clearColor]];
//            }
            [valueText setDelegate:self];
            [titleLable setText:@"出生日期(年-月-日)"];
            if (customer.cus_BirthDay != nil && ![customer.cus_BirthDay isEqual: @""]) {
                [valueText setText:customer.cus_BirthDay];
            } else {
                [valueText setPlaceholder:@"请输入出生日期"];
            }
            return cell;
        } else if (indexPath.row == 1) {
            NSString *cellIdentifier = @"HeightCell";
            __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
            [titleLable setFrame:CGRectMake(10.0f, 4.0f, 100.0f, 30.0f)];
            noCopyTextField *valueText = (noCopyTextField *)[cell viewWithTag:101];
            [titleLable setFont:kFont_Light_16];
            [titleLable setTextColor:kColor_DarkBlue];
            [valueText setFont:kFont_Light_16];
            [valueText setTextColor:kColor_Editable];
            [valueText setTextAlignment:NSTextAlignmentRight];
//            if ((IOS7 || IOS8)) {
//                [valueText setTintColor:[UIColor clearColor]];
//            }
            [valueText setDelegate:self];
            
            [titleLable setText:@"身高（厘米）"];
            if (customer.cus_Height != 0) {
                [valueText setText:[NSString stringWithFormat:@"%.1f",customer.cus_Height]];
            } else {
                [valueText setPlaceholder:@"请输入身高"];
            }
            [valueText setReturnKeyType:UIReturnKeyDone];
            
            return cell;
        } else if (indexPath.row == 2) {
            NSString *cellIdentifier = @"WeightCell";
            __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
            [titleLable setFrame:CGRectMake(10.0f, 4.0f, 100.0f, 30.0f)];
            noCopyTextField *valueText = (noCopyTextField *)[cell viewWithTag:101];
            [titleLable setFont:kFont_Light_16];
            [titleLable setTextColor:kColor_DarkBlue];
            [valueText setFont:kFont_Light_16];
            [valueText setTextColor:kColor_Editable];
            [valueText setTextAlignment:NSTextAlignmentRight];
//            if ((IOS7 || IOS8)) {
//                [valueText setTintColor:[UIColor clearColor]];
//            }
            [valueText setDelegate:self];
            
            [titleLable setText:@"体重（公斤）"];
            if (customer.cus_Weight != 0) {
                [valueText setText:[NSString stringWithFormat:@"%.1f",customer.cus_Weight]];
            } else {
                [valueText setPlaceholder:@"请输入体重"];
            }
            [valueText setReturnKeyType:UIReturnKeyDone];
            
            return cell;
        } else if (indexPath.row == 3) {
            NSString *cellIdentifier = @"BloodTypeCell";
            __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
            [titleLable setFrame:CGRectMake(10.0f, 4.0f, 100.0f, 30.0f)];
            noCopyTextField *valueText = (noCopyTextField *)[cell viewWithTag:101];
            [titleLable setFont:kFont_Light_16];
            [titleLable setTextColor:kColor_DarkBlue];
            [valueText setFont:kFont_Light_16];
            [valueText setTextColor:kColor_Editable];
            [valueText setTextAlignment:NSTextAlignmentRight];
            if ((IOS7 || IOS8)) {
                [valueText setTintColor:[UIColor clearColor]];
            }
            [valueText setDelegate:self];
            
            [titleLable setText:@"血型"];
            if (![customer.cus_BloodType  isEqual: @""] && customer.cus_BloodType != nil) {
                [valueText setText:customer.cus_BloodType];
            } else {
                [valueText setPlaceholder:@"请输入血型"];
            }
            return cell;
        } else if (indexPath.row == 4) {
            NSString *cellIdentifier = @"MarriageCell";
            __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
            [titleLable setFrame:CGRectMake(10.0f, 4.0f, 100.0f, 30.0f)];
            noCopyTextField *valueText = (noCopyTextField *)[cell viewWithTag:101];
            [titleLable setFont:kFont_Light_16];
            [titleLable setTextColor:kColor_DarkBlue];
            [valueText setFont:kFont_Light_16];
            [valueText setTextColor:kColor_Editable];
            [valueText setTextAlignment:NSTextAlignmentRight];
            if ((IOS7 || IOS8)) {
                [valueText setTintColor:[UIColor clearColor]];
            }
            [valueText setDelegate:self];
            
            [titleLable setText:@"婚姻状况"];
            switch (customer.cus_Marriage) {
                case -1:
                    [valueText setText:[NSString stringWithFormat:@"未填"]];
                    break;
                case 0:
                    [valueText setText:[NSString stringWithFormat:@"未婚"]];
                    break;
                case 1:
                    [valueText setText:[NSString stringWithFormat:@"已婚"]];
                    break;
                    
                default:
                    break;
            }
            return cell;
        } else if (indexPath.row == 5) {
            NSString *cellIdentifier = @"WorkCell";
            __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
            [titleLable setFrame:CGRectMake(10.0f, 4.0f, 100.0f, 30.0f)];
            UITextField *valueText = (UITextField *)[cell viewWithTag:101];
            [titleLable setFont:kFont_Light_16];
            [titleLable setTextColor:kColor_DarkBlue];
            [valueText setFont:kFont_Light_16];
            [valueText setTextColor:kColor_Editable];
            [valueText setTextAlignment:NSTextAlignmentRight];
            [valueText setDelegate:self];
            
            [titleLable setText:@"职业"];
            if (![customer.cus_Profession  isEqual: @""] && customer.cus_Profession != nil) {
                [valueText setText:customer.cus_Profession];
            } else {
                [valueText setPlaceholder:@"请输入职业"];
            }
            return cell;
        }
    }  else {
        if (indexPath.row == 0) {
            static NSString *cellIdentifier = @"DetailTitleCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.backgroundColor = [UIColor whiteColor];
            [cell setSelected:NO];
            UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
            [titleLable setFont:kFont_Light_16];
            [titleLable setTextColor:kColor_DarkBlue];
            [titleLable setText:@"备注"];
            return cell;
        } else {
            static NSString *cellIndentify = @"Remind_ContentCell";
            ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [cell setContentText:customer.cus_Remark];
            [cell setDelegate:self];
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return kTableView_HeightOfRow;
    } else {
        if (indexPath.row == 0) {
            return kTableView_HeightOfRow;
        }else {
            return customer.cell_Remark_Height;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

#pragma mark - UIPickerViewDataSource && UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerData count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 280;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kTableView_HeightOfRow;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *valueLabel = [UILabel initNormalLabelWithFrame:view.bounds title:@""];
    [valueLabel setTextAlignment:NSTextAlignmentCenter];
    [valueLabel setFont:kFont_Medium_18];
    [valueLabel setText:[pickerData objectAtIndex:row]];
    return valueLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.textField_Selected setText:[pickerData objectAtIndex:row]];
    if([[pickerData objectAtIndex:1]  isEqual: @"A型"])
        customer.cus_BloodType = self.textField_Selected.text;
    if([[pickerData objectAtIndex:1]  isEqual: @"女"]){
        if ([self.textField_Selected.text isEqualToString:@"女"]) {
            [customer setCus_Gender:0];
        } else if ([self.textField_Selected.text isEqualToString:@"男"]){
            [customer setCus_Gender:1];
        } else {
            [customer setCus_Gender:-1];
        }
    }
    if([[pickerData objectAtIndex:1]  isEqual: @"未婚"]){
        if ([self.textField_Selected.text isEqualToString:@"未婚"]) {
            [customer setCus_Marriage:0];
        } else if ([self.textField_Selected.text isEqualToString:@"已婚"]){
            [customer setCus_Marriage:1];
        } else {
            [customer setCus_Marriage:-1];
        }
    }
}

#pragma mark - Keyboard Notification

-(void)keyboardDidShown:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f + 44.0f;
    _tableView.frame = tvFrame;
    [UIView commitAnimations];
    
    if (self.textView_Selected) {
        [self scrollToTextView:self.textView_Selected];
    }
}

-(void)keyboardWillHidden:(NSNotification*)notification
{
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _tableView.frame = tvFrame;
}

- (void)scrollToTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    if(path && path.row == 0)
        return;
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView:(UITextView*)textView
{
    //引起屏幕闪烁
//    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
//    CGRect newCursorRect = [_tableView convertRect:cursorRect fromView:textView];
//    
//    if (_prevCaretRect.size.height != newCursorRect.size.height) {
//        newCursorRect.size.height += 15;
//        _prevCaretRect = newCursorRect;
//        [self.tableView scrollRectToVisible:newCursorRect animated:YES];
//    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(300.0f, 200.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    if (textViewSize.width < 300) {
        textViewSize.width = 300;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

- (void)dismissKeyBoard
{
    [self.textField_Selected resignFirstResponder];
    [self.textView_Selected  resignFirstResponder];
    
    if (_initialTVHeight != 0) {
        CGRect tableFrame = _tableView.frame;
        tableFrame.size.height =  _initialTVHeight;
        _tableView.frame = tableFrame;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.textField_Selected = textField;
    //[self scrollToTextField:textField];
    
    [self initialKeyboard];
    NSIndexPath *indexPath = [self indexPathForCellWithTextFiled:textField];
    switch (indexPath.row) {
//        case 0:
//        {
//            textField.inputAccessoryView = inputAccessoryView;
//            textField.inputView = pickerView;
//            
//            [self setPickerData:genderArray];
//            [pickerView reloadAllComponents];
//            [pickerView selectRow:customer.cus_Gender + 1 inComponent:0 animated:YES];
//        } break;
        case 0:
        {
//            textField.inputAccessoryView = twobuttonAccessoryView;
//            textField.inputView = datePicker;
//            NSDate *theDate = [NSDate stringToDate:textField.text dateFormat:@"yyyy-MM-dd"];
//            if (theDate != nil && ![theDate  isEqual: @""]) {
//                [datePicker setDate:theDate];
//            }
            textField.inputAccessoryView = inputAccessoryView;
            textField.keyboardType = UIKeyboardTypeDefault;
        } break;
        case 1:
        {
            textField.inputAccessoryView = inputAccessoryView;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        } break;
        case 2:
        {
            textField.inputAccessoryView = inputAccessoryView;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        } break;
        case 3:
        {
            textField.inputAccessoryView = inputAccessoryView;
            textField.inputView = pickerView;
            
            [self setPickerData:bloodTypeArray];
            [pickerView reloadAllComponents];
            NSInteger bloodType = [self indexForBloodType:customer.cus_BloodType];
            [pickerView selectRow:bloodType inComponent:0 animated:YES];
        } break;
        case 4:
        {
            textField.inputAccessoryView = inputAccessoryView;
            textField.inputView = pickerView;
            [self setPickerData:marriageArray];
            [pickerView reloadAllComponents];
            [pickerView selectRow:customer.cus_Marriage + 1 inComponent:0 animated:YES];
        } break;
        case 5:
        {
            textField.inputAccessoryView = inputAccessoryView;
            [textField setReturnKeyType:UIReturnKeyDone];
            textField.keyboardType = UIKeyboardTypeDefault;
        } break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self scrollToTextField:self.textField_Selected];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:textField];
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            NSIndexPath *indexPath = [self indexPathForCellWithTextFiled:textField];
            if (indexPath.row == 5) { // 职业
                if (toBeString.length > 20) {
                    textField.text = [toBeString substringToIndex:20];
                }
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        NSIndexPath *indexPath = [self indexPathForCellWithTextFiled:textField];
        if (indexPath.row == 5) { // 职业
            if (toBeString.length > 20) {
                textField.text = [toBeString substringToIndex:20];
            }
        }
    }
    
    NSIndexPath *indexPath = [self indexPathForCellWithTextFiled:self.textField_Selected];
    if(indexPath && indexPath.section == 0){
        switch (indexPath.row) {
            case 3:
                customer.cus_Height = [self.textField_Selected.text integerValue];
                break;
            case  4:
                customer.cus_Weight = [self.textField_Selected.text integerValue];
                break;
            case 5:
                customer.cus_Profession = self.textField_Selected.text;
            default:
                break;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    //if (*ch == 32) return NO;
    
    NSIndexPath *indexPath = [self indexPathForCellWithTextFiled:textField];
    if (indexPath.row == 1 || indexPath.row == 2) { // 身高 体重
        NSRange decRange = [textField.text rangeOfString:@"."];
        
        if (*ch == 46 && decRange.location != NSNotFound) {
            return NO;
        }
        
        if ((textField.text.length - decRange.location > 1) && (range.location > decRange.location)) {
            return NO;
        }
        
        if ([textField.text length] > 4) {
            return NO;
        }
    }
//    if (indexPath.row == 6) { // 职业
//        if ([textField.text length] > 19) {
//            return NO;
//        }
//    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathForCellWithTextFiled:textField];
    if(indexPath == nil)
        return YES;
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0) {
//            [self dateChanged:nil]; 不用选择日期了
        } else if ( indexPath.row == 3 || indexPath.row == 4){
//            NSInteger row = [pickerView selectedRowInComponent:0];
//            if([[pickerData objectAtIndex:1]  isEqual: @"A型"])
//                [textField setText:[pickerData objectAtIndex:row]];
//            if([[pickerData objectAtIndex:1]  isEqual: @"女"])
//                [textField setText:[pickerData objectAtIndex:row]];
//            if([[pickerData objectAtIndex:1]  isEqual: @"未婚"])
//                [textField setText:[pickerData objectAtIndex:row]];
        } else {
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            UITextField *text = (UITextField *)[cell viewWithTag:101];
            NSLog(@"textField.text = %@", textField.text);
            text.text = textField.text;
        }
    }
    
    NSLog(@"textField.text = %@", textField.text);
    NSIndexPath *theIndexPath = [self indexPathForCellWithTextFiled:textField];
    switch (theIndexPath.row) {
//        case 0:
//            if ([textField.text isEqualToString:@"女"]) {
//                [customer setCus_Gender:0];
//            } else if ([textField.text isEqualToString:@"男"]){
//                [customer setCus_Gender:1];
//            } else {
//                [customer setCus_Gender:-1];
//            }
//            break;
        case 0:
            [customer setCus_BirthDay:textField.text];
            break;
        case 1:
            [customer setCus_Height:[textField.text length] == 0 ? 0 : [textField.text floatValue]];
            break;
        case 2:
            [customer setCus_Weight:[textField.text length] == 0 ? 0 : [textField.text floatValue]];
            break;
        case 3:
            [customer setCus_BloodType:textField.text];
            break;
        case 4:
            if ([textField.text isEqualToString:@"未婚"]) {
                [customer setCus_Marriage:0];
            } else if ([textField.text isEqualToString:@"已婚"]){
                [customer setCus_Marriage:1];
            } else {
                [customer setCus_Marriage:-1];
            }
            break;
        case 5:
            [customer setCus_Profession:textField.text];
            break;
        default:
            break;
    }

    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyBoard];
    return YES;
}

#pragma mark - ContentEditCellDelegate

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    self.textView_Selected = contentText;
    //[self scrollToTextView:contentText];
    
    [self initialKeyboard];

    contentText.inputAccessoryView = inputAccessoryView;

    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
//    [self scrollToCursorForTextView:textView];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:textView];
    CGRect rect = textView.frame;
    rect.size.width = 300;
    textView.frame = rect;
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
    //if ([contentText.text length] > 299) return NO;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
    
    customer.cell_Remark_Height = height;
    customer.cus_Remark = contentText.text;
    
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

//#pragma mark UIScrollViewDelegate
//
////只要滚动了就会触发
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
//{
//    
//}
//
////开始拖拽视图
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
//{
//    [self.textField_Selected resignFirstResponder];
//    [self.textView_Selected  resignFirstResponder];
//}

#pragma mark - 接口

- (void)requestUpdateDetailInfo
{
    [self.view endEditing:YES];
    if (![customer.cus_BirthDay length] == 0){ // 编辑了日期
        NSArray *dateArrs = [customer.cus_BirthDay componentsSeparatedByString:@"-"];
        if (dateArrs.count != 2  && dateArrs.count != 3) {
            [SVProgressHUD showErrorWithStatus2:@"日期格式不正确" duration:2.0 touchEventHandle:^{ // 日期格式不正确
            }]  ;
            return;
        }
        if (dateArrs.count == 2) { //没有输入年
            NSMutableString *temp = [[NSMutableString alloc]initWithString:customer.cus_BirthDay];
            [temp insertString:@"2104-" atIndex:0];
             customer.cus_BirthDay = temp;
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"] ];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSDate *birthDate = [formatter dateFromString:customer.cus_BirthDay];
        if (!birthDate) {
            [SVProgressHUD showErrorWithStatus2:@"日期格式不正确" duration:2.0 touchEventHandle:^{ // 日期格式不正确
            }]  ;
            if (dateArrs.count == 2) {
                [customer.cus_BirthDay substringFromIndex:5];
            }
            return;
        }
//        if ([[NSDate class]isDateWithString:customer.cus_BirthDay]) { // HHHH-MM-DD
//            
//        }else{
//            NSMutableString *temp = [[NSMutableString alloc]initWithString:customer.cus_BirthDay];
//            [temp insertString:@"2104-" atIndex:0];
//            customer.cus_BirthDay = temp;
//            NSLog(@"temp = %@",temp);
//            if (![[NSDate class]isDateWithString:customer.cus_BirthDay]) { // HHHH-MM-DD
//                [SVProgressHUD showErrorWithStatus2:@"日期格式不正确" duration:2.0 touchEventHandle:^{ // 日期格式不正确
//                }]  ;
//                return;
//            }
//        }
    }

    
//    if (![customer.cus_BirthDay length] == 0){ // 编辑了日期
//        if ([[NSDate class]isDateWithString:customer.cus_BirthDay]) { // HHHH-MM-DD
//            
//        }else{
//                NSMutableString *temp = [[NSMutableString alloc]initWithString:customer.cus_BirthDay];
//                [temp insertString:@"2104-" atIndex:0];
//                customer.cus_BirthDay = temp;
//                NSLog(@"temp = %@",temp);
//            if (![[NSDate class]isDateWithString:customer.cus_BirthDay]) { // HHHH-MM-DD
//                [SVProgressHUD showErrorWithStatus2:@"日期格式不正确" duration:2.0 touchEventHandle:^{ // 日期格式不正确
//                }]  ;
//                return;
//            }
//        }
//    }

  
    
    
    if ([customer.cus_BloodType length] == 0 || [customer.cus_BloodType isEqualToString:@"未填"]) customer.cus_BloodType = @"";
    if ([customer.cus_BirthDay length] == 0) customer.cus_BirthDay = @"";
    if ([customer.cus_Profession length] == 0) customer.cus_Profession = @"";
    if ([customer.cus_Remark length] == 0)  customer.cus_Remark = @"";
    if (customer.cus_Remark.length > 300) { // 只传前300字符。
        customer.cus_Remark = [customer.cus_Remark substringToIndex:300];
    }
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *ganderSre = @"";
    if (customer.cus_Gender == -1) {
        ganderSre = @"\"Gender\":\"\"";
    } else {
        ganderSre = [NSString stringWithFormat:@"\"Gender\":%ld", (long)customer.cus_Gender];
    }
    
    NSString *marriageSre = @"";
    if (customer.cus_Marriage == -1) {
        marriageSre = @"\"Marriage\":\"\"";
    } else {
        marriageSre = [NSString stringWithFormat:@"\"Marriage\":%ld", (long)customer.cus_Marriage];
    }
    
    NSString *heightStr = @"";
//    if(customer.cus_Height != 0)
        heightStr = [NSString stringWithFormat:@"\"Height\":%.1f",customer.cus_Height];
    NSString *weightStr = @"";
//    if(customer.cus_Weight != 0)
        weightStr = [NSString stringWithFormat:@"\"Weight\":%.1f",customer.cus_Weight];

    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,%@,%@,%@,%@,\"BloodType\":\"%@\",\"Birthday\":\"%@\",\"Profession\":\"%@\",\"Remark\":\"%@\"}", (long)customer.cus_ID, ganderSre, marriageSre, heightStr, weightStr, customer.cus_BloodType, customer.cus_BirthDay, customer.cus_Profession, customer.cus_Remark];

    
    _requestUpdateDetailInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/updateCustomerDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
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
    _requestUpdateDetailInfoOperation = [[GPHTTPClient shareClient] requestUpdateCustomerDetailInfoWithCustomer:customer success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {}failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}

@end
