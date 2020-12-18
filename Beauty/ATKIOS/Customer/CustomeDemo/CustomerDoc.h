//
//  CustomerDoc.h
//  Customers
//
//  Created by ace-009 on 13-4-23.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Woman = 0,
    Man
} Gender;

typedef enum {
    Unmarried = 0,
    Married
} Marriage;

@interface CustomerDoc : NSObject
@property (assign, nonatomic) NSInteger cus_ID;
@property (copy, nonatomic) NSString *cus_Name;  //*
@property (copy, nonatomic) NSString *cus_Title; //*
@property (copy, nonatomic) NSString *cus_Mobile;  //*
@property (copy, nonatomic) NSString *cus_Email;
@property (copy, nonatomic) NSString *cus_Weixin;
@property (copy, nonatomic) NSString *cus_Phone;
@property (copy, nonatomic) NSString *cus_Address;
@property (copy, nonatomic) NSString *cus_Zip;
@property (copy, nonatomic) NSString *cus_Remark;
@property (copy, nonatomic) NSString *cus_BloodType;
@property (copy, nonatomic) NSString *cus_BirthDay;
@property (copy, nonatomic) NSString *cus_VisitDate;
@property (assign, nonatomic) CGFloat cus_Height;
@property (assign, nonatomic) CGFloat cus_Weight;
@property (assign, nonatomic) Gender cus_Gender;
@property (assign, nonatomic) Marriage cus_Marriage;
@property (assign, nonatomic) NSInteger cus_ProgressRate;
@property (copy, nonatomic) NSString *cus_HeadImgURL;
//
//@property (strong, nonatomic) NSMutableArray *cus_RecordDocArray; // 客户的记录数组
//@property (strong, nonatomic) NSMutableArray *cus_OrderDocArray;  // 客户的订单数组
//
//
//- (id)initWithNewFlag:(BOOL)NewFlag Name:(NSString*)Name Phone:(NSString*)Phone Address:(NSString*)Address Email:(NSString*)Email Weixin:(NSString*)Weixin VisitDate:(NSString*)VisitDate Remarks:(NSString*)Remarks thumbImage:(UIImage *)thumbImage fullImage:(UIImage *)fullImage;

@end
