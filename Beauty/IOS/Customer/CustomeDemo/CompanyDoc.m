//
//  SalonDoc.m
//  CustomeDemo
//
//  Created by macmini on 13-7-5.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "CompanyDoc.h"

@implementation CompanyDoc
@synthesize company_ID = companyId;
@synthesize company_BranchID = companyBranchId;
@synthesize company_Name = companyName;
@synthesize company_BranchName = companyBranchName;
@synthesize company_Summary = companyRemark;
@synthesize company_Contact = companyContact;
@synthesize company_Phone = companyPhone;
@synthesize company_Fax = companyFax;
@synthesize company_Web = companyWeb;
@synthesize company_Address = companyAddr;
@synthesize company_Zip = companyZip;
@synthesize company_BusinessHours = companyHours;
@synthesize tag = tag;

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{ 
    if ([key rangeOfString:@"company_"].length <= 0)
        [self setValue:value forKey:[NSString stringWithFormat:@"company_%@",key]];
    else
        NSLog(@"%@",key);
}

@end
