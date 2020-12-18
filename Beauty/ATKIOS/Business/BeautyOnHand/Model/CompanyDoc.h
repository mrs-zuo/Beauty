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
@property (assign,nonatomic) NSInteger BranchID;
@property (assign,nonatomic) NSInteger ImageCount;
@property (assign,nonatomic) NSInteger AccountCount;   //该店员工数量
@property (copy,nonatomic) NSString *Name;
@property (copy,nonatomic) NSString *BranchName;
@property (copy,nonatomic) NSString *Summary;
@property (copy,nonatomic) NSString *Contact;
@property (copy,nonatomic) NSString *Phone;
@property (copy,nonatomic) NSString *Fax;
@property (copy,nonatomic) NSString *Web;
@property (copy,nonatomic) NSString *Address;
@property (copy,nonatomic) NSString *Zip;
@property (copy,nonatomic) NSString *BusinessHours;
@property (nonatomic, strong) NSArray *ImageURL;
@property (assign,nonatomic) NSInteger tag;//标记符 0：公司   1：分支机构

@property (nonatomic, assign) CGFloat Longitude;
@property (nonatomic, assign) CGFloat Latitude;


- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end
