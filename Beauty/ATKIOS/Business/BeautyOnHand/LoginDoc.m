//
//  LoginDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-10-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "LoginDoc.h"

@implementation BranchDoc

@end

@implementation LoginDoc

- (void)loginParameterUserConfig {

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.accountId] forKey:@"ACCOUNT_USERID"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.companyId] forKey:@"ACCOUNT_COMPANTID"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.branchID]  forKey:@"ACCOUNT_BRANCHID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.companyCode forKey:@"ACCOUNT_COMPANTCODE"];
    [[NSUserDefaults standardUserDefaults] setObject:self.userName forKey:@"ACCOUNT_NAME"];
    [[NSUserDefaults standardUserDefaults] setObject:self.headImg forKey:@"ACCOUNT_HEADIMAGE"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.companyScale] forKey:@"ACCOUNT_COMPANTSCALE"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"SettlementCurrency"];
    [[NSUserDefaults standardUserDefaults] setObject:(self.moneyIcon ? self.moneyIcon : @"¥") forKey:@"ACCOUNT_CURRENCY_ICON"];
    [[NSUserDefaults standardUserDefaults] setObject:self.companyAbbreviation forKey:@"ACCOUNT_COMPANYABBREVIATION"];

}
@end
