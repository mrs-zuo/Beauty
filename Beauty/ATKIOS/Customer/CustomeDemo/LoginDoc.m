//
//  LoginDoc.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "LoginDoc.h"

@implementation LoginDoc

- (id)init
{
    self = [super init];
    if (self) {
        self.login_Discount = 1;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key rangeOfString:@"login_"].length <= 0)
        [self setValue:value forKey:[NSString stringWithFormat:@"login_%@",key]];
    else
        NSLog(@"%@",key);
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(_login_CustomerID) forKey:@"_login_CustomerID"];
    [aCoder encodeObject:@(_login_CompanyID) forKey:@"_login_CompanyID"];
    [aCoder encodeObject:@(_login_BranchID) forKey:@"_login_BranchID"];
    
    [aCoder encodeObject:@(_login_BranchCount) forKey:@"_login_BranchCount"];
    [aCoder encodeObject:@(_login_PromotionCount) forKey:@"_login_PromotionCount"];
    [aCoder encodeObject:@(_login_Discount) forKey:@"_login_Discount"];
    
    [aCoder encodeObject:_login_CurrencySymbol forKey:@"_login_CurrencySymbol"];
    [aCoder encodeObject:@(_login_RemindCount) forKey:@"_login_RemindCount"];
    [aCoder encodeObject:@(_login_UnpaidOrderCount) forKey:@"_login_UnpaidOrderCount"];
    [aCoder encodeObject:@(_login_UnconfirmedOrderCount) forKey:@"_login_UnconfirmedOrderCount"];
    [aCoder encodeObject:_login_CompanyCode forKey:@"_login_CompanyCode"];
    [aCoder encodeObject:_login_CompanyAbbreviation forKey:@"_login_CompanyAbbreviation"];

    [aCoder encodeObject:_login_CustomerName forKey:@"_login_CustomerName"];
    [aCoder encodeObject:_login_HeadImageURL forKey:@"_login_HeadImageURL"];
    [aCoder encodeObject:_login_Advanced forKey:@"_login_Advanced"];

    [aCoder encodeObject:@(_login_CompanyScale) forKey:@"_login_CompanyScale"];
    [aCoder encodeObject:_login_CurrencySymbol forKey:@"_login_CurrencySymbol"];
    
    [aCoder encodeObject:_login_CustomerName forKey:@"_login_CustomerName"];
    [aCoder encodeObject:_login_LevelName forKey:@"_login_LevelName"];
    [aCoder encodeObject:_login_CompanyName forKey:@"_login_CompanyName"];
    [aCoder encodeObject:_login_BranchName forKey:@"_login_BranchName"];
    [aCoder encodeObject:@(_login_LoginTime) forKey:@"_login_LoginTime"];
    [aCoder encodeObject:@(_login_NewMessageCount) forKey:@"_login_NewMessageCount"];



}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _login_CustomerID = [[aDecoder decodePropertyListForKey:@"_login_CustomerID"] integerValue];
        _login_CompanyID = [[aDecoder decodePropertyListForKey:@"_login_CompanyID"] integerValue];
        _login_BranchID = [[aDecoder decodePropertyListForKey:@"_login_BranchID"] integerValue];
        _login_BranchCount = [[aDecoder decodePropertyListForKey:@"_login_BranchCount"] integerValue];
        _login_PromotionCount = [[aDecoder decodePropertyListForKey:@"_login_Discount"] integerValue];
        _login_Discount = [[aDecoder decodePropertyListForKey:@"_login_Discount"] integerValue];
        _login_CurrencySymbol = [aDecoder decodePropertyListForKey:@"_login_CurrencySymbol"];
        _login_RemindCount = [[aDecoder decodePropertyListForKey:@"_login_RemindCount"] integerValue];
        _login_UnpaidOrderCount = [[aDecoder decodePropertyListForKey:@"_login_UnpaidOrderCount"] integerValue];
        _login_UnconfirmedOrderCount = [[aDecoder decodePropertyListForKey:@"_login_UnconfirmedOrderCount"] integerValue];
        _login_CompanyCode = [aDecoder decodePropertyListForKey:@"_login_CompanyCode"] ;
        _login_CompanyAbbreviation = [aDecoder decodePropertyListForKey:@"_login_CompanyAbbreviation"] ;
        _login_CustomerName = [aDecoder decodePropertyListForKey:@"_login_CustomerName"] ;
        _login_HeadImageURL = [aDecoder decodePropertyListForKey:@"_login_HeadImageURL"] ;
        _login_Advanced = [aDecoder decodePropertyListForKey:@"_login_Advanced"] ;
        _login_CurrencySymbol = [aDecoder decodePropertyListForKey:@"_login_CurrencySymbol"] ;
        _login_CompanyScale = [[aDecoder decodePropertyListForKey:@"_login_CompanyScale"] integerValue];
        
        _login_LoginTime = [[aDecoder decodePropertyListForKey:@"_login_LoginTime"] integerValue];
        _login_NewMessageCount = [[aDecoder decodePropertyListForKey:@"_login_NewMessageCount"] integerValue];

        _login_CustomerName = [aDecoder decodePropertyListForKey:@"_login_CustomerName"] ;
        _login_LevelName = [aDecoder decodePropertyListForKey:@"_login_LevelName"] ;
        _login_CompanyName = [aDecoder decodePropertyListForKey:@"_login_CompanyName"] ;
        _login_BranchName = [aDecoder decodePropertyListForKey:@"_login_BranchName"] ;

        
    }
    return self;
}



@end
