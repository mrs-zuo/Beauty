//
//  CustomerDoc.h
//  Customers
//
//  Created by ZhongHe on 13-4-23.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Gender) {
    GNotExist = -1,
    Woman,
    Man
};

typedef NS_ENUM(NSInteger, Marriage) {
    MNotExist = -1,
    Unmarried,
    Married
} ;

typedef NS_OPTIONS(NSInteger, CustomerEditStatus) {
    CustomerEditStatusNone      = 0,
    CustomerEditStatusBasic     = 1 << 0, //专属顾问 或者 3个权限都有
    CustomerEditStatusContacts  = 1 << 1, // 非专属顾问 有No.4权限 可编辑基本信息 个人信息 笔记信息
    CustomerEditStatusPro       = 1 << 2, //非专属顾问 有No.4权限 可查看编辑联系信息
      //非专属顾问 有No.4权限 可查看编辑专业记录CustomerEditStatusAll
};
typedef NS_ENUM(NSInteger, CustomerRefreshType) {
    CustomerRefreshTypeNone,
    CustomerRefreshTypeInfo,
    CustomerRefreshTypeAll
};
@class PhoneDoc;
@interface CustomerDoc : NSObject

// -- basic info
@property (assign, nonatomic)NSInteger cus_ID;
@property (copy, nonatomic) NSString *cus_Name;
@property (copy, nonatomic) NSString *cus_ShortPinYin;
@property (copy, nonatomic) NSString *cus_QuanPinYin;
@property (nonatomic, copy) NSString *cus_FirstWord;
@property (nonatomic ,assign)NSInteger  cus_gender; //0 nv  1 nan

@property (nonatomic, assign) CustomerEditStatus editStatus;
@property (nonatomic, assign) BOOL isMyPerson;

@property (nonatomic, assign) CustomerRefreshType refreshType;

@property (copy, nonatomic) NSString *cus_Title;
@property (copy, nonatomic) NSString *cus_Remark;
@property (copy, nonatomic) NSString *cus_Profession;
@property (copy, nonatomic) NSString *cus_BloodType;
@property (copy, nonatomic) NSString *cus_BirthDay;
@property (copy, nonatomic) NSString *cus_VisitDate;
@property (assign, nonatomic) CGFloat cus_Height;
@property (assign, nonatomic) CGFloat cus_Weight;
@property (assign, nonatomic) Gender cus_Gender;
@property (assign, nonatomic) Marriage cus_Marriage;
@property (assign, nonatomic) NSInteger cus_ProgressRate;

@property (nonatomic,assign) NSInteger cus_Level;
@property (nonatomic,strong) NSString *cus_LevelName;
//顾客来源
@property (nonatomic,assign) NSInteger cus_sourceType;
@property (nonatomic,strong) NSString *cus_sourceTypeName;
// -- about membership info
@property (assign, nonatomic) long double cus_Discount;
@property (assign, nonatomic) long double cus_Balance;
@property (assign, nonatomic) NSInteger cus_ResponsiblePersonID;
@property (copy, nonatomic) NSString *cus_ResponsiblePersonName;

//GPB-2632 顾客增加销售顾问及是否是导入顾客
@property (nonatomic, assign) NSInteger cus_SalesID;
@property (nonatomic, strong) NSString *cus_SalesName;
@property (nonatomic, assign) BOOL  isImport;
///顾客资料里的顾客转入
//@property (assign, nonatomic) NSInteger  cus_RegistFrom;

@property (nonatomic,copy) NSString *cus_RegistFrom;

@property (copy, nonatomic) NSString *cus_LoginMobile;
//顾客是否上门标识
@property (copy, nonatomic) NSString *cus_ComeTime;
/**
 *顾客预约数
 */
@property (nonatomic, assign) NSInteger cus_appointCount;

/**
 *顾客结账数
 */
@property (nonatomic, assign) NSInteger cus_checkoutCount;
@property (nonatomic, strong) NSString *cus_LoginStarMob;
@property (nonatomic, strong) PhoneDoc *cus_LoginMobileDoc;
// GPB925  add OriginalLoginMobile
@property (copy, nonatomic) NSString *cus_OriginalLoginMobile;

// 图片
@property (strong, nonatomic) UIImage *cus_HeadImg;
@property (copy, nonatomic) NSString *cus_HeadImgURL;
@property (copy, nonatomic) NSString *cus_ImgType;

// -- others
@property (strong, nonatomic) NSMutableArray *cus_oldAnswer;
@property (strong, nonatomic) NSMutableArray *cus_Answers;
@property (copy, nonatomic) NSString *cus_AnswerSend;  //用户答案，以xml形式排列，以便发送

@property (copy, nonatomic) NSString *cus_PhoneSend;    //用户电话，以xml形式排列，以便发送
@property (copy, nonatomic) NSString *cus_EmailSend;    //用户邮件，以xml形式排列，以便发送
@property (copy, nonatomic) NSString *cus_AddressSend;  //用户地址，以xml形式排列，以便发送

@property (strong, nonatomic) NSMutableArray *cus_PhoneArray;
@property (strong, nonatomic) NSMutableArray *cus_EmailArray;
@property (strong, nonatomic) NSMutableArray *cus_AdrsArray;

@property (copy, nonatomic) NSString *cus_PhoneIds;  // 多个电话修改标识拼接字符串 以“,”拼接
@property (copy, nonatomic) NSString *cus_EmailIds;   // 多个邮件修改标识拼接字符串 以“,”拼接
@property (copy, nonatomic) NSString *cus_AdrsIds;    // 多个地址修改标识拼接字符串 以“,”拼接

@property (copy, nonatomic) NSString *cus_PhoneKeys;  // 多个电话名称拼接字符串 以“,”拼接
@property (copy, nonatomic) NSString *cus_EmailKeys;   // 多个邮件名称拼接字符串 以“,”拼接
@property (copy, nonatomic) NSString *cus_AdrsKeys;    // 多个地址名称拼接字符串 以“,”拼接

@property (copy, nonatomic) NSString *cus_Phones;  // 多个电话拼接字符串 以“,”拼接
@property (copy, nonatomic) NSString *cus_Emails;   // 多个邮件拼接字符串 以“,”拼接
@property (copy, nonatomic) NSString *cus_Adrss;    // 多个地址拼接字符串 以“,”拼接
@property (copy, nonatomic) NSString *cus_Zips;     // 多个邮编拼接字符串 以“,”拼接

@property (copy, nonatomic) NSString *cus_PhoneTags;  // 多个电话修改标识拼接字符串 以“,”拼接
@property (copy, nonatomic) NSString *cus_EmailTags;   // 多个邮件修改标识拼接字符串 以“,”拼接
@property (copy, nonatomic) NSString *cus_AdrsTags;    // 多个地址修改标识拼接字符串 以“,”拼接

@property (assign, nonatomic) BOOL cus_ServerState;     //标记用户是否已经在服务器上存在
@property (assign, nonatomic) BOOL cus_nowState;        //标记用户现在的选中状态

@property (assign, nonatomic) CGFloat cell_Remark_Height;

@property (assign, nonatomic) BOOL cus_IsMyCustomer;     //是否是我的顾客


+ (NSMutableArray *)sortIndexOfCustomerDoc:(NSMutableArray *)customerArray;
+ (NSMutableArray *)sortCustomerDocWithFirstLetter:(NSMutableArray *)letterArray customerArray:(NSMutableArray *)custArray;
@end
