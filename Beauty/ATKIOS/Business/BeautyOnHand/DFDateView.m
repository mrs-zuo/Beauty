//
//  DFDateView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-15.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DFDateView.h"
@interface DFDateView()

@property (nonatomic, strong) UIView    *backView;
@property (nonatomic, strong) UIToolbar *toolBar;

@end

@implementation DFDateView
@synthesize backView;
@synthesize datePicker;
@synthesize toolBar;


-(void)createBackgroundView
{
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    self.opaque = NO;
    
    UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
    [appWindow addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    }];
    
}
- (void)show
{
    [self createBackgroundView];
    self.backView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backView.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.backView];
    
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(20, 90, 200, 20)];
    self.toolBar.bounds = CGRectMake(0, 0, 320, 35);
    self.toolBar.center = CGPointMake(160, 17.5);
    self.toolBar.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
    UIBarButtonItem *okBut = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(completion)];
    [okBut setTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    
    UIBarButtonItem *other = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(other)];
    [other setTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];

    UIBarButtonItem *fixidSpaces = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixidSpaces.width = 6.0f;
    
    UIBarButtonItem *flexibleSpaces = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.toolBar setItems:@[fixidSpaces, other, flexibleSpaces, okBut, fixidSpaces]];
    
    self.datePicker = [[UIDatePicker alloc]init];
    self.datePicker.frame = CGRectMake(0, 35, kSCREN_BOUNDS.size.width, 200);
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.date = [NSDate date];
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    
    [self.backView addSubview:self.toolBar];
    [self.backView addSubview:self.datePicker];
    [self becomeFirstResponder];
    
    [self animateIn];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)animateIn
{
    self.backView.frame = CGRectMake(0, kSCREN_BOUNDS.size.height, kSCREN_BOUNDS.size.width, 260);
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.frame = CGRectMake(0, (kSCREN_BOUNDS.size.height - 220), kSCREN_BOUNDS.size.width, 315);
    } completion:^(BOOL finished) {
        if (self.startBlock) {
            NSDate *inDate = self.startBlock();
            if (inDate) {
                [self.datePicker setDate:inDate animated:YES];
            }
        }
    }];
}

-(void)animateOut
{
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.frame = CGRectMake(0, kSCREN_BOUNDS.size.height, kSCREN_BOUNDS.size.width, 260);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self animateOut];
}

- (void)other
{
    [self animateOut];
}

- (void)completion
{
    self.completionBlock(self.datePicker.date);
    [self animateOut];
}

@end
