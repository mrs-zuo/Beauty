//
//  RandomColor.m
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/14.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "RandomColor.h"
static Color _colors[12] = {
    {237 , 230 ,4},
    {158 , 209 ,16},
    {80 , 181 ,23},
    {23 , 144 ,103},
    {71 , 110 ,175},
    {159 , 73 ,172},
    {204 , 66 ,162},
    {255 , 59 ,167},
    {255 , 88 ,0},
    {255 , 129 ,0},
    {254 , 172 ,0},
    {255 , 204 ,0}
};
@implementation RandomColor
-(UIColor *)randomColor{
    Color randomColor = _colors[arc4random_uniform(12)];
    return [UIColor colorWithRed:(randomColor.red / 255.0f) green:(randomColor.green / 255.0f)  blue:(randomColor.blue / 255.0f)  alpha:1.0f];
}

@end
