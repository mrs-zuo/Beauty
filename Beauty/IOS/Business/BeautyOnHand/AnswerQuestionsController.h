//
//  AnswerQuestionsController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/26.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QuestionPaper;
@class Questions;
@interface AnswerQuestionsController : UIViewController
@property (nonatomic, strong) QuestionPaper *quesPaper;
@property (nonatomic, assign) NSInteger     questionIndex;

@end
