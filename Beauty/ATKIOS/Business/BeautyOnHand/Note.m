//
//  Note.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-10.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "Note.h"
#import "GPHTTPClient.h"
#import "DFFilterSet.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"

@implementation Note



- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqual:@"ID"]) {
        self.noteID = [value integerValue];
    }
    NSLog(@"the UndefinedKey is %@", key);
}

- (NSString*)TagName
{
    NSArray *array = [_TagName componentsSeparatedByString:@"|"];
    NSArray *ar = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 length]> [obj2 length]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if ([obj1 length]< [obj2 length])
            return (NSComparisonResult)NSOrderedAscending;
        else
            return (NSComparisonResult)NSOrderedSame;
    }];
//    for (NSString *str in ar) {
//        [string appendString:[NSString stringWithFormat:@"%@、",str]];
//    }
    NSString *result  = [ar componentsJoinedByString:@"、"];

    return result;
    
}

- (NSString *)CreateTime
{
    NSString *result = [[_CreateTime substringToIndex:16] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    return result;
}


- (CGFloat)height
{
    CGSize sizeToFit;
    CGRect contentFrame;
    
    sizeToFit = [_Content sizeWithFont:kFont_Light_15 constrainedToSize:CGSizeMake(290, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

    if (sizeToFit.height < 52.0) {
        _height = fmaxf(sizeToFit.height + 10, 38);
    } else {
        if (_showContent) {
            contentFrame.size.height = sizeToFit.height;
        } else {
            contentFrame.size.height = 50;
        }
        _height = (_showContent ? sizeToFit.height + 25 : 75);
    }
    return _height;
}


+ (AFHTTPRequestOperation *)requestFilter:(DFFilterSet *)filter NoteID:(NSInteger)noteID PageIndex:(NSInteger)pagIndex andPageSize:(NSInteger)pagSize completionBlock:(void (^)(NSArray *array, NSInteger pagCount, NSInteger notCount, NSString *mesg))block
{
    NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"RecordID\":%ld,\"FilterByTimeFlag\":%d,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"PageIndex\":%ld,\"PageSize\":%ld,\"TagIDs\":\"%@\",\"ResponsiblePersonIDs\":[%@],\"CustomerID\":%ld,\"IsShowAll\":%d}", (long)ACC_ACCOUNTID, (long)noteID, filter.timeFlag, filter.startTime, filter.endTime, (long)pagIndex, (long)pagSize, filter.tagIDs, filter.personIDs, (long)filter.customerID, kMenu_Type];
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Notepad/GetNotepadList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSInteger pCount = [[data objectForKey:@"PageCount"] integerValue];
            NSInteger nCount = [[data objectForKey:@"RecordCount"] integerValue];
            if ([data objectForKey:@"NotepadList"] != [NSNull null]) {
                NSArray *tmpArray = [data objectForKey:@"NotepadList"];
                NSMutableArray *tmpNotes = [NSMutableArray array];
                [tmpArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [tmpNotes addObject:[[Note alloc] initWithDictionary:obj]];
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
    
    
    
    
    
    
    
    
    return  [[GPHTTPClient shareClient] requestNoteListAccountID:filter NoteID:noteID PageIndex:pagIndex andPageSize:pagSize success:^(id xml) {
        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data, id message) {
            if ([data objectForKey:@"PageCount"] != [NSNull null] && [data objectForKey:@"RecordCount"] != [NSNull null]) {
                NSInteger pCount = [[data objectForKey:@"PageCount"] integerValue];
                NSInteger nCount = [[data objectForKey:@"RecordCount"] integerValue];
                if ([data objectForKey:@"NotepadList"] != [NSNull null]) {
                    NSArray *tmpArray = [data objectForKey:@"NotepadList"];
                    NSMutableArray *tmpNotes = [NSMutableArray array];
                    [tmpArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [tmpNotes addObject:[[Note alloc] initWithDictionary:obj]];
                    }];
                    
                    block([tmpNotes copy], pCount, nCount, nil);
                } else {
                    block(nil, pCount, nCount, nil);
                }
            } else {
                block(nil, 0, 0, nil);
            }
        } failure:^(NSString *error) {
            block(nil, 0, 0, error);
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus2:error.localizedDescription touchEventHandle:^{}];
    }];
}


@end
