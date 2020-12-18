//
//  CustomerDoc.m
//  Customers
//
//  Created by ZhongHe on 13-4-23.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CustomerDoc.h"
#import "PhoneDoc.h"
#import "EmailDoc.h"
#import "AddressDoc.h"
#import "DEFINE.h"
#import "PermissionDoc.h"

@implementation CustomerDoc

- (id)init
{
    self = [super init];
    if (self) {
        _cus_PhoneArray = [NSMutableArray array];
        _cus_EmailArray = [NSMutableArray array];
        _cus_AdrsArray  = [NSMutableArray array];
        
        _cus_Answers = [NSMutableArray array];
        _cus_oldAnswer = [NSMutableArray array];
        
        _cus_Remark = @"";
        _cus_Profession = @"";
    
    }
    return self;
}

- (void)setCus_Remark:(NSString *)newCus_Remark
{
    _cus_Remark = newCus_Remark;
    
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 150.0f)];
    textView.text = _cus_Remark;
    textView.font = kFont_Light_16;

    float currentHeight = [textView sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;

    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    _cell_Remark_Height = currentHeight;
//    textView = nil;
}

- (NSString *)cus_FirstWord {
    static NSString *checkString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    if (_cus_QuanPinYin.length) {
        _cus_FirstWord = [_cus_QuanPinYin substringToIndex:1].uppercaseString;
        if ([checkString rangeOfString:_cus_FirstWord].location == NSNotFound) {
            _cus_FirstWord = @"#";
        }
    } else {
        _cus_FirstWord = @"#";
    }
    
    return _cus_FirstWord;
}

+ (NSMutableArray *)sortCustomerDocWithFirstLetter:(NSMutableArray *)letterArray customerArray:(NSMutableArray *)custArray
{
    
    NSMutableArray *completionArray = [NSMutableArray array];
    for (NSString *firstString in letterArray) {
        NSMutableArray *tmp = [NSMutableArray array];
        [custArray enumerateObjectsUsingBlock:^(CustomerDoc *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.cus_FirstWord isEqualToString:firstString]) {
                [tmp addObject:obj];
            }
        }];
        [completionArray addObject:tmp];
    }
    return completionArray;
}

+ (NSMutableArray *)sortIndexOfCustomerDoc:(NSMutableArray *)customerArray
{
    NSArray *firstLetter = [customerArray valueForKeyPath:@"@distinctUnionOfObjects.cus_FirstWord"];
    
    NSArray *array = [firstLetter sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isEqualToString:@"#"]) {
            return NSOrderedDescending;
        } else if ([obj2 isEqualToString:@"#"]) {
            return NSOrderedAscending;
        }
        return [obj1 caseInsensitiveCompare:obj2];
        }];
    return [array mutableCopy];
}

- (BOOL)isMyPerson
{
    if (ACC_ACCOUNTID == self.cus_ResponsiblePersonID) {
        _isMyPerson = YES;
    } else {
        _isMyPerson = NO;
    }
    return _isMyPerson;
}

- (CustomerEditStatus)editStatus
{
    if (self.isMyPerson) {
        _editStatus = CustomerEditStatusBasic|CustomerEditStatusContacts|CustomerEditStatusPro;
    } else {
        if (![[PermissionDoc sharePermission] rule_CustomerInfo_Write]) {
            _editStatus = CustomerEditStatusNone;
        } else {
            _editStatus = CustomerEditStatusBasic;
            if ([[PermissionDoc sharePermission] rule_Record_Read] && [[PermissionDoc sharePermission] rule_Record_Write]) {
                _editStatus = CustomerEditStatusBasic|CustomerEditStatusContacts|CustomerEditStatusPro;
            } else if ([[PermissionDoc sharePermission] rule_Record_Read]) {
                _editStatus = _editStatus | CustomerEditStatusContacts;
            } else if ([[PermissionDoc sharePermission] rule_Record_Write]) {
                _editStatus = _editStatus |CustomerEditStatusPro;
            }
        }
    }
    return _editStatus;
}

- (NSString *)cus_LoginStarMob
{
    if (self.editStatus & CustomerEditStatusContacts) { //
        _cus_LoginStarMob = self.cus_LoginMobile;
    } else {
        NSMutableString *stry = [self.cus_LoginMobile mutableCopy];
        NSInteger length = stry.length - 4;
        if (length > 0) {
            NSMutableString *star = [NSMutableString string];
            for (NSInteger i = 0; i < length; i ++) {
                [star appendString:@"*"];
            }
            [stry replaceCharactersInRange:NSMakeRange(0, length) withString:star];
        }
        _cus_LoginStarMob = [stry copy];
    }
    return _cus_LoginStarMob;
}
@end
