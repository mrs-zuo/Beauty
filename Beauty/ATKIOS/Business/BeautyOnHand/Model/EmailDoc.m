//
//  EmailDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "EmailDoc.h"

@implementation EmailDoc
@synthesize emailType;
@synthesize email_Type;
@synthesize ctlFlag;
@synthesize email_ID;
@synthesize email_Email;

- (void)setEmail_Type:(NSInteger)newEmail_Type
{
    email_Type = newEmail_Type;
    [self setEmialTypeByType];
}

- (void)setEmialTypeByType
{
    switch (self.email_Type) {
        case 0:  emailType = @"住宅";  break;
        case 1:  emailType = @"工作";  break;
        case 2:  emailType = @"其他";  break;
        default: emailType = @"";     break;
    }
}
@end
