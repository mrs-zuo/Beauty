//
//  AccountDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "AccountDoc.h"
#import "DEFINE.h"

@implementation AccountDoc
@synthesize cos_Introduction;
@synthesize cos_Expert;
@synthesize instro_Height;
@synthesize expert_Height;

- (id)init
{
    self = [super init];
    if (self) {
        self.cos_Introduction = @"";
        self.cos_Expert = @"";
    }
    return self;
}

- (void)setCos_Introduction:(NSString *)newCos_Introduction
{
    cos_Introduction = newCos_Introduction;
    
    CGSize size = [cos_Introduction sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(290.0f, 400.0f) lineBreakMode:NSLineBreakByWordWrapping];
    instro_Height = size.height == 0 ? 18.0f : size.height;
    
}

- (void)setCos_Expert:(NSString *)newCos_Expert
{
    cos_Expert = newCos_Expert;
    
    CGSize size = [cos_Expert sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(290.0f, 400.0f) lineBreakMode:NSLineBreakByWordWrapping];
    expert_Height = size.height == 0 ? 18.0f : size.height;
    
      DLOG(@"expert_Height:%f", expert_Height);
}

@end
