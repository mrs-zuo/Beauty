//
//  PermissionDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "PermissionDoc.h"
#import "DEFINE.h"
#import "OrderDoc.h"
@implementation PermissionDoc
static PermissionDoc *permissionDoc = nil;

+ (id)sharePermission
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        permissionDoc = [[PermissionDoc alloc] init];
        permissionDoc.userGUID = [[NSString alloc] init];
    });
    
    return permissionDoc;
}
+ (void)saveUserRsa:(NSString *)userID andPassword:(NSString *)pwd {
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"RSA_USERID"];
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:@"RSA_PWD"];
}

// --OperationWay
+(NSInteger)getOperationWay
{
    // 操作模式
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault integerForKey:@"OperationWay"]) {
        NSInteger tmp = [userDefault integerForKey:@"OperationWay"];
        return tmp;
    } else {
        // 标准模式
        return 0;
    }
}

-(void)setPermission:(NSString *)sourceString
{
    PermissionDoc *permissionDoc = [PermissionDoc sharePermission];
    permissionDoc.rule_MyCustomer_Read    = [self isExsit:@"|1|" andSource:sourceString];
    permissionDoc.rule_FirstTop_Read   = [self isExsit:@"|2|" andSource:sourceString];
    permissionDoc.rule_AllCustomer_Read = [self isExsit:@"|3|" andSource:sourceString];
//    permissionDoc.rule_CustomerInfo_Read  = [self isExsit:@"|3|" andSource:sourceString];
    permissionDoc.rule_CustomerInfo_Write = [self isExsit:@"|4|" andSource:sourceString];
    permissionDoc.rule_Record_Read = [self isExsit:@"|28|" andSource:sourceString];
    permissionDoc.rule_Record_Write = [self isExsit:@"|29|" andSource:sourceString];
    permissionDoc.rule_Order_Read   = [self isExsit:@"|5|" andSource:sourceString];
    permissionDoc.rule_MyOrder_Write  = [self isExsit:@"|6|" andSource:sourceString];
    permissionDoc.rule_Payment_Use  = [self isExsit:@"|7|" andSource:sourceString];
    permissionDoc.rule_ECard_Read   = [self isExsit:@"|8|" andSource:sourceString];
    permissionDoc.rule_Recharge_Use = [self isExsit:@"|9|" andSource:sourceString];
    permissionDoc.rule_CustomerLevel_Write = [self isExsit:@"|10|" andSource:sourceString];
    permissionDoc.rule_Service_Read   = [self isExsit:@"|11|" andSource:sourceString];
    permissionDoc.rule_Commodity_Read = [self isExsit:@"|13|" andSource:sourceString];
    permissionDoc.rule_Oppotunity_Use = [self isExsit:@"|30|" andSource:sourceString];
    permissionDoc.rule_Chat_Use       = [self isExsit:@"|15|" andSource:sourceString];
    permissionDoc.rule_MyReport_Read  = [self isExsit:@"|16|" andSource:sourceString];
    permissionDoc.rule_BusinessReport_Read = [self isExsit:@"|17|" andSource:sourceString];
    permissionDoc.rule_Marketing_Read  = [self isExsit:@"|32|" andSource:sourceString];
    permissionDoc.rule_Marketing_Write = [self isExsit:@"|33|" andSource:sourceString];
    permissionDoc.rule_MyInfo_Write    = [self isExsit:@"|21|" andSource:sourceString];
    permissionDoc.rule_IsAccountPayEcard = [self isExsit:@"|1|" andSource:sourceString];
    permissionDoc.rule_OrderTotalSalePrice_Write = [self isExsit:@"|34|" andSource:sourceString];
    permissionDoc.rule_Money_Out = [self isExsit:@"|35|" andSource:sourceString];
    permissionDoc.rule_BranchOrder_Read = [self isExsit:@"|39|" andSource:sourceString];
    permissionDoc.rule_TaskAll_Write = [self isExsit:@"|44|" andSource:sourceString];
    permissionDoc.rule_AllOrder_Write = [self isExsit:@"|45|" andSource:sourceString];
    permissionDoc.rule_attendance_code = [self isExsit:@"|47|" andSource:sourceString];
    permissionDoc.rule_PastPayment = [self isExsit:@"|51|" andSource:sourceString];
    permissionDoc.rule_PastFinished = [self isExsit:@"|52|" andSource:sourceString];
    permissionDoc.rule_BalanceCharge = [self isExsit:@"|53|" andSource:sourceString];
    permissionDoc.rule_DirectExpend = [self isExsit:@"|54|" andSource:sourceString];
    permissionDoc.rule_TerminateOrder = [self isExsit:@"|55|" andSource:sourceString];
    permissionDoc.rule_PayAmountWrite = [self isExsit:@"|57|" andSource:sourceString];
}

-(void)resetPermission:(NSString *)record_marketing_oppotun
{
    PermissionDoc *permissionDoc = [PermissionDoc sharePermission];
    permissionDoc.rule_MyCustomer_Read    = NO;
    permissionDoc.rule_AllCustomer_Read   = NO;
    permissionDoc.rule_CustomerInfo_Read  = NO;
    permissionDoc.rule_CustomerInfo_Write = NO;
    permissionDoc.rule_Record_Read = NO;
    permissionDoc.rule_Record_Write = NO;
    permissionDoc.rule_Order_Read   = NO;
//    permissionDoc.rule_Order_Write  = NO;
    permissionDoc.rule_Payment_Use  = NO;
    permissionDoc.rule_ECard_Read   = NO;
    permissionDoc.rule_Recharge_Use = NO;
    permissionDoc.rule_CustomerLevel_Write = NO;
    permissionDoc.rule_Service_Read   = NO;
    permissionDoc.rule_Commodity_Read = NO;
    permissionDoc.rule_Oppotunity_Use = NO;
    permissionDoc.rule_Chat_Use       = NO;
    permissionDoc.rule_MyReport_Read  = NO;
    permissionDoc.rule_BusinessReport_Read = NO;
    permissionDoc.rule_Marketing_Read  = NO;
    permissionDoc.rule_Marketing_Write = NO;
    permissionDoc.rule_MyInfo_Write    = NO;
    permissionDoc.rule_IsAccountPayEcard = NO;
    permissionDoc.rule_OrderTotalSalePrice_Write = NO;
    permissionDoc.rule_Money_Out = NO;
    permissionDoc.rule_TaskAll_Write = NO;
    permissionDoc.record_marketing_oppotun = record_marketing_oppotun;
    permissionDoc.rule_AllOrder_Write = NO;
    permissionDoc.rule_BranchOrder_Read = NO;
    permissionDoc.rule_FirstTop_Read = NO;
    permissionDoc.rule_MyOrder_Write = NO;
    permissionDoc.rule_PastPayment = NO;
    permissionDoc.rule_PastFinished = NO;
    permissionDoc.rule_BalanceCharge = NO;
    permissionDoc.rule_DirectExpend = NO;
    permissionDoc.rule_TerminateOrder = NO;
    permissionDoc.rule_PayAmountWrite = NO;
}
// -- Record
-(BOOL)isExsit:(NSString *)string andSource:(NSString *)sourceString
{
    return  [sourceString rangeOfString:string].length > 0 ? YES : NO;
}

@end
