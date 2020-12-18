//
//  QuestionPaper.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PaperStatus) {
    PaperStatusNormol,
    PaperStatusStorage
    
};
@class AFHTTPRequestOperation;
@class DFFilterSet;
@class Questions;
@interface QuestionPaper : NSObject
@property (nonatomic, strong) NSString *Title;
@property (nonatomic, assign) NSInteger PaperID;
@property (nonatomic, assign) NSInteger GroupID;
@property (nonatomic, strong) NSAttributedString *attriTitle;
@property (nonatomic, strong) NSAttributedString *storageTitle;
@property (nonatomic, assign) CGSize titleSize;
@property (nonatomic, assign) BOOL  IsVisible;
@property (nonatomic, assign) BOOL  CanEditAnswer;
@property (nonatomic, strong) NSString *UpdateTime;
@property (nonatomic, strong) NSString *ResponsiblePersonName;
@property (nonatomic, assign) CGFloat   responsiblePersonWidth;
@property (nonatomic, strong) NSString *CustomerName;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) NSArray *questionsList;
@property (nonatomic, strong) NSString *answerString;
@property (nonatomic, assign) NSInteger customerID;
@property (nonatomic, assign) PaperStatus PaperStatus;
- (id)initWithDictionary:(NSDictionary *)dic;

+ (AFHTTPRequestOperation *)requestAnswerPaperList:(DFFilterSet *)filter pageIndex:(NSInteger)pageIndex date:(NSString *)date completion:(void(^)(NSArray *array, NSInteger indexPage, NSInteger count, NSString *mesg))block;

+ (AFHTTPRequestOperation *)requestPaperListCompletion:(void(^)(NSArray *, NSString *))block;

- (AFHTTPRequestOperation *)requestAddAnswerOfPaperCompletion:(void(^)(NSInteger , NSString *))block;

- (AFHTTPRequestOperation *)modifyTheQuestionOfThisPaper:(Questions *)question CompletionBlock:(void(^)(NSInteger , NSString *))block;
- (void)getQuestionsOfThePaperCompletion:(void(^)(NSArray *))block;

@end
