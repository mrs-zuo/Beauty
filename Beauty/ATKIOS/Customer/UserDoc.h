//
//  UserDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-10-18.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  struct  {
    int startTime;
    int duration;
    const char *name;
} workTime ;

typedef NS_ENUM(NSInteger, AccountType) {
    AccountTypeMine = 0,
    AccountTypeSale = 1,
    AccountTypeNormol
};
@interface UserDoc : NSObject<NSCoding>

@property (assign, nonatomic) NSInteger user_Type; // 0为customer 1为account
@property (nonatomic, assign) AccountType accountType;
@property (assign, nonatomic) NSInteger user_Id;
@property (copy, nonatomic) NSString *user_Code;
@property (copy, nonatomic) NSString *user_Name;
@property (copy, nonatomic) NSString *user_HeadImage;
@property (copy, nonatomic) NSString *user_ShortPinYin;
@property (copy, nonatomic) NSString *user_QuanPinYin;

@property (copy, nonatomic) NSString *user_Department;

@property (strong, nonatomic) NSArray *worktimeArray;

@property (assign, nonatomic) NSInteger user_Available;
@property (assign, nonatomic) NSInteger user_SelectedState; // 0未选中 1为选中

@property (copy, nonatomic) NSString *user_LoginMobile; //
@end
