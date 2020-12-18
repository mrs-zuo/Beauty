//
//  QuestionDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-23.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionDoc : NSObject<NSCopying>
@property (assign, nonatomic) NSInteger question_ID;
@property (copy, nonatomic) NSString *question_Name;
@property (nonatomic, assign) CGFloat question_Height;
@property (assign, nonatomic) NSInteger question_Type;   //0 文本 1 单项 2 多选
@property (copy, nonatomic) NSString *question_Content;
@property (copy, nonatomic) NSString *question_Answer;      //用户答案，以0|0|1形式排列
@property (copy, nonatomic) NSString *question_AnswerWord;  //用户答案，以AA|BB|CC形式排列
@property (assign, nonatomic) NSInteger question_AnswerID;
@property (assign, nonatomic) NSInteger question_OptionNumber;
@end
