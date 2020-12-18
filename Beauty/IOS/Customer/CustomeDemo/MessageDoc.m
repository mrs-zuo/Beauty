//
//  MessageDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-7-10.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "MessageDoc.h"

@implementation MessageDoc
@synthesize mesg_MessageContent,mesg_MsgHegiht,mesg_MsgWith;
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key rangeOfString:@"mesg_"].length <= 0)
        [self setValue:value forKey:[NSString stringWithFormat:@"mesg_%@",key]];
    else
        NSLog(@"%@",key);
        
}


-(void)setMesg_MessageContent:(NSString *)newMesg_MessageContent
{
    mesg_MessageContent = newMesg_MessageContent;
}

- (CGFloat)mesg_MsgHegiht {
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = mesg_MessageContent;
    textView.font = kFont_Light_16;
    CGSize size = [textView sizeThatFits:CGSizeMake(440, FLT_MAX)];
    float currentHeight = size.height;
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    mesg_MsgHegiht = currentHeight;
    
    return mesg_MsgHegiht;
}

- (CGFloat)mesg_MsgWith {
    
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = mesg_MessageContent;
    textView.font = kFont_Light_16;
    CGSize size = [textView sizeThatFits:CGSizeMake(440, FLT_MAX)];
    float currentHeight = size.height;
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    
    mesg_MsgWith = size.width;
    
    if (IOS6) {
        CGSize tmpSize = [textView.text sizeWithFont:kFont_Medium_18 constrainedToSize:CGSizeMake(440, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        mesg_MsgWith = tmpSize.width;
    }
    return mesg_MsgWith;
}


@end
