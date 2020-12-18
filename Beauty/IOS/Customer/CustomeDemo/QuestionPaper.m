//
//  QuestionPaper.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "QuestionPaper.h"
#import "Questions.h"
#import "GPCHTTPClient.h"
#import "AppDelegate.h"

#define TitleLabelWidth     260.0
#define NameLabelWidth      60.0

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
    _attriTitle = [[NSAttributedString alloc] initWithString:_Title attributes:attributedDic];
    return _attriTitle;
}

- (CGFloat)responsiblePersonWidth
{
    CGSize size;
    if (IOS6) {
        size = [self.ResponsiblePersonName sizeWithFont:kFont_Light_14 constrainedToSize:CGSizeMake(NameLabelWidth, 20) lineBreakMode:NSLineBreakByTruncatingTail];
    } else {
        size = [self.ResponsiblePersonName boundingRectWithSize:CGSizeMake(NameLabelWidth, 20) options:(NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: kFont_Light_14} context:NULL].size;
    }
    _responsiblePersonWidth = ceilf(size.width);
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

+ (AFHTTPRequestOperation *)requestAnswerPaperListCompletion:(void (^)(NSArray *, NSString *))block
{
    
    NSString *par = [NSString stringWithFormat:@"{\"FilterByTimeFlag\":0,\"StartTime\":\"\",\"EndTime\":\"\",\"PageIndex\":1,\"PageSize\":9999,\"ResponsiblePersonID\":0,\"CustomerID\":0,\"UpdateTime\":\"\"}"];
    
    return [[GPCHTTPClient sharedClient] requestUrlPath:@"/Paper/GetAnswerPaperList" showErrorMsg:YES parameters:par WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if ([data objectForKey:@"PaperList"] != [NSNull null]) {
                NSArray *tmpArray = [data objectForKey:@"PaperList"];
                NSMutableArray *tmpNotes = [NSMutableArray array];
                [tmpArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [tmpNotes addObject:[[QuestionPaper alloc] initWithDictionary:obj]];
                }];
                block([tmpNotes copy], nil);
            } else {
                block(nil, nil);
            }
        } failure:^(NSInteger code, NSString *error) {
                block(nil, error);
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)getQuestionsOfThePaperCompletion:(void (^)(NSArray *))block
{
    NSString *par = [NSString stringWithFormat:@"{\"PaperID\":%ld,\"GroupID\":%ld}", (long)self.PaperID, (long)self.GroupID];
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/Paper/GetPaperDetail" showErrorMsg:YES parameters:par WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
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


@end
