//
//  DFFilterSet.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, OpportunityType){
    OpportunityAll = -1,
    OpportunityService = 0,
    OpportunityCommodity = 1
};

@interface DFFilterSet : NSObject<NSCoding, NSCopying>
@property (nonatomic, assign) int   timeFlag;
@property (nonatomic, assign) OpportunityType   oppType;
@property (nonatomic, copy) NSString *oppName;

@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *personName;
@property (nonatomic, assign) NSInteger personID;
@property (nonatomic, copy) NSString *customerName;
@property (nonatomic, assign) NSInteger customerID;

@property (nonatomic, strong) NSMutableArray *personsArray;
@property (nonatomic, copy) NSString *personIDs;
@property (nonatomic, strong) NSMutableArray *tagsArray;
@property (nonatomic, copy) NSString *tagString;
@property (nonatomic, copy) NSString *tagIDs;


- (BOOL) saveFilterDocInPath:(NSString *)path;

+ (instancetype)getFilterDocWithPath:(NSString *)path;

@end
