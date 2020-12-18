//
//  RandomColor.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/14.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef struct _Color {
    CGFloat red,green,blue;
}Color;
@interface RandomColor : NSObject
-(UIColor *)randomColor;
@end
