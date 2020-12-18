//
//  MenuDoc.m
//  Customers
//
//  Created by ZhongHe on 13-4-23.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "MenuDoc.h"

@implementation MenuDoc

@synthesize MenuName = _MenuName;
@synthesize Image = _Image;
@synthesize View = _View;

- (id)initWithMenuName:(NSString *)MenuName Image:(UIImage *)Image View:(NSString *)View {
    if ((self = [super init])) {
        self.MenuName = MenuName;
        self.Image = Image;
        self.View = View;
    }
    return self;
}

@end
