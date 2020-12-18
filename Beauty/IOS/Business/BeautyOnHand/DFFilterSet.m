//
//  DFFilterSet.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DFFilterSet.h"
#import "Tags.h"
#import "UserDoc.h"

@implementation DFFilterSet
@synthesize personName = _personName;

- (id)init
{
    self = [super init];
    if (self) {
        _timeFlag = 0;
        _tagIDs = [[NSString alloc] init];
        _startTime = [[NSString alloc] init];
        _personName = [[NSString alloc] init];
        _customerName = [[NSString alloc] init];
        _endTime = [[NSString alloc] init];
        _tagsArray = [NSMutableArray array];
        _oppType = OpportunityAll;
        _oppName = [[NSString alloc] init];
        _personsArray = [NSMutableArray array];
    }
    return self;
}

- (NSString *)oppName {
    switch (_oppType) {
        case OpportunityAll:
            _oppName = @"全部";
            break;
        case OpportunityService:
            _oppName = @"服务";
            break;
        case OpportunityCommodity:
            _oppName = @"商品";
            break;
    }
    return _oppName;
}
//- (int)timeFlag
//{
//    if ([_endTime isEqualToString:@""] || [_startTime isEqualToString:@""]) {
//        return 0;
//    } else {
//        return 1;
//    }
//}
- (NSMutableArray *)personsArray {
    if (kMenu_Type == 0) {
        if (_personsArray.count == 0) {
            UserDoc *user = [[UserDoc alloc] init];
            user.user_Name = ACC_ACCOUNTName;
            user.user_Id = ACC_ACCOUNTID;
            [_personsArray addObject:user];
        }
    }
    return _personsArray;
}

- (NSString *)personName
{
    NSArray *nameArray = [self.personsArray valueForKeyPath:@"@unionOfObjects.user_Name"];
    return [nameArray componentsJoinedByString:@"、"];
}

- (NSString *)personIDs
{
    _personIDs = @"";
    NSArray *idArray = [self.personsArray valueForKeyPath:@"@unionOfObjects.user_Id"];
    if (idArray.count) {
        _personIDs = [idArray componentsJoinedByString:@","];
    }
    return _personIDs;
}

- (NSString*)tagString
{
/*
    NSArray *ar = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 length]> [obj2 length]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if ([obj1 length]< [obj2 length])
            return (NSComparisonResult)NSOrderedAscending;
        else
            return (NSComparisonResult)NSOrderedSame;
    }];
 
 */
    NSMutableArray *tmpTags = [NSMutableArray array];
    
    if ([_tagsArray count]) {
        for (Tags *ta in _tagsArray) {
            [tmpTags addObject:ta.Name];
        }
    }
    
    NSString *str = [tmpTags componentsJoinedByString:@"、"];
    NSLog(@"the str is %@", str);
    return [[tmpTags componentsJoinedByString:@"、"] copy];
    
}

- (NSMutableString*)tagIDs
{
    if (!_tagIDs) {
        _tagIDs = [NSMutableString string];
    }
    NSMutableString *tmpTags = [NSMutableString string];
    if ([_tagsArray count]) {
        for (Tags *ta in _tagsArray) {
            [tmpTags appendFormat:@"|%ld",(long)ta.tagID];
        }
        [tmpTags appendString:@"|"];
    }
    return [tmpTags copy];
}




- (BOOL)saveFilterDocInPath:(NSString *)path
{
    BOOL succ = [NSKeyedArchiver archiveRootObject:self toFile:path];
    return succ;
}

+ (instancetype)getFilterDocWithPath:(NSString *)path
{
    NSFileManager *fileMan = [NSFileManager defaultManager];

    if ([fileMan fileExistsAtPath:path]) {
        DFFilterSet *set = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return set;
    } else {
        return [[self alloc] init];
    }
    
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    DFFilterSet *tmpSet = [[[self class] allocWithZone:zone] init];
    
    return tmpSet;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:_timeFlag forKey:@"timeFlag"];
    [aCoder encodeInteger:_oppType forKey:@"oppType"];
    [aCoder encodeObject:_startTime forKey:@"startTime"];
    [aCoder encodeObject:_endTime forKey:@"endTime"];
//    [aCoder encodeObject:self.personName forKey:@"personName"];
//    [aCoder encodeObject:self.personIDs forKey:@"personIDs"];
//    [aCoder encodeInteger:_personID forKey:@"personID"];
    [aCoder encodeObject:self.personsArray forKey:@"personsArray"];
    [aCoder encodeObject:_customerName forKey:@"customerName"];
    [aCoder encodeInteger:_customerID forKey:@"customerID"];
    [aCoder encodeObject:_tagsArray forKey:@"tagsArray"];

}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self == nil ) {
        return nil;
    }
    self.timeFlag = [aDecoder decodeIntForKey:@"timeFlag"];
    self.startTime = [aDecoder decodeObjectForKey:@"startTime"];
    self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
    
    self.oppType = [aDecoder decodeIntegerForKey:@"oppType"];
//    self.personID = [aDecoder decodeIntegerForKey:@"personID"];
//    self.personIDs = [aDecoder decodeObjectForKey:@"personIDs"];
//    self.personName = [aDecoder decodeObjectForKey:@"personName"];
    self.customerID = [aDecoder decodeIntegerForKey:@"customerID"];
    self.customerName = [aDecoder decodeObjectForKey:@"customerName"];
    self.tagsArray = [aDecoder decodeObjectForKey:@"tagsArray"];
    self.personsArray = [aDecoder decodeObjectForKey:@"personsArray"];
    return self;
}


@end
