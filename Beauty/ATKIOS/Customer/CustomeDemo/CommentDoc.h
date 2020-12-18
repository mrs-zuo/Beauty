//
//  CommentDoc.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-2-11.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentDoc : NSObject
@property (assign, nonatomic) NSInteger comment_TreatmentID;//TreatmentID
@property (assign, nonatomic) NSInteger comment_ReviewID;   //评论ID
@property (assign, nonatomic) NSInteger comment_Score;      //评论得分
@property (copy  , nonatomic) NSString *comment_Describe;   //评论描述
@end
