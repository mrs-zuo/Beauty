//
//  SalonDoc.h
//  CustomeDemo
//
//  Created by macmini on 13-7-5.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanyDoc : NSObject

@property (assign,nonatomic) NSInteger company_ID;
@property (assign,nonatomic) NSInteger company_BranchID;
@property (assign,nonatomic) NSInteger company_ImageCount;
@property (assign,nonatomic) NSInteger company_AccountCount;   //该店员工数量
@property (copy,nonatomic) NSString *company_Name;
@property (copy,nonatomic) NSString *company_BranchName;
@property (copy,nonatomic) NSString *company_Summary;
@property (copy,nonatomic) NSString *company_Contact;
@property (copy,nonatomic) NSString *company_Phone;
@property (copy,nonatomic) NSString *company_Fax;
@property (copy,nonatomic) NSString *company_Web;
@property (copy,nonatomic) NSString *company_Address;
@property (copy,nonatomic) NSString *company_Zip;
@property (copy,nonatomic) NSString *company_BusinessHours;
@property (copy,nonatomic) NSString *Distance;



@property (assign,nonatomic) NSInteger tag;//标记符 0：公司   1：分支机构

@property (nonatomic, assign) CGFloat company_Longitude;
@property (nonatomic, assign) CGFloat company_Latitude;

@end
