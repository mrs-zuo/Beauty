//
//  AccountDoc.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-2.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountDoc : NSObject

@property(assign, nonatomic) NSInteger acc_ID;          //服务人员ID
@property(copy  , nonatomic) NSString *acc_Code;        //服务人员code

@property(assign, nonatomic) NSInteger acc_companyId;   //服务人员所属公司ID
@property(copy  , nonatomic) NSString *acc_companyName; //服务人员所属公司名称
@property(copy  , nonatomic) NSString *acc_Branch;      //服务人员所属分支机构名称

@property(assign, nonatomic) NSInteger acc_Available;   //服务人员可用状态
@property(assign, nonatomic) NSInteger acc_Chat_Use;    //服务人员飞语权限
@property(copy  , nonatomic) NSString *acc_Name;        //服务人员姓名
@property(copy  , nonatomic) NSString *acc_PinYin;      //服务人员姓名拼音
@property(copy  , nonatomic) NSString *acc_PinYinFirst; //服务人员姓名缩写
@property(copy  , nonatomic) NSString *acc_Department;  //服务人员部门
@property(copy  , nonatomic) NSString *acc_Title;       //服务人员职称
@property(copy  , nonatomic) NSString *acc_Expert;      //服务人员擅长
@property(copy  , nonatomic) NSString *acc_Introduction;//服务人员简介
@property(copy  , nonatomic) NSString *acc_Mobile;      //服务人员联系电话
@property(copy  , nonatomic) NSString *acc_Email;       //服务人员邮箱
@property(copy  , nonatomic) NSString *acc_Weixin;      //服务人员微信
@property(copy  , nonatomic) NSString *acc_Phone;       //服务人员电话
@property(copy  , nonatomic) NSString *acc_Fax;         //服务人员传真
@property(copy  , nonatomic) NSString *acc_Address;     //服务人员地址
@property(copy  , nonatomic) NSString *acc_Zip;         //服务人员邮编
@property(copy  , nonatomic) NSString *acc_HeadImgURL;  //服务人员头像地址

@property(copy  , nonatomic) NSString *acc_Question;    //？
@property(copy  , nonatomic) NSString *acc_Answer;      //？

@end
