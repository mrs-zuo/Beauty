//
//  ReportBasicTopView.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/11.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#define kText_borderColor [UIColor colorWithRed:233.0 / 255.0 green:233.0 / 255.0  blue:233.0 / 255.0  alpha:1].CGColor;
#define kbtn_borderColor [UIColor colorWithRed:49.0 / 255.0 green:184.0 / 255.0  blue:235.0 / 255.0  alpha:1].CGColor;

#define kTextTitleColor [UIColor colorWithRed:135.0 / 255.0 green:135.0 / 255.0  blue:135.0 / 255.0  alpha:1];
#define kLineViewColor [UIColor colorWithRed:230.0 / 255.0 green:230.0 / 255.0  blue:230.0 / 255.0  alpha:1];

#import "ReportBasicTopView.h"
#import "UIButton+InitButton.h"
#import "UIButton+WebCache.h"
#import "noCopyTextField.h"
#import "StatementCategoryDoc.h"

@interface ReportBasicTopView () <UITextFieldDelegate>

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


@implementation ReportBasicTopView
@synthesize cycleType,statementCategoryID,extractItemType;
//->Ver.010
@synthesize displayType;
//<-Ver.010
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
    self.cycleView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, kSCREN_BOUNDS.size.width - 10,88)];
    UILabel *cycleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width - 10, 44)];
    cycleLab.text = @"周期";
    cycleLab.textColor = [UIColor colorWithRed:112.0 / 255.0 green:112.0 / 255.0 blue:112.0 / 255.0  alpha:1];
    cycleLab.textAlignment = NSTextAlignmentLeft;
    [self.cycleView addSubview:cycleLab];
    
    NSArray *cycleArr = @[@"日", @"月", @"季", @"年", @"自定义"];
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
        [self.cycleView addSubview:btn];
    }
    [self addSubview:self.cycleView];
    
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.cycleView.frame.origin.y + self.cycleView.frame.size.height, kSCREN_BOUNDS.size.width - 10, 1)];
    self.lineView.backgroundColor = kLineViewColor;
    [self addSubview:self.lineView];
    
    self.typeView = [[UIView alloc]initWithFrame:CGRectMake(0, self.lineView.frame.size.height + self.lineView.frame.origin.y,kSCREN_BOUNDS.size.width - 10,88)];
    UILabel *typeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width - 10, 44)];
    typeLab.text = @"类别";
    typeLab.textColor = [UIColor colorWithRed:112.0 / 255.0 green:112.0 / 255.0 blue:112.0 / 255.0  alpha:1];
    typeLab.textAlignment = NSTextAlignmentLeft;
    [self.typeView addSubview:typeLab];
    
    NSArray *typeArr;
    if ([reportTitle isEqualToString:@"我的报表"] || [reportTitle isEqualToString:@"员工报表"] || [reportTitle isEqualToString:@"分组报表"]) {
        typeArr = @[@"商品/服务",@"顾客"];
        
    }else{
        typeArr = @[@"商品/服务", @"储值卡", @"顾客"];
    }
    for (int i = 0 ; i < typeArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithTitle:typeArr[i] target:self selector:@selector(btnExtractItemType:) frame:CGRectMake(i * ((kSCREN_BOUNDS.size.width - 10)/ typeArr.count), 44 + 7, (kSCREN_BOUNDS.size.width - 10) / typeArr.count, 30) titleColor:[UIColor blackColor] backgroudColor:nil];
        btn.tag = i + 1;
        if (typeArr.count == 2 && btn.tag == 2) { // 顾客的时候 extractItemType == 3
            btn.tag = 3;
        }
        if (extractItemType == btn.tag) {
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = kbtn_borderColor;
            btn.backgroundColor  = [UIColor whiteColor];
        }else{
            btn.layer.borderWidth = 0;
            btn.layer.borderColor = [UIColor clearColor].CGColor;
            btn.backgroundColor  = [UIColor clearColor];
        }
        [self.typeView addSubview:btn];
    }
    //->Ver.010
    //[self addSubview:self.typeView];
    if  (displayType != 1){
        [self addSubview:self.typeView];
    }
    //<-Ver.010

    self.finishedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.finishedBtn.frame =CGRectMake(15, 88 * 2 + 10, (kSCREN_BOUNDS.size.width -10 - 30), 44);
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
        queryPad.frame = CGRectMake(0, 88, (kSCREN_BOUNDS.size.width - 10), 44);
        queryPad.tag = 100;
        queryPad.backgroundColor  = [UIColor colorWithRed:246.0 / 255.0 green:246.0 / 255.0  blue:246.0 / 255.0  alpha:1];
        [self.cycleView addSubview:queryPad];
    }
    
    if(beginTime == nil) {
        beginTime = [[noCopyTextField alloc]init];
        beginTime.text = [dateFormatter stringFromDate:self.startDateBasic];
        beginTime.frame = CGRectMake(10.f, 88 + 7,(kSCREN_BOUNDS.size.width - 40) / 2 , 30);
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
        
    }
   
    if(timeGap == nil)
    {
        timeGap = [[UILabel alloc] init];
        timeGap.text = @"-";
        timeGap.frame = CGRectMake(beginTime.frame.origin.x + beginTime.frame.size.width + 2, 88 + 7, 6.f, 30);
        timeGap.textColor = [UIColor grayColor];
        timeGap.backgroundColor = [UIColor clearColor];
        [self.cycleView addSubview:timeGap];
        
    }
    
    if(endTime == nil) {
        endTime = [[noCopyTextField alloc]init];
        endTime.text = [dateFormatter stringFromDate:self.endDateBasic];
        endTime.frame = CGRectMake(timeGap.frame.origin.x + 6 + 2, 88 + 7, (kSCREN_BOUNDS.size.width - 40) / 2, 30);
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
        [self.cycleView addSubview:endTime];
    }
  
}
- (void)initScrollView
{
    if (!self.typeScrollView) {
        self.typeScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 88, (kSCREN_BOUNDS.size.width - 10), 44)];
        [self.typeView addSubview:self.typeScrollView];
    }
    if (self.statementCategoryList.count > 0) {
        CGFloat width = 0.0f;
        for (int i = 0; i < self.statementCategoryList.count ; i ++) {
            StatementCategoryDoc *statementDoc = self.statementCategoryList[i];
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]};
            CGRect rect = [statementDoc.CategoryName boundingRectWithSize:CGSizeMake(MAXFLOAT, 30) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
            CGRect temp = rect;
            temp.size.width += 20;
            rect = temp;
            UIButton *btn = [UIButton buttonWithTitle:statementDoc.CategoryName target:self selector:@selector(btnRefreshType:) frame:CGRectMake(10 + width, 7, rect.size.width, 30) titleColor:[UIColor blackColor] backgroudColor:nil];
            btn.tag = statementDoc.ID;
            if (statementCategoryID == btn.tag) {
                btn.layer.borderWidth = 1;
                btn.layer.borderColor = kbtn_borderColor;
                btn.backgroundColor = [UIColor whiteColor];
            }else{
                btn.layer.borderWidth = 0;
                btn.layer.borderColor = [UIColor clearColor].CGColor;
                btn.backgroundColor = [UIColor clearColor];
            }

            [self.typeScrollView addSubview:btn];
//            [btn sizeToFit];
            float btnwidth = btn.frame.size.width;
            width += btnwidth + 10;
        }
        self.typeScrollView.contentSize = CGSizeMake(width, 44);
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
    

    if (cycleType == 4) { // 自定义
        if (!self.isChangeCycleViewFrame) {
            self.isChangeCycleViewFrame = !self.isChangeCycleViewFrame;
            CGRect rect = self.frame;
            rect.size.height += 44;
            self.frame = rect;
            
            CGRect cycleViewRect = self.cycleView.frame;
            cycleViewRect.size.height += 44;
            self.cycleView.frame = cycleViewRect;
            
            CGRect lineViewRect = self.lineView.frame;
            lineViewRect.origin.y += 44;
            self.lineView.frame = lineViewRect;
            
            
            CGRect typeViewRect = self.typeView.frame;
            typeViewRect.origin.y += 44;
            self.typeView.frame = typeViewRect;
            
            CGRect finishedBtnRect = self.finishedBtn.frame;
            finishedBtnRect.origin.y += 44;
            self.finishedBtn.frame = finishedBtnRect;
            
            [self initialCustomizeQueryPad];
            
            if ([self.delegate respondsToSelector:@selector(ReportBasicTopView:repBeginTime:repEndTime:)]) {
                [self.delegate ReportBasicTopView:self repBeginTime:beginTime repEndTime:endTime];
            }
        }
    }else{
        if (self.isChangeCycleViewFrame) {
            self.isChangeCycleViewFrame = !self.isChangeCycleViewFrame;
            CGRect rect = self.frame;
            rect.size.height -= 44;
            self.frame = rect;
            
            CGRect cycleViewRect = self.cycleView.frame;
            cycleViewRect.size.height -= 44;
            self.cycleView.frame = cycleViewRect;
            
            CGRect lineViewRect = self.lineView.frame;
            lineViewRect.origin.y -= 44;
            self.lineView.frame = lineViewRect;
            
            CGRect typeViewRect = self.typeView.frame;
            typeViewRect.origin.y -= 44;
            self.typeView.frame = typeViewRect;
            
            CGRect finishedBtnRect = self.finishedBtn.frame;
            finishedBtnRect.origin.y -= 44;
            self.finishedBtn.frame = finishedBtnRect;
            
            [queryPad removeFromSuperview];
            queryPad = nil;
            [beginTime removeFromSuperview];
            beginTime = nil;
            [timeGap removeFromSuperview];
            timeGap = nil;
            [endTime removeFromSuperview];
            endTime = nil;
        }
    }
    
}
- (void)btnExtractItemType:(UIButton *)sender
{
    extractItemType =  sender.tag;
    for (UIView *vi in self.typeView.subviews) {
        if ([vi isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)vi;
            if (extractItemType == btn.tag) {
                btn.layer.borderWidth = 1;
                btn.layer.borderColor =kbtn_borderColor;
                btn.backgroundColor = [UIColor whiteColor];
            }else{
                btn.layer.borderWidth = 0;
                btn.layer.borderColor =kbtn_borderColor;
                btn.backgroundColor = [UIColor clearColor];

            }
        }
    }
    if (extractItemType == 1) { // 服务和商品
        if (!self.isChangeTypeViewFrame) {
            self.isChangeTypeViewFrame = !self.isChangeTypeViewFrame;
            CGRect rect = self.frame;
            rect.size.height += (44 + 10);
            self.frame = rect;
            
            CGRect typeViewRect = self.typeView.frame;
            typeViewRect.size.height += 44;
            self.typeView.frame = typeViewRect;

            
            CGRect finishedBtnRect = self.finishedBtn.frame;
            finishedBtnRect.origin.y += (44 + 10);
            self.finishedBtn.frame = finishedBtnRect;
            
            [self initScrollView];
 
        }
    }else{
        if (self.isChangeTypeViewFrame) {
            self.isChangeTypeViewFrame = !self.isChangeTypeViewFrame;

            CGRect rect = self.frame;
            rect.size.height -= 44;
            self.frame = rect;
            
            CGRect typeViewRect = self.typeView.frame;
            typeViewRect.size.height -= 44;
            self.typeView.frame = typeViewRect;
            
            CGRect finishedBtnRect = self.finishedBtn.frame;
            finishedBtnRect.origin.y -= (44 + 10);
            self.finishedBtn.frame = finishedBtnRect;
            
            [self.typeScrollView removeFromSuperview];
            self.typeScrollView = nil;
        }
    }
}
- (void)btnRefreshType:(UIButton *)sender
{
    statementCategoryID = sender.tag;
    for (UIView *vi in self.typeScrollView.subviews) {
        if ([vi isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)vi;
            if (statementCategoryID == btn.tag) {
                btn.layer.borderWidth = 1;
                btn.layer.borderColor =kbtn_borderColor;
                btn.backgroundColor = [UIColor whiteColor];
            }else{
                btn.layer.borderWidth = 0;
                btn.layer.borderColor =kbtn_borderColor;
                btn.backgroundColor = [UIColor clearColor];
            }
        }
    }

}


- (void)finishedEvent:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(ReportBasicTopView:selCycleType:selExtractItemType:selStatementCategoryID:)]) {
        [self.delegate ReportBasicTopView:self selCycleType:cycleType selExtractItemType:extractItemType selStatementCategoryID:statementCategoryID];
    }
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    if ([self.delegate respondsToSelector:@selector(ReportBasicTopView:textField:)]) {
        [self.delegate ReportBasicTopView:self textField:textField];
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
