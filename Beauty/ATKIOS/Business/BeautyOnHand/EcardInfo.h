//
//  EcardInfo.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-12-1.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcardInfo : NSObject


//@property (nonatomic, strong) NSString *DiscountName;
@property (nonatomic, assign) CGFloat   Discount;
//
//@property (nonatomic, strong) NSString *LevelName;
//@property (nonatomic, assign) NSInteger LevelID;


@property (nonatomic)           BOOL    IsDefault;

@property (nonatomic, strong) NSString *CardName;
@property (nonatomic, assign) NSInteger CardID;
@property (nonatomic, assign) NSInteger CardCode;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
