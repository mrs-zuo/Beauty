//
//  MessageDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-7-10.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageDoc : NSObject

@property (assign, nonatomic) NSInteger mesg_AccountID;
@property (copy, nonatomic) NSString *mesg_AccountName;
@property (assign, nonatomic) NSInteger mesg_Available;//account 是否可用

@property (assign, nonatomic) NSInteger mesg_MessageID;
@property (assign, nonatomic) NSInteger mesg_MessageType;
@property (assign, nonatomic) NSInteger mesg_SenderType;
@property (assign, nonatomic) NSInteger mesg_GroupFlag; // 0:非群发    1:群发
@property (assign, nonatomic) NSInteger mesg_FromUserID;
@property (assign, nonatomic) NSInteger mesg_ToUserID;
@property (copy, nonatomic) NSString *mesg_MessageContent;
@property (copy, nonatomic) NSString *mesg_SendTime;  //
@property (copy, nonatomic) NSString *mesg_ReceiveTime; //

@property (assign, nonatomic) NSInteger mesg_NewMessageCount;

@property (assign, nonatomic) NSInteger mesg_AllMsgCount;
@property (assign, nonatomic) NSInteger mesg_ReadMsgCount;
@property (assign, nonatomic) NSInteger mesg_Chat_Use;
//发送或是接受的标记 by wx
@property (assign, nonatomic) NSInteger mesg_SendOrReceiveFlag;
@property (assign, nonatomic) int mesg_Status; // 0发送成功  1正在发送  2发送失败
//无论是单发还是群发，用此string发送其ID by wx
@property (copy, nonatomic) NSString *mesg_ToUserIDString;

@property (copy, nonatomic) NSString *mesg_HeadImageURL;

//other
@property (assign, nonatomic) CGFloat mesg_MsgHegiht;
@property (nonatomic, assign) CGFloat mesg_MarHeight; //营销内容高度
@property (assign, nonatomic) CGFloat mesg_MsgWith;


@end
