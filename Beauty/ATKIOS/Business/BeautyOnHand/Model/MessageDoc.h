//
//  MessageDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-10.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageDoc : NSObject

@property (copy, nonatomic) NSString *customerHeadImgURL;
@property (assign, nonatomic) NSInteger customerAvailable;

@property (assign, nonatomic) NSInteger mesg_ID;
@property (assign, nonatomic) NSInteger mesg_MessageType;   // 0:飞语     1:营销
@property (assign, nonatomic) NSInteger mesg_GroupFlag;     // 0:非群发    1:群发
@property (copy, nonatomic) NSString *mesg_MessageContent;
@property (copy, nonatomic) NSString *mesg_SendTime;
@property (copy, nonatomic) NSString *mesg_ReceiveTime;
@property (assign, nonatomic) NSInteger mesg_NewsCount;

@property (assign, nonatomic) NSInteger mesg_AllMsgCount;
@property (assign, nonatomic) NSInteger mesg_ReadMsgCount;

// --Sender && Receiver
@property (strong, nonatomic) NSMutableArray *mesg_FromUserIDArray;
@property (assign, nonatomic) NSInteger mesg_FromUserID;
@property (assign, nonatomic) NSInteger mesg_ToUserID;

//无论是单发还是群发，用此string发送其ID by wx
@property (copy, nonatomic) NSString *mesg_ToUserIDString;

//发送或是接受的标记 by wx
@property (assign, nonatomic) NSInteger mesg_SendOrReceiveFlag;

@property (strong, nonatomic) NSMutableArray *mesg_FromUserNameArray;
@property (copy, nonatomic) NSString *mesg_FromUserName;
@property (copy, nonatomic) NSString *mesg_ToUserName;

@property (strong, nonatomic) NSMutableArray *mesg_FromUserImgURLArray;
@property (copy, nonatomic) NSString *mesg_FromUserImgURL;
@property (copy, nonatomic) NSString *mesg_ToUserImgURL;

// --other
@property (assign, nonatomic) CGFloat mesg_MsgHegiht;
@property (nonatomic, assign) CGFloat mesg_MarHeight; //营销内容高度
@property (assign, nonatomic) CGFloat mesg_MsgWith;
@property (assign, nonatomic) int mesg_Status; // 0发送成功  1正在发送  2发送失败 

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
