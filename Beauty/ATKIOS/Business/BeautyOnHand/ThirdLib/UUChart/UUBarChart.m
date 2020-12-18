//
//  UUBarChart.m
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#define k_xLabelWidth 46

#define Y_COUNT 10.0f

#import "UUBarChart.h"
#import "UUChartLabel.h"
#import "UUBar.h"

@interface UUBarChart ()
{
    UIScrollView *myScrollView;
}
@end

@implementation UUBarChart {
    NSHashTable *_chartLabelsForX;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(UUYLabelwidth, 0, frame.size.width-UUYLabelwidth, frame.size.height)];
        [self addSubview:myScrollView];
    }
    return self;
}

-(void)setYValues:(NSArray *)yValues
{
    _yValues = yValues;
    [self setYLabels:yValues];
}

-(void)setYLabels:(NSArray *)yLabels
{
    NSInteger max = -100;
    NSInteger min = 1000000000;
    for (NSArray * ary in yLabels) {
        for (NSString *valueString in ary) {
            NSInteger value = [valueString integerValue];
            if (value > max) {
                max = value;
            }
            if (value < min) {
                min = value;
            }
        }
    }
    //if (max < 10) {
    //    max = 10;
    //}
    if (self.showRange) {
        _yValueMin = (int)min;
    }else{
        _yValueMin = 0;
    }
    _yValueMax = (int)max;
    
    if (_chooseRange.max!=_chooseRange.min) {
        _yValueMax = _chooseRange.max;
        _yValueMin = _chooseRange.min;
    }
    
    //float level = (_yValueMax-_yValueMin) /Y_COUNT;
    //CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
    //CGFloat levelHeight = chartCavanHeight /Y_COUNT;
    
    NSInteger rowCount = 1;
    
    if ((int)(max) <= 10){
       rowCount = (int)(max);
    }else{
        rowCount = 10;
    }
    
    float level = (_yValueMax-_yValueMin) /rowCount;
    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
    CGFloat levelHeight = chartCavanHeight /rowCount;
    
    if( rowCount == 0 ){
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(0.0,chartCavanHeight + 5, UUYLabelwidth, UULabelHeight)];
        //Ver.010
        //label.text = [NSString stringWithFormat:@"%.1f",level * i+_yValueMin];
        label.text = [NSString stringWithFormat:@"%d",0];
        [self addSubview:label];
    }else{
        for (int i=0; i<=rowCount; i++) {
            UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(0.0,chartCavanHeight-i*levelHeight+5, UUYLabelwidth, UULabelHeight)];
            //Ver.010
            //label.text = [NSString stringWithFormat:@"%.1f",level * i+_yValueMin];
            label.text = [NSString stringWithFormat:@"%ld",(long)(level * i+_yValueMin)];
            //Ver.010
            if(i != 0){
                if ((long)(level * i+_yValueMin) != 0){
                    [self addSubview:label];
                }
            }else{
                [self addSubview:label];
            }
        }
    }
    
}

-(void)setXLabels:(NSArray *)xLabels
{
    if( !_chartLabelsForX ){
        _chartLabelsForX = [NSHashTable weakObjectsHashTable];
    }
    
    _xLabels = xLabels;
    NSInteger num;
    if (xLabels.count>=8) {
        num = 8;
    }else if (xLabels.count<=4){
        num = 4;
    }else{
        num = xLabels.count;
    }
    //    _xLabelWidth = myScrollView.frame.size.width/num;
    //>Ver.010
    //_xLabelWidth = k_xLabelWidth;
    
    if(xLabels.count>=8){
        _xLabelWidth = k_xLabelWidth;
    }else{
        _xLabelWidth = (kSCREN_BOUNDS.size.width - 10) / (xLabels.count + 1);
    }
    
    //<Ver.010
    
    for (int i=0; i<xLabels.count; i++) {
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake((i *  _xLabelWidth ), self.frame.size.height - UULabelHeight, _xLabelWidth, UULabelHeight)];
        label.text = xLabels[i];
        [myScrollView addSubview:label];
        [_chartLabelsForX addObject:label];
    }
    
    float max = (([xLabels count]-1)*_xLabelWidth + chartMargin)+_xLabelWidth;
    if (myScrollView.frame.size.width < max-10) {
        myScrollView.contentSize = CGSizeMake(max, self.frame.size.height);
    }
}

-(void)setColors:(NSArray *)colors
{
    _colors = colors;
}

- (void)setChooseRange:(CGRange)chooseRange
{
    _chooseRange = chooseRange;
}

-(void)strokeChart
{
    
    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
    
    for (int i=0; i<_yValues.count; i++) {
        if (i==2)
            return;
        NSArray *childAry = _yValues[i];
        for (int j=0; j<childAry.count; j++) {
            NSString *valueString = childAry[j];
            float value = [valueString floatValue];
            float grade = ((float)value-_yValueMin) / ((float)_yValueMax-_yValueMin);
            
             //添加一个显示Label
            UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake((j+(_yValues.count==1?0.1:0.05))*_xLabelWidth +i*_xLabelWidth * 0.47,0, _xLabelWidth * (_yValues.count==1?0.8:0.45), UULabelHeight)];
            if (valueString.floatValue > 0 ) {
                label.text = valueString;
            }
            [label setFont:[UIFont systemFontOfSize:10.0f]];
            [myScrollView addSubview:label];
            
            
            UUBar * bar = [[UUBar alloc] initWithFrame:CGRectMake((j+(_yValues.count==1?0.1:0.05))*_xLabelWidth +i*_xLabelWidth * 0.47, UULabelHeight, _xLabelWidth * (_yValues.count==1?0.8:0.45), chartCavanHeight)];
            bar.barColor = [_colors objectAtIndex:i];
            bar.grade = grade;
            
//            //添加一个显示Label
//            UILabel *titleLable = [[UILabel alloc]init];
//            titleLable.frame = CGRectMake(0, (1 - grade) * chartCavanHeight  , 46, 20);
//            titleLable.textAlignment = NSTextAlignmentCenter;
//            titleLable.textColor = [UIColor blackColor];
//            if (valueString.floatValue > 0 ) {
//                titleLable.text = valueString;
//            }
//            [titleLable setFont:[UIFont systemFontOfSize:10.0f]];
//            [bar addSubview:titleLable];
            
            [myScrollView addSubview:bar];
            
        }
    }
}

- (NSArray *)chartLabelsForX
{
    return [_chartLabelsForX allObjects];
}

@end
