//
//  Note.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-10.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperation;
@class DFFilterSet;
@interface Note : NSObject
@property (nonatomic, assign) NSInteger noteID;
@property (nonatomic, strong) NSString *CreateTime;
@property (nonatomic, strong) NSString *CreatorName;
@property (nonatomic, strong) NSString *CustomerName;
@property (nonatomic, strong) NSString *Content;
@property (nonatomic, assign) BOOL showContent;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSString *TagName;
@property (nonatomic, strong) NSString *TagIDs;


- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (AFHTTPRequestOperation *)requestFilter:(DFFilterSet *)filter NoteID:(NSInteger)noteID PageIndex:(NSInteger)pagIndex andPageSize:(NSInteger)pagSize completionBlock:(void(^)(NSArray *array, NSInteger pagCount, NSInteger notCount, NSString *mesg))block;
@end
