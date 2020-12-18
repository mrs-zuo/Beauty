//
//  UserDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-10-18.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "UserDoc.h"

@implementation UserDoc
-(instancetype)init
{
    if (self = [super init]) {
        self.user_ProfitPct = @"0";
        self.user_commissionRate=@"0";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_user_Id forKey:@"user_Id"];
    [aCoder encodeObject:_user_Name forKey:@"user_Name"];
    [aCoder encodeObject:_user_ProfitPct forKey:@"user_ProfitPct"];
    [aCoder encodeObject:_user_commissionRate forKey:@"user_commissionRate"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return self;
    }
    self.user_Id = [aDecoder decodeIntegerForKey:@"user_Id"];
    self.user_Name = [aDecoder decodeObjectForKey:@"user_Name"];
    self.user_ProfitPct = [aDecoder decodeObjectForKey:@"user_ProfitPct"];
    self.user_commissionRate = [aDecoder decodeObjectForKey:@"user_commissionRate"];
    
    return self;
    
}

- (NSComparisonResult)compareUserSelectedState:(UserDoc *)user
{
    if (self.user_SelectedState) {
        if (user.user_SelectedState) {
            return NSOrderedSame;
        } else {
            return NSOrderedAscending;
        }
    } else {
        if (user.user_SelectedState) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }
}


@end

