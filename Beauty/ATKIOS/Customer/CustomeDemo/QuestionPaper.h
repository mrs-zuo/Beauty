//
//  QuestionPaper.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^test)(NSArray *);
@class AFHTTPRequestOperation;
@class Questions;
@interface QuestionPaper : NSObject
@property (nonatomic, strong) NSString *Title;
@property (nonatomic, assign) NSInteger PaperID;
@property (nonatomic, assign) NSInteger GroupID;
@property (nonatomic, strong) NSAttributedString *attriTitle;
@property (nonatomic, assign) CGSize titleSize;
@property (nonatomic, assign) BOOL  IsVisible;
@property (nonatomic, assign) BOOL  CanEditAnswer;
@property (nonatomic, strong) NSString *UpdateTime;
@property (nonatomic, strong) NSString *ResponsiblePersonName;
@property (nonatomic, assign) CGFloat   responsiblePersonWidth;
@property (nonatomic, strong) NSString *CustomerName;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) NSArray *questionsList;

- (id)initWithDictionary:(NSDictionary *)dic;

+ (AFHTTPRequestOperation *)requestAnswerPaperListCompletion:(void(^)(NSArray *array, NSString *mesg))block;

- (void)getQuestionsOfThePaperCompletion:(void(^)(NSArray *))block;

@end
