//
//  ReportCountTopView.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/11.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#define kText_borderColor [UIColor colorWithRed:233.0 / 255.0 green:233.0 / 255.0  blue:233.0 / 255.0  alpha:1].CGColor;
#define kbtn_borderColor [UIColor colorWithRed:49.0 / 255.0 green:184.0 / 255.0  blue:235.0 / 255.0  alpha:1].CGColor;

#define kTextTitleColor [UIColor colorWithRed:135.0 / 255.0 green:135.0 / 255.0  blue:135.0 / 255.0  alpha:1];
#define kLineViewColor [UIColor colorWithRed:230.0 / 255.0 green:230.0 / 255.0  blue:230.0 / 255.0  alpha:1];

#import "ReportCountTopView.h"
#import "UIButton+InitButton.h"
#import "UIButton+WebCache.h"
#import "noCopyTextField.h"
#import "StatementCategoryDoc.h"

@interface ReportCountTopView () <UITextFieldDelegate>

@property (nonatomic,strong) UIView *typeView;
@property (nonatomic,strong) UIView *cycleView;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,strong) UIButton *finishedBtn;


@property (strong, nonatomic) noCopyTextField *beginTime;
@property (strong, nonatomic) noCopyTextField *endTime;
@property (strong, nonatomic) UILabel *timeGap;
@property (strong, nonatomic) UIButton *queryButton;
@property (strong, nonatomic) UIImageView *queryPad;
@property (strong, nonatomic) UITextField *textField_Selected;
@property (strong, nonatomic) UIScrollView *typeScrollView;


@property (nonatomic,assign) BOOL isChangeTypeViewFrame;
@property (nonatomic,assign) BOOL isChangeCycleViewFrame;


@end


@implementation ReportCountTopView
@synthesize cycleType,statementCategoryID,extractItemType;
@synthesize displayType;
@synthesize reportTitle;
@synthesize beginTime, endTime ,timeGap ,queryButton,queryPad,textField_Selected;


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:246.0 / 255.0 green:246.0 / 255.0  blue:246.0 / 255.0  alpha:1];
        self.isChangeTypeViewFrame = NO;
        self.isChangeCycleViewFrame = NO;
    }
    return self;
}

- (void)initView
{
    if  (displayType == 1){
        self.cycleView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, kSCREN_BOUNDS.size.width - 10,88)];
    }else{
        self.cycleView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, kSCREN_BOUNDS.size.width - 10,88 + 44)];
    }
    
    UILabel *cycleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width - 10, 44)];
    //cycleLab.text = @"周期";
    if  (displayType == 1){
        cycleLab.text = @"统计范围";
    }else{
        cycleLab.text = @"周期";
    }
    cycleLab.textColor = [UIColor colorWithRed:112.0 / 255.0 green:112.0 / 255.0 blue:112.0 / 255.0  alpha:1];
    cycleLab.textAlignment = NSTextAlignmentLeft;
    [self.cycleView addSubview:cycleLab];
    NSArray *cycleArr = @[@"日", @"周", @"月", @"季", @"年"];
    
    for (int i = 0 ; i < cycleArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithTitle:cycleArr[i] target:self selector:@selector(btnCycleType:) frame:CGRectMake(i * ((kSCREN_BOUNDS.size.width - 10)  / cycleArr.count), 44 + 7, (kSCREN_BOUNDS.size.width - 10) / cycleArr.count, 30) titleColor:[UIColor blackColor] backgroudColor:nil];
        btn.tag = i;
        if (cycleType == btn.tag) {
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = kbtn_borderColor;
            btn.backgroundColor = [UIColor whiteColor];
        }else{
            btn.layer.borderWidth = 0;
            btn.layer.borderColor = [UIColor clearColor].CGColor;
            btn.backgroundColor = [UIColor clearColor];
        }
        if  (displayType != 1){
        [self.cycleView addSubview:btn];
        }
    }
    
    //if  (displayType == 1){
    /*if  (displayType != 1){
        //[self addSubview:self.cycleView];
    }else{
        [self initialCustomizeQueryPad];
        if ([self.delegate respondsToSelector:@selector(ReportCountTopView:repBeginTime:repEndTime:)]) {
            [self.delegate ReportCountTopView:self repBeginTime:beginTime repEndTime:endTime];
        }
    }*/
    [self initialCustomizeQueryPad];
    if ([self.delegate respondsToSelector:@selector(ReportCountTopView:repBeginTime:repEndTime:)]) {
        [self.delegate ReportCountTopView:self repBeginTime:beginTime repEndTime:endTime];
    }
    
    [self addSubview:self.cycleView];
    
    self.finishedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //self.finishedBtn.frame =CGRectMake(15, 88 * 2 + 10, (kSCREN_BOUNDS.size.width -10 - 30), 44);
    if  (displayType == 1){
        self.finishedBtn.frame =CGRectMake(15, 88 + 10, (kSCREN_BOUNDS.size.width -10 - 30), 44);
    }else{
        self.finishedBtn.frame =CGRectMake(15, 88 + 44 + 10, (kSCREN_BOUNDS.size.width -10 - 30), 44);
    }
    [self.finishedBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.finishedBtn setTitleColor:[UIColor colorWithRed:26.0 /255.0  green:172.0 /255.0 blue:234.0 /255.0 alpha:1] forState:UIControlStateNormal];
    [self.finishedBtn addTarget:self action:@selector(finishedEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.finishedBtn.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.finishedBtn];
}




