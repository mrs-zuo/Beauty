//
//  SalonDoc.m
//  CustomeDemo
//
//  Created by macmini on 13-7-5.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "CompanyDoc.h"

@implementation CompanyDoc
//@synthesize company_ID = companyId;
//@synthesize company_BranchID = companyBranchId;
//@synthesize company_Name = companyName;
//@synthesize company_BranchName = companyBranchName;
//@synthesize company_Remark = companyRemark;
//@synthesize company_Contact = companyContact;
//@synthesize company_Phone = companyPhone;
//@synthesize company_Fax = companyFax;
//@synthesize company_Web = companyWeb;
//@synthesize company_Addr = companyAddr;
//@synthesize company_Zip = companyZip;
//@synthesize company_Hours = companyHours;
//@synthesize tag = tag;
//@synthesize company_BranchID;
//@synthesize Name;


- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    //    [record ]
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"the UndefinedKey is %@", key);
}

@end
