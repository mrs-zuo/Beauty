//
//  ComOrderFilter.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/20.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ComOrderFilter.h"

@implementation ComOrderFilter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _customerName = nil;
        _personName = nil;
    }
    return self;
}

- (NSPredicate *)filterPred
{
    if (_customerName == nil || _personName == nil) {
        if (_customerName == nil) {
            _filterPred = [NSPredicate predicateWithFormat:@"AccountName == %@", self.personName];
        } else {
            _filterPred = [NSPredicate predicateWithFormat:@"CustomerName == %@", self.customerName];
        }
    } else {
        _filterPred = [NSPredicate predicateWithFormat:@"CustomerName == %@ AND AccountName == %@", self.customerName, self.personName];
    }
    return _filterPred;
}
@end
