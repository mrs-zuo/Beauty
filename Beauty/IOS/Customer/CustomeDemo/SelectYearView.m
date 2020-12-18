//
//  SelectYearView.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/2/29.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "SelectYearView.h"
#import "NSDate+Convert.h"
 NSInteger startYear = 2015;

const CGFloat pickerView_Heigth = 216;


@interface SelectYearView () <UIPickerViewDataSource,UIPickerViewDelegate>


@property (nonatomic,copy) NSString *yearStr;
@property (nonatomic,strong) NSMutableArray *yearDatas;

@end
@implementation SelectYearView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self initView];
    }
    return self;
  
}
- (void)initData
{
    _yearDatas = [NSMutableArray array];
    NSString *yearStr = [NSDate stringFromDate:[NSDate date]];
    NSInteger currentYear = [[yearStr substringToIndex:4] integerValue];
    NSInteger count = currentYear - startYear + 1;
    for (int i = 0; i < count; i ++) {
        NSInteger year = currentYear - i;
        NSString *yearStr = [NSString stringWithFormat:@"%ld年",(long)year];
        [_yearDatas addObject:yearStr];
    }   
}
- (void)initView
{
    self.userInteractionEnabled = YES;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cance:)];
    [leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kNormalFont_14, UITextAttributeFont,nil] forState:UIControlStateNormal];
    leftItem.tintColor = RGBA(74, 74, 74, 1);
   
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirm:)];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kNormalFont_14, UITextAttributeFont,nil] forState:UIControlStateNormal];
    rightItem.tintColor = RGBA(74, 74, 74, 1);
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *titleArrs = @[leftItem,flexibleSpace,rightItem];
    UIToolbar *bar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    bar.barTintColor =  kDefaultBackgroundColor;//RGBA(224, 224, 224, 1);
    [bar setItems:titleArrs];
    [self addSubview:bar];
    
    UIPickerView *pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, kSCREN_BOUNDS.size.width, pickerView_Heigth)];
    pickView.delegate =  self;
    pickView.dataSource = self;
    [self addSubview:pickView];
}
- (void)cance:(UIBarButtonItem *)sender
{
    self.disSelectYearViewBlock(@"");
}
- (void)confirm:(UIBarButtonItem *)sender
{
    self.selectYearViewBlock(self.yearStr);
}

#pragma mark -  UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _yearDatas.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _yearDatas[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.yearStr = _yearDatas[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kTableView_DefaultCellHeight;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:kNormalFont_14];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}


@end
