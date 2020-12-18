//
//  BusinessInfoModel.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/6.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessInfoModel : NSObject
@property(nonatomic,copy) NSString * Abbreviation ;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *Summary;
@property (nonatomic, copy) NSString *Contact;
@property (nonatomic, copy) NSString *Phone;
@property (nonatomic, copy) NSString *Fax;
@property (nonatomic, copy) NSString *Address;
@property (nonatomic, copy) NSString *Zip;
@property (nonatomic, copy) NSString *Web;
@property (nonatomic, copy) NSString *BusinessHours;
@property (nonatomic, assign) NSInteger ImageCount;
@property (nonatomic, copy) NSArray *ImageURL;
@property (nonatomic, assign) CGFloat Longitude;
@property (nonatomic, assign) CGFloat Latitude;
@property (nonatomic, assign) NSInteger AccountCount;
@property (nonatomic, assign) CGFloat summaryHeight;
@property (nonatomic, assign) BOOL  isMapView;
- (instancetype)initWithDic:(NSDictionary *)dic;

- (NSArray *)businessInfoHandle;

- (NSArray *)shopBusinessInfoHandle;
@end
