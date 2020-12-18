////
////  OrderDateCell.m
////  GlamourPromise.Cosmetology.B
////
////  Created by GuanHui on 13-8-5.
////  Copyright (c) 2013年 ZhongHe. All rights reserved.
////
//
//
//#import "OrderDateCell.h"
//#import "NSDate+Convert.h"
//#import "UILabel+InitLabel.h"
//#import "UITextField+InitTextField.h"
//#import "OrderEditViewController.h"
//#import "NSDate+Convert.h"
//#import "ScheduleDoc.h"
//#import "DEFINE.h"
//
//@interface OrderDateCell ()
//@property (strong, nonatomic) UIDatePicker *datePicker;
//@property (strong, nonatomic) UIToolbar *inputAccessoryView;
//
//@property (strong, nonatomic) ScheduleDoc *theScheduleDoc;
//@property (assign, nonatomic) OrderDateCellMode theOrderDateCellMode;
//@end
//
//@implementation OrderDateCell
//@synthesize titleLabel, accNameLabel, timeText, deleteBtn;
//@synthesize statusImgView0, statusImgView1, statusImgView2, statusImgView3;
//@synthesize datePicker, inputAccessoryView;
//@synthesize theScheduleDoc, delegate;
//@synthesize theOrderDateCellMode;
//@synthesize orderEditViewController;
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        statusImgView0 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,  0.0f, 20.0f, 20.0f)];
//        statusImgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(32.0f, kTableView_HeightOfRow/2 - 14.0f/2, 14.0f, 14.0f)];
//        statusImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(47.0f ,kTableView_HeightOfRow/2 - 14.0f/2, 14.0f, 14.0f)];
//        statusImgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(62.0f, kTableView_HeightOfRow/2 - 14.0f/2, 14.0f, 14.0f)];
//        statusImgView0.image = [UIImage imageNamed:@"order_FinishStatus"];
//        statusImgView1.image = [UIImage imageNamed:@"order_RemarkStatus"];
//        statusImgView2.image = [UIImage imageNamed:@"order_PictureStatus"];
//        statusImgView3.image = [UIImage imageNamed:@"order_AppraiseStatus"];
//        [self.contentView addSubview:statusImgView0];
//        [self.contentView addSubview:statusImgView1];
//        [self.contentView addSubview:statusImgView2];
//        [self.contentView addSubview:statusImgView3];
//        
//        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, kTableView_HeightOfRow/2 - 20.0f/2, 20.0f, 20.0f) title:@"88"];
//        [titleLabel setTextColor:kColor_DarkBlue];
//        [titleLabel setFont:kFont_Medium_16];
//        [titleLabel setTextAlignment:NSTextAlignmentCenter];
//        [self.contentView addSubview:titleLabel];
//        
//        accNameLabel = [UILabel initNormalLabelWithFrame:CGRectMake(78.0f, 0.0f, 70.0f, kTableView_HeightOfRow) title:@"诸葛流云"];
//        accNameLabel.textAlignment = NSTextAlignmentRight;
//        [self.contentView addSubview:accNameLabel];
//        
//        timeText = [UITextField initNormalTextViewWithFrame:CGRectMake(148.0f, kTableView_HeightOfRow/2 - 15.0f, 130.0f, 30.0f) text:@"2013-09-06 10:53" placeHolder:@""];
//        timeText.textAlignment = NSTextAlignmentRight;
//        timeText.delegate = self;
//        [self.contentView addSubview:timeText];
//        
//        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        deleteBtn.frame = CGRectMake( 278.0f, kTableView_HeightOfRow/2 - 15.0f, 30.0f, 30.0f);
//        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
//        [deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:deleteBtn];
//    }
//    return self;
//}
//
//- (void)updateData:(ScheduleDoc *)scheduleDoc mode:(OrderDateCellMode)orderDateCellMode canEdited:(BOOL)edited
//{
//    theScheduleDoc = scheduleDoc;
//    theOrderDateCellMode = orderDateCellMode;
//    
//    if (!edited) {
//        if (orderDateCellMode == OrderDateCellModeDisplayCourse) {
//            statusImgView1.hidden = scheduleDoc.sch_Completed > 0 ? NO : YES;
//            statusImgView2.hidden = scheduleDoc.sch_RemarkCnt > 0 ? NO : YES;
//            statusImgView3.hidden = scheduleDoc.sch_ImageCnt  > 0 ? NO : YES;
//        } else {
//        
//        }
//    
//    } else {
//        if (orderDateCellMode == OrderDateCellModeDisplayCourse) {
//            
//        } else {
//            
//        }
//    }
//    
//    
//    
//    
//    if (orderDateCellMode == OrderDateCellModeDisplayCourse) {
//        statusImgView1.hidden = scheduleDoc.sch_Completed > 0 ? NO : YES;
//        statusImgView2.hidden = scheduleDoc.sch_RemarkCnt > 0 ? NO : YES;
//        statusImgView3.hidden = scheduleDoc.sch_ImageCnt  > 0 ? NO : YES;
//        deleteBtn.hidden = YES;
//        timeText.enabled = NO;
//        timeText.textColor = [UIColor blackColor];
//    } else if (orderDateCellMode == OrderDateCellModeDisplayContact){
//        statusImgView1.hidden = YES;
//        statusImgView2.hidden = YES;
//        statusImgView3.hidden = YES;
//        deleteBtn.hidden = YES;
//        timeText.enabled = NO;
//        timeText.textColor = [UIColor blackColor];
//    } else if (orderDateCellMode == OrderDateCellModeEdit) {
//        statusImgView1.hidden = YES;
//        statusImgView2.hidden = YES;
//        statusImgView3.hidden = YES;
//        deleteBtn.hidden = NO;
//        timeText.frame  = CGRectMake(135.0f, kTableView_HeightOfRow/2 - 15.0f, 140.0f, 30.0f);
//        deleteBtn.frame = CGRectMake( 275.0f, kTableView_HeightOfRow/2 - 15.0f, 30.0f, 30.0f);
//        timeText.textColor = kColor_Editable;
//        timeText.delegate = self;
//    }
//    timeText.text = scheduleDoc.sch_ScheduleTime;
//
//}
//
//
//
//- (void)initPickerView
//{
//    if (datePicker == nil) {
//        datePicker = [[UIDatePicker alloc] init];
//        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
//        datePicker.autoresizingMask = UIViewAutoresizingNone;
//        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
//        [datePicker addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
//        [datePicker sizeThatFits:CGSizeZero];
//    }
//    
//    if (inputAccessoryView == nil) {
//        inputAccessoryView  = [[UIToolbar alloc] init];
//        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
//        inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        [inputAccessoryView sizeToFit];
//        CGRect frame1 = inputAccessoryView.frame;
//        frame1.size.height = 44.0f;
//        inputAccessoryView.frame = frame1;
//        
//        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
//        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
//        [inputAccessoryView setItems:array];
//    }
//}
//
//- (void)valueChanged
//{
//    timeText.text = [NSDate dateToString:[datePicker date]];
//}
//
//- (void)done
//{
//    timeText.text = [NSDate dateToString:[datePicker date]];
//    [timeText resignFirstResponder];
//    [orderEditViewController dismissKeyBoard];
//}
//
//
//
////- (void)updateData:(ScheduleDoc *)scheduleDoc mode:(OrderDateCellMode)orderDateCellMode canEdited:(BOOL)edited
////{
////    theScheduleDoc = scheduleDoc;
////    theOrderDateCellMode = orderDateCellMode;
////    if (orderDateCellMode == OrderDateCellModeDisplayCourse) {
////        statusImgView1.hidden = scheduleDoc.sch_Completed > 0 ? NO : YES;
////        statusImgView2.hidden = scheduleDoc.sch_RemarkCnt > 0 ? NO : YES;
////        statusImgView3.hidden = scheduleDoc.sch_ImageCnt  > 0 ? NO : YES;
////        deleteBtn.hidden = YES;
////        timeText.enabled = NO;
////        timeText.textColor = [UIColor blackColor];
////    } else if (orderDateCellMode == OrderDateCellModeDisplayContact){
////        statusImgView1.hidden = YES;
////        statusImgView2.hidden = YES;
////        statusImgView3.hidden = YES;
////        deleteBtn.hidden = YES;
////        timeText.enabled = NO;
////        timeText.textColor = [UIColor blackColor];
////    } else if (orderDateCellMode == OrderDateCellModeEdit) {
////        statusImgView1.hidden = YES;
////        statusImgView2.hidden = YES;
////        statusImgView3.hidden = YES;
////        deleteBtn.hidden = NO;
////        timeText.frame  = CGRectMake(135.0f, kTableView_HeightOfRow/2 - 15.0f, 140.0f, 30.0f);
////        deleteBtn.frame = CGRectMake( 275.0f, kTableView_HeightOfRow/2 - 15.0f, 30.0f, 30.0f);
////        timeText.textColor = kColor_Editable;
////        timeText.delegate = self;
////    }
////    timeText.text = scheduleDoc.sch_ScheduleTime;
////}
//
//- (void)deleteAction
//{
//    if ([delegate respondsToSelector:@selector(chickDeleteRowButton:)]) {
//        [delegate chickDeleteRowButton:self];
//    }
//}
//
//#pragma mark - UITextFieldDelegate 
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    [self initPickerView];
//    textField.inputView = datePicker;
//    textField.inputAccessoryView = inputAccessoryView;
//    return YES;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if (![theScheduleDoc.sch_ScheduleTime isEqualToString:textField.text]) {
//        theScheduleDoc.sch_ScheduleTime = textField.text;
//        
//        if (theScheduleDoc.ctlFlag == 0) {
//            theScheduleDoc.ctlFlag = 2;
//        }
//    }
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    return YES;
//}
//
//@end
