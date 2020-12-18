//
//  Tag.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-13.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tags : NSObject<NSCoding, NSCopying>
@property (nonatomic, assign) NSInteger tagID;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, assign) BOOL  isChoose;
- (id)initWithDictionary:(NSDictionary *)dictionary;



@end
