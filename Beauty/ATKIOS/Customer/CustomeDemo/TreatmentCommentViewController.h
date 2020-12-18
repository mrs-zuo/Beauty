//
//  TreatmentCommentViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-2-11.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@class CommentDoc;
@interface TreatmentCommentViewController : ZXBaseViewController<UITextViewDelegate>
@property (strong, nonatomic) CommentDoc *treatmentComment;
@property (assign, nonatomic) NSInteger orderId;
@property (assign, nonatomic) long long GroupNo;
@property (assign ,nonatomic) NSInteger treatMentOrGroup;//1 TG  0 teatment
@end
