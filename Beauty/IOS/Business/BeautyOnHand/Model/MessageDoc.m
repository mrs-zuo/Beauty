//
//  MessageDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-10.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "MessageDoc.h"
#import "DEFINE.h"
#import "UIPlaceHolderTextView.h"

@implementation MessageDoc
@synthesize mesg_MessageContent, mesg_MsgHegiht, mesg_MsgWith;

- (id)init
{
    self = [super init];
    if (self) {
        [self setMesg_MessageContent:@""];
        self.mesg_FromUserIDArray = [NSMutableArray array];
        self.mesg_FromUserNameArray = [NSMutableArray array];
        self.mesg_FromUserImgURLArray = [NSMutableArray array];
    } 
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqual:@"NewMessageCount"]) {
        self.mesg_NewsCount = [value integerValue];
    }
    if ([key isEqual:@"CustomerID"]) {
        self.mesg_ToUserID = [value integerValue];
    }
    if ([key isEqual:@"CustomerName"]) {
        self.mesg_ToUserName = value;
    }
    if ([key isEqual:@"Available"]) {
        self.customerAvailable = [value integerValue];
    }
    if ([key isEqual:@"MessageContent"]) {
        self.mesg_MessageContent = value;
    }
    if ([key isEqual:@"SendTime"]) {
        self.mesg_SendTime = value;
    }
    if ([key isEqual:@"HeadImageURL"]) {
        self.customerHeadImgURL = value;
    }
//    if ([key isEqual:@"Chat_Use"]) {
//        self.mesg_NewsCount = [value integerValue];
//    }
    
    
    if ([key isEqual:@"MessageID"]) {
        self.mesg_ID = [value integerValue];
    }
    if ([key isEqual:@"FromUserID"]) {
        self.mesg_FromUserID = [value integerValue];
    }
    if ([key isEqual:@"FromUserName"]) {
        self.mesg_FromUserName = value;
    }
    if ([key isEqual:@"SendCount"]) {
        self.mesg_AllMsgCount = [value integerValue];
    }
    if ([key isEqual:@"ReceiveCount"]) {
        self.mesg_ReadMsgCount = [value integerValue];
    }
    if ([key isEqual:@"ToUserName"]) {
        self.mesg_FromUserNameArray = value;
    }
    if ([key isEqual:@"SendOrReceiveFlag"]) {
        self.mesg_SendOrReceiveFlag = [value integerValue];
    }
    if ([key isEqual:@"GroupFlag"]) {
        self.mesg_GroupFlag = [value integerValue];
    }
}

- (NSString *)mesg_SendTime {
    return  [[_mesg_SendTime substringToIndex:16] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
}

- (void)setMesg_MessageContent:(NSString *)newMesg_MessageContent
{
    mesg_MessageContent = newMesg_MessageContent;
    
//    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
//    textView.text = mesg_MessageContent;
//    textView.font = kFont_Light_16;
//    CGSize size = [textView sizeThatFits:CGSizeMake(kChat_Message_WIDTH, FLT_MAX)];
//    float currentHeight = size.height;
//    
//    if (currentHeight < kTableView_HeightOfRow) {
//        currentHeight = kTableView_HeightOfRow;
//    }
//    mesg_MsgHegiht = currentHeight;
//    mesg_MsgWith = size.width;
//    
//    if (IOS6) {
//        CGSize tmpSize = [textView.text sizeWithFont:kFont_Medium_18 constrainedToSize:CGSizeMake(kChat_Message_WIDTH, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//        mesg_MsgWith = tmpSize.width;
//    }
//    textView = nil;
}

- (CGFloat)mesg_MsgWith {
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = mesg_MessageContent;
    textView.font = kFont_Light_16;
    CGSize size = [textView sizeThatFits:CGSizeMake(kChat_Message_WIDTH, FLT_MAX)];
    
//    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//    CGRect size = [mesg_MessageContent boundingRectWithSize:textView.bounds.size options:options attributes:nil context:nil];
    
    float currentHeight = size.height;
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    
    mesg_MsgWith = size.width;
    
    if (IOS6) {
        CGSize tmpSize = [textView.text sizeWithFont:kFont_Medium_18 constrainedToSize:CGSizeMake(kChat_Message_WIDTH, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        mesg_MsgWith = tmpSize.width;
    }
    return mesg_MsgWith;
}

- (CGFloat)mesg_MsgHegiht {
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = mesg_MessageContent;
    textView.font = kFont_Light_16;
    CGSize size = [textView sizeThatFits:CGSizeMake(kChat_Message_WIDTH, FLT_MAX)];
    float currentHeight = size.height;
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    mesg_MsgHegiht = currentHeight;
    
    return mesg_MsgHegiht;
}



/*
- (CGFloat)mesg_MarHeight
{
     UIPlaceHolderTextView *textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, MAXFLOAT)];
    
    textView.text = mesg_MessageContent;
    textView.font = kFont_Light_16;
    CGFloat currentHeight;
    if (IOS6) {
        currentHeight = [mesg_MessageContent sizeWithFont:kFont_Light_18 constrainedToSize:CGSizeMake(300.0f, MAXFLOAT)].height;
    } else {
        currentHeight = [textView sizeThatFits:CGSizeMake(300.0f, MAXFLOAT)].height;
    }
    //    CGRect rect = contentEditText.frame;
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    //    rect.size.height = currentHeight;
    _mesg_MarHeight = currentHeight;
    
    return _mesg_MarHeight;
}
*/
@end
