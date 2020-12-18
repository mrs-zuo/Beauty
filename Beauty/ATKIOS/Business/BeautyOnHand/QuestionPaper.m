//
//  QuestionPaper.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "QuestionPaper.h"
#import "Questions.h"
#import "GPBHTTPClient.h"
#import "DFFilterSet.h"
#import "AppDelegate.h"

#define TitleLabelWidth     260.0
#define NameLabelWidth      80.0

@implementation QuestionPaper

- (CGSize)titleSize
{
    _titleSize = [self.attriTitle boundingRectWithSize:CGSizeMake(TitleLabelWidth, MAXFLOAT) options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) context:NULL].size;
    return _titleSize;
}

- (NSAttributedString *)attriTitle {
    NSMutableParagraphStyle *paragStyle = [[NSMutableParagraphStyle alloc] init];
    paragStyle.lineSpacing = 2.0;
    NSDictionary *attributedDic = @{NSFontAttributeName:kFont_Light_15, NSParagraphStyleAttributeName: paragStyle};
    if (!_Title) {
        _Title = @"";
    }
    if (_PaperStatus == PaperStatusStorage) {
        return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[草稿] %@", _Title] attributes:attributedDic];
    } else {
        _attriTitle = [[NSAttributedString alloc] initWithString:_Title attributes:attributedDic];
        return _attriTitle;
    }
}

- (NSString *)ResponsiblePersonName
{
    NSString *ResponsName = [NSString stringWithFormat:@"|%@", _ResponsiblePersonName];
    return ResponsName;
}

- (CGFloat)responsiblePersonWidth
{
    CGSize size;
    if (IOS6) {
        size = [self.ResponsiblePersonName sizeWithFont:kFont_Light_14 constrainedToSize:CGSizeMake(NameLabelWidth, 20) lineBreakMode:NSLineBreakByTruncatingTail];
    } else {
        size = [self.ResponsiblePersonName boundingRectWithSize:CGSizeMake(NameLabelWidth, 20) options:(NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: kFont_Light_14} context:NULL].size;
    }
    _responsiblePersonWidth = ceilf(size.width) ;
    return _responsiblePersonWidth;
}

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"CreateTime"]) {
        self.UpdateTime = value;
    }
    printf("%s, %c", __func__, __LINE__);
}

- (NSString *)answerString
{
    NSMutableArray *answerArray = [NSMutableArray array];
    [self.questionsList enumerateObjectsUsingBlock:^(Questions *obj, NSUInteger idx, BOOL *stop) {
        if (obj.quesStatus == QuestionStatusModified) {
            [answerArray addObject:obj.questionAnswer];
        }
    }];
    _answerString = [answerArray componentsJoinedByString:@","];
    return _answerString;
}

+ (AFHTTPRequestOperation *)requestAnswerPaperList:(DFFilterSet *)filter pageIndex:(NSInteger)pageIndex date:(NSString *)date completion:(void (^)(NSArray *, NSInteger, NSInteger, NSString *))block
{
    NSString *par = [NSString stringWithFormat:@"{\"FilterByTimeFlag\":%d,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"PageIndex\":%ld,\"PageSize\":10,\"ResponsiblePersonIDs\":[%@],\"CustomerID\":%ld,\"UpdateTime\":\"%@\",\"IsShowAll\":%d}", filter.timeFlag, filter.startTime, filter.endTime, (long)pageIndex, filter.personIDs, (long)filter.customerID, date, kMenu_Type];

    
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Paper/GetAnswerPaperList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSInteger pCount = [[data objectForKey:@"PageCount"] integerValue];
            NSInteger nCount = [[data objectForKey:@"RecordCount"] integerValue];
            if ([data objectForKey:@"PaperList"] != [NSNull null]) {
                NSArray *tmpArray = [data objectForKey:@"PaperList"];
                NSMutableArray *tmpNotes = [NSMutableArray array];
                [tmpArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [tmpNotes addObject:[[QuestionPaper alloc] initWithDictionary:obj]];
                }];
                
                block([tmpNotes copy], pCount, nCount, nil);
            } else {
                block(nil, pCount, nCount, nil);
            }
            
        } failure:^(NSInteger code, NSString *error) {
            block(nil, 0, 0, error);
        }];

    } failure:^(NSError *error) {
        
    }];
    
}

+ (AFHTTPRequestOperation *)requestPaperListCompletion:(void (^)(NSArray *array, NSString *mesg))block
{
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Paper/GetPaperList" andParameters:nil failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
        
                NSMutableArray *tmpNotes = [NSMutableArray array];
                [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [tmpNotes addObject:[[QuestionPaper alloc] initWithDictionary:obj]];
                }];
                
                block([tmpNotes copy], nil);

        } failure:^(NSInteger code, NSString *error) {
            block(nil,error);
        }];

    } failure:^(NSError *error) {
        
    }];
}

- (void)getQuestionsOfThePaperCompletion:(void (^)(NSArray *))block
{
    NSString *par = [NSString stringWithFormat:@"{\"PaperID\":%ld,\"GroupID\":%ld}", (long)self.PaperID, (long)self.GroupID];
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Paper/GetPaperDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json){
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSMutableArray *tmpArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tmpArray addObject:[[Questions alloc] initWithDictionary:obj]];
            }];
            self.questionsList = [tmpArray copy];
            
            block([tmpArray copy]);
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (AFHTTPRequestOperation *)requestAddAnswerOfPaperCompletion:(void (^)(NSInteger , NSString *))block
{
    NSInteger customerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
    NSString *par = [NSString stringWithFormat:@"{\"PaperID\":%ld,\"CustomerID\":%ld,\"IsVisible\":%d,\"AnswerList\":[%@],}", (long)self.PaperID, (long)customerID, self.IsVisible, self.answerString];
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Paper/AddAnswer" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            block(code, message);
        } failure:^(NSInteger code, NSString *error) {
            block(code, error);
        }];
    } failure:^(NSError *error) {
    }];
}

- (AFHTTPRequestOperation *)modifyTheQuestionOfThisPaper:(Questions *)question CompletionBlock:(void (^)(NSInteger, NSString *))block
{
    NSString *par = [NSString stringWithFormat:@"{\"QuestionID\":%ld,\"GroupID\":%ld,\"AnswerID\":%ld,\"AnswerContent\":\"%@\"}",(long)question.QuestionID, (long)self.GroupID, (long)question.AnswerID, (question.QuestionType == QuestionTextMode ? question.QuestionContent : question.choiceAnswer)];
    
  return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Paper/EditAnswer" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            block(code, message);
        } failure:^(NSInteger code, NSString *error) {
            block(code, error);
        }];
    } failure:^(NSError *error) {
        
    }];
    
}
@end
