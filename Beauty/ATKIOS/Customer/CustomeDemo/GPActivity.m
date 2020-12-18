//
//  GPActivity.m
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-13.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "GPActivity.h"

@implementation GPActivity

- (id)initWithTitle:(NSString *)title image:(UIImage *)image activityHander:(GPActivityHandler)activityHander
{
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        _activityHander = activityHander;
    }
    return self;
}

@end
