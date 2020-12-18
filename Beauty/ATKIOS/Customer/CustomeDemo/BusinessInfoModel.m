//
//  BusinessInfoModel.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/6.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "BusinessInfoModel.h"

@implementation BusinessInfoModel
- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"ImageURL"]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [array addObject:obj];
        }];
        _ImageURL = [array copy];
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"forUndefinedKey:%@,Value:%@", key, value);
}

- (NSArray *)businessInfoHandle
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    if (self.Name.length >0) {
         [tmpArray addObject:@{@"Title":self.Name, @"Content":@""}];
    }
    if (self.Abbreviation .length > 0) {
        [tmpArray addObject:@{@"Title":@"简称", @"Content":self.Abbreviation }];
    }
    if (self.Contact.length > 0) {
        [tmpArray addObject:@{@"Title":@"联系人", @"Content":self.Contact}];
    }
    if (self.Phone.length > 0) {
        [tmpArray addObject:@{@"Title":@"电话", @"Content":self.Phone}];
    }
    if (self.Fax.length > 0) {
        [tmpArray addObject:@{@"Title":@"传真", @"Content":self.Fax}];
    }
    if (self.Web.length > 0) {
        [tmpArray addObject:@{@"Title":@"网址", @"Content":@""}];
        [tmpArray addObject:@{@"Title":@"网址简介", @"Content":self.Web}];
    }
    if (self.Summary.length > 0) {
        [tmpArray addObject:@{@"Title":@"简介", @"Content":@""}];
        [tmpArray addObject:@{@"Title":@"", @"Content":self.Summary}];
    }
    return [tmpArray copy];
}

- (NSArray *)shopBusinessInfoHandle
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    if (self.Name.length > 0) {
        [tmpArray addObject:@{@"Title":self.Name}];
    }
    if (self.Contact.length > 0) {
        [tmpArray addObject:@{@"Title":@"联系人", @"Content":self.Contact}];
    }
    if (self.Phone.length > 0) {
        [tmpArray addObject:@{@"Title":@"电话", @"Content":self.Phone}];
    }
    if (self.Fax.length > 0) {
        [tmpArray addObject:@{@"Title":@"传真", @"Content":self.Fax}];
    }
    if (self.Address.length > 0) {
        [tmpArray addObject:@{@"Title":@"地址", @"Content":@""}];
    }
    if (self.Address.length > 0) {
        [tmpArray addObject:@{@"Title":@"", @"Content":self.Address}];
    }
    if (self.Web.length > 0) {
        [tmpArray addObject:@{@"Title":@"网址", @"Content":@""}];
    }
    if (self.Web.length > 0) {
        [tmpArray addObject:@{@"Title":@"网址简介", @"Content":self.Web}];
    }
    if (self.Zip.length > 0) {
        [tmpArray addObject:@{@"Title":@"邮编", @"Content":self.Zip}];
    }
    if (self.BusinessHours.length > 0) {
        [tmpArray addObject:@{@"Title":@"营业时间", @"Content":@""}];
    }
    if (self.BusinessHours.length > 0) {
        [tmpArray addObject:@{@"Title":@"", @"Content":self.BusinessHours}];
    }
    return [tmpArray copy];
}


- (CGFloat)summaryHeight
{
    CGSize summarySize = [self.Summary sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(280.0, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail];
    if (summarySize.height < 20) {
        _summaryHeight = 38.0f;
    } else {
        _summaryHeight = summarySize.height + 12;
    }
    return _summaryHeight;
}

- (BOOL)isMapView
{
    _isMapView = NO;
    if (self.Longitude != 0 && self.Latitude != 0) {
        _isMapView = YES;
    }
    return _isMapView;
}
@end
