//
//  OrderDateCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//


#import "OrderDateCell.h"
#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "UITextField+InitTextField.h"
#import "NSDate+Convert.h"
#import "ScheduleDoc.h"

@interface OrderDateCell ()
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;

@property (strong, nonatomic) ScheduleDoc *theScheduleDoc;
@property (assign, nonatomic) OrderDateCellMode theOrderDateCellMode;
@end

@implementation OrderDateCell
@synthesize titleLabel,timeText, deleteBtn;
@synthesize statusImgView1, statusImgView2, statusImgView3;
@synthesize datePicker, inputAccessoryView;
@synthesize theScheduleDoc, delegate;
@synthesize theOrderDateCellMode;
@synthesize orderEditViewController;


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
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [inputAccessoryView setItems:array];
    }
}

- (void)valueChanged
{
    timeText.text = [NSDate stringFromDateTime:[datePicker date]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(20.0f, kTableView_HeightOfRow/2 - 10.0f, 20.0f, 20.0f) title:@"1"];
        [titleLabel setTextColor:kColor_Editable];
        [titleLabel setFont:kFont_Light_16];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:titleLabel];
        
        statusImgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(50.0f, kTableView_HeightOfRow/2 - 10.0f, 20.0f, 20.0f)];
        statusImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(75.0f , kTableView_HeightOfRow/2 - 10.0f, 20.0f, 20.0f)];
        statusImgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(100.0f, kTableView_HeightOfRow/2 - 10.0f, 20.0f, 20.0f)];
        statusImgView1.image = [UIImage imageNamed:@"order_FinishStatus"];
        statusImgView2.image = [UIImage imageNamed:@"order_RemarkStatus"];
        statusImgView3.image = [UIImage imageNamed:@"order_PictureStatus"];
        [self.contentView addSubview:statusImgView1];
        [self.contentView addSubview:statusImgView2];
        [self.contentView addSubview:statusImgView3];
        
        timeText = [UITextField initNormalTextViewWithFrame:CGRectMake(135.0f, kTableView_HeightOfRow/2 - 15.0f, 150.0f, 30.0f) text:@"2013-09-06 10:53" placeHolder:@""];
        timeText.font = kFont_Light_16;
        timeText.textAlignment = NSTextAlignmentRight;
        timeText.delegate = self;
        [self.contentView addSubview:timeText];
            
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake( 280.0f, kTableView_HeightOfRow/2 - 15.0f, 30.0f, 30.0f);
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteBtn];
    }
    return self;
}

- (void)updateData:(ScheduleDoc *)scheduleDoc mode:(OrderDateCellMode)orderDateCellMode
{
    theScheduleDoc = scheduleDoc;
    theOrderDateCellMode = orderDateCellMode;
    if (orderDateCellMode == OrderDateCellModeDisplayCourse) {
        statusImgView1.hidden = scheduleDoc.sch_Completed > 0 ? NO : YES;
        statusImgView2.hidden = scheduleDoc.sch_RemarkCnt > 0 ? NO : YES;
        statusImgView3.hidden = scheduleDoc.sch_ImageCnt  > 0 ? NO : YES;
        deleteBtn.hidden = YES;
        timeText.enabled = NO;
        timeText.textColor = [UIColor blackColor];
    } else if (orderDateCellMode == OrderDateCellModeDisplayContact){
        statusImgView1.hidden = YES;
        statusImgView2.hidden = YES;
        statusImgView3.hidden = YES;
        deleteBtn.hidden = YES;
        timeText.enabled = NO;
        timeText.textColor = [UIColor blackColor];
    } else if (orderDateCellMode == OrderDateCellModeEdit) {
        statusImgView1.hidden = YES;
        statusImgView2.hidden = YES;
        statusImgView3.hidden = YES;
        deleteBtn.hidden = NO;
        timeText.frame  = CGRectMake(135.0f, kTableView_HeightOfRow/2 - 15.0f, 140.0f, 30.0f);
        deleteBtn.frame = CGRectMake( 275.0f, kTableView_HeightOfRow/2 - 15.0f, 30.0f, 30.0f);
        timeText.textColor = kColor_Editable;
        timeText.delegate = self;
    }
    timeText.text = scheduleDoc.sch_ScheduleTime;
}

- (void)deleteAction
{
    if ([delegate respondsToSelector:@selector(chickDeleteRowButton:)]) {
        [delegate chickDeleteRowButton:self];
    }
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
    
    NSLog(@"textField:%@", textField);
    NSLog(@"%@", theScheduleDoc.sch_ScheduleTime);
    if (![theScheduleDoc.sch_ScheduleTime isEqualToString:textField.text]) {
        theScheduleDoc.sch_ScheduleTime = textField.text;
        
        if (theScheduleDoc.ctlFlag == 0) {
            theScheduleDoc.ctlFlag = 2;
        }
        
        NSLog(@"222:%ld", (long)theScheduleDoc.sch_ID);
        NSLog(@"222:%@", theScheduleDoc.sch_ScheduleTime);
        NSLog(@"222:%p", theScheduleDoc);
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

@end
