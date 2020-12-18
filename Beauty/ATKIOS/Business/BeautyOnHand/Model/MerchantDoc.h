//
//  MerchantDoc.h
//  merNew
//
//  Created by MAC_Lion on 13-7-23.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MerchantDoc : NSObject

@property (assign, nonatomic) NSInteger mer_ID;
@property (copy, nonatomic) NSString *mer_Name;  //*
@property (copy, nonatomic) NSString *mer_Intro; //*
@property (copy, nonatomic) NSString *mer_Linkman;  //*
@property (copy, nonatomic) NSString *mer_Phone;
@property (copy, nonatomic) NSString *mer_Fax;
@property (copy, nonatomic) NSString *mer_Postcode;
@property (copy, nonatomic) NSString *mer_Address;
@property (copy, nonatomic) NSString *mer_Url;

@end
