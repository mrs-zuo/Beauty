//
//  CommentDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-14.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReviewDoc : NSObject
@property (assign, nonatomic) NSInteger review_ID;
@property (copy, nonatomic)   NSString *review_Comment;
@property (assign, nonatomic) NSInteger review_StarCnt;
@property (copy, nonatomic) NSString * ServiceName;
@property (assign, nonatomic) NSInteger TGFinishedCount;
@property (assign, nonatomic) NSInteger TGTotalCount;
@property (copy , nonatomic) NSString * TGEndTime;
@end
