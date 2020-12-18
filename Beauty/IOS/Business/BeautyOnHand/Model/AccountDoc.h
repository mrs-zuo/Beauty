//
//  AccountDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//  

#import <Foundation/Foundation.h>

@interface AccountDoc : NSObject

@property (assign, nonatomic) NSInteger cos_CompanyID;
@property (assign, nonatomic) NSInteger cos_UserID;
@property (copy, nonatomic) NSString *cos_Name;
@property (copy, nonatomic) NSString *cos_Title;
@property (copy, nonatomic) NSString *cos_Department;
@property (copy, nonatomic) NSString *cos_Available;  //帐户是否激活
@property (copy, nonatomic) NSString *cos_HeadImgURL;
@property (copy, nonatomic) NSString *cos_Expert;
@property (copy, nonatomic) NSString *cos_Introduction;
@property (copy, nonatomic) NSString *cos_Mobile;

// 图片
@property (strong, nonatomic) UIImage *cos_HeadImg;
@property (copy, nonatomic)  NSString *cos_ImgType;

@property (assign, nonatomic, readonly) CGFloat expert_Height;
@property (assign, nonatomic, readonly) CGFloat instro_Height;

@property (strong, nonatomic) NSString *aaa;
@property (copy, nonatomic)   NSString *bbb;


@end
