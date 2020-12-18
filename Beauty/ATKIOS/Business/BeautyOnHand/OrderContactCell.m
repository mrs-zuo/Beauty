//
//  OrderContactCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-12.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "OrderContactCell.h"
#import "OrderEditViewController.h"
#import "ContactDoc.h"

#import "DEFINE.h"

#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"
#import "UITextField+InitTextField.h"

#import "NSDate+Convert.h"

@interface OrderContactCell ()
@property (nonatomic) ContactDoc *theContactDoc;

@property (nonatomic) UIDatePicker *datePicker;
@property (nonatomic) UIToolbar *inputAccessoryView;
@end

@implementation OrderContactCell
@synthesize titleLabel, dateText, deleteBtn;
@synthesize delegate;
@synthesize theContactDoc;
@synthesize datePicker, inputAccessoryView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, kTableView_HeightOfRow/2 - 20.0f/2, 20.0f, 20.0f) title:@"88"];
        [titleLabel setTextColor:kColor_DarkBlue];
        [titleLabel setFont:kFont_Medium_16];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:titleLabel];
        
        dateText = [UITextField initNormalTextViewWithFrame:CGRectMake(148.0f, kTableView_HeightOfRow/2 - 15.0f, 130.0f, 30.0f) text:@"2013-09-06 10:53" placeHolder:@""];
        dateText.textAlignment = NSTextAlignmentRight;
        dateText.delegate = self;
        [self.contentView addSubview:dateText];
        
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake( 278.0f, kTableView_HeightOfRow/2 - 15.0f, 30.0f, 30.0f);
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteBtn];
    }
    return self;
}

- (void)updateData:(ContactDoc *)contactDoc canEdited:(BOOL)edited
{
    if (!edited) {
        dateText.textColor = [UIColor blackColor];
        dateText.userInteractionEnabled = NO;
        deleteBtn.hidden = YES;
    } else {
        theContactDoc = contactDoc;
        
        dateText.textColor = kColor_Editable;
        dateText.userInteractionEnabled = YES;
        deleteBtn.hidden = NO;
        dateText.delegate = self;
    }
    dateText.text = contactDoc.cont_Schedule.sch_ScheduleTime;
}

- (void)deleteAction
{
    if ([delegate respondsToSelector:@selector(chickOperateRowButton:)]) {
        [delegate chickOperateRowButton:self];
    }
}

- (void)initPickerView
{
    
  
    if (datePicker == nil) {
        datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        datePicker.autoresizingMask = UIViewAutoresizingNone;
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
        [datePicker sizeThatFits:CGSizeZero];
    }
    
    if (inputAccessoryView == nil) {
        inputAccessoryView  = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [inputAccessoryView sizeToFit];
        CGRect frame1 = inputAccessoryView.frame;
        frame1.size.height = 44.0f;
        inputAccessoryView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
        [doneBtn setTintColor:kColor_White];
        
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [inputAccessoryView setItems:array];
    }
}

- (void)valueChanged
{
    dateText.text = [NSDate dateToString:[datePicker date]];
}

- (void)done
{
    dateText.text = [NSDate dateToString:[datePicker date]];
    [dateText resignFirstResponder];
    [_orderEditViewController dismissKeyBoard];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self initPickerView];
    textField.inputView = datePicker;
    textField.inputAccessoryView = inputAccessoryView;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (![theContactDoc.cont_Schedule.sch_ScheduleTime isEqualToString:textField.text]) {
        theContactDoc.cont_Schedule.sch_ScheduleTime = textField.text;
        
        if (theContactDoc.cont_Schedule.ctlFlag == 0) {
            theContactDoc.cont_Schedule.ctlFlag = 2;
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

@end
