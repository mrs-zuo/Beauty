//
//  ModifyAnswerController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/29.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QuestionPaper;

@interface ModifyAnswerController : UIViewController

@property (nonatomic, strong) QuestionPaper *questionPaper;
@property (nonatomic, assign) NSInteger questionIndex;
@end