-(void )initialCustomizeQueryPad
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    
    if(queryPad == nil) {
        queryPad = [[UIImageView alloc ]init];
        //queryPad.frame = CGRectMake(0, 88, (kSCREN_BOUNDS.size.width - 10), 44);
        if  (displayType == 1){
        queryPad.frame = CGRectMake(0, 44 , (kSCREN_BOUNDS.size.width - 10), 44);
        }else{
            queryPad.frame = CGRectMake(0, 88 , (kSCREN_BOUNDS.size.width - 10), 44);
        }
        queryPad.tag = 100;
        queryPad.backgroundColor  = [UIColor colorWithRed:246.0 / 255.0 green:246.0 / 255.0  blue:246.0 / 255.0  alpha:1];
        [self.cycleView addSubview:queryPad];
    }
    
    if(beginTime == nil) {
        beginTime = [[noCopyTextField alloc]init];
        beginTime.text = [dateFormatter stringFromDate:self.startDateBasic];
        if  (displayType == 1){
            beginTime.frame = CGRectMake(10.f, 44 + 7,(kSCREN_BOUNDS.size.width - 40) / 2 , 30);
        }else{
            //beginTime.frame = CGRectMake(10.f, 88 + 7,(kSCREN_BOUNDS.size.width - 40) / 2 , 30);
            beginTime.frame = CGRectMake((kSCREN_BOUNDS.size.width - 40) / 3, 88 + 7,(kSCREN_BOUNDS.size.width - 40) / 2 , 30);
        }
        beginTime.tag = 102;
        beginTime.delegate = self;
        beginTime.font = kFont_Light_17;
        beginTime.layer.borderWidth = 1;
        beginTime.layer.borderColor = kText_borderColor;
        beginTime.textColor = kTextTitleColor;
        beginTime.borderStyle = UITextBorderStyleLine;
        beginTime.textAlignment = NSTextAlignmentCenter;
        if((IOS7 || IOS8))
            [beginTime setTintColor:[UIColor clearColor]];
        [self.cycleView addSubview:beginTime];
        if  (displayType != 1){
            UILabel *dateLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 88 ,(kSCREN_BOUNDS.size.width - 40) / 3, 44)];
            dateLab.text = @"统计截止日";
            dateLab.textColor = [UIColor colorWithRed:112.0 / 255.0 green:112.0 / 255.0 blue:112.0 / 255.0  alpha:1];
            dateLab.textAlignment = NSTextAlignmentLeft;
            [self.cycleView addSubview:dateLab];
        }
        
    }
    
    if(timeGap == nil)
    {
        timeGap = [[UILabel alloc] init];
        timeGap.text = @"-";
        timeGap.frame = CGRectMake(beginTime.frame.origin.x + beginTime.frame.size.width + 2, 44 + 7, 6.f, 30);
        timeGap.textColor = [UIColor grayColor];
        timeGap.backgroundColor = [UIColor clearColor];
        if  (displayType == 1){
        [self.cycleView addSubview:timeGap];
        }
    }
    
    if(endTime == nil) {
        endTime = [[noCopyTextField alloc]init];
        endTime.text = [dateFormatter stringFromDate:self.endDateBasic];
        endTime.frame = CGRectMake(timeGap.frame.origin.x + 6 + 2, 44 + 7, (kSCREN_BOUNDS.size.width - 40) / 2, 30);
        endTime.tag = 103;
        endTime.delegate = self;
        endTime.font = kFont_Light_17;
        endTime.layer.borderWidth = 1;
        endTime.layer.borderColor = kText_borderColor;
        endTime.textColor = kTextTitleColor;
        endTime.borderStyle = UITextBorderStyleLine;
        endTime.textAlignment = NSTextAlignmentCenter;
        if((IOS7 || IOS8))
            [endTime setTintColor:[UIColor clearColor]];
        if  (displayType == 1){
        [self.cycleView addSubview:endTime];
        }
    }
    
}

#pragma mark -  按钮事件
- (void)btnCycleType:(UIButton *)sender
{
    cycleType = sender.tag;
    for (UIView *vi in self.cycleView.subviews) {
        if ([vi isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)vi;
            if (cycleType == btn.tag) {
                btn.layer.borderWidth = 1;
                btn.layer.borderColor = kbtn_borderColor;
                btn.backgroundColor = [UIColor whiteColor];
            }else{
                btn.layer.borderWidth = 0;
                btn.layer.borderColor = [UIColor clearColor].CGColor;
                btn.backgroundColor = [UIColor clearColor];
            }
        }
    }
}


- (void)finishedEvent:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(ReportCountTopView:selCycleType:selExtractItemType:selStatementCategoryID:)]) {
        [self.delegate ReportCountTopView:self selCycleType:cycleType selExtractItemType:extractItemType selStatementCategoryID:statementCategoryID];
    }
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if ([self.delegate respondsToSelector:@selector(ReportCountTopView:textField:)]) {
        [self.delegate ReportCountTopView:self textField:textField];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return  YES;
}



@end

