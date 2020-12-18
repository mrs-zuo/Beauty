//
//  FirstPageFilter.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/21.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, FilterOrderType) {
    FilterOrderAll = 1,
    FilterOrderOne = 2,
    FilterOrderTwo = 3,
//    FilterOrderThree = 3
};
@interface FirstPageFilter : NSObject
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) NSInteger accountID;
@property (nonatomic, assign) FilterOrderType type;
@property (nonatomic, strong) NSString *Status;

@property (nonatomic, strong) NSPredicate *filterPred;
@end
