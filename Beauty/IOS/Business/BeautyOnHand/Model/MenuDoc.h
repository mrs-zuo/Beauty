//
//  MenuDoc.h
//  Customers
//
//  Created by ZhongHe on 13-4-23.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuDoc : NSObject

@property (copy) NSString *MenuName;
@property (copy) UIImage *Image;
@property (copy) NSString *View;

- (id)initWithMenuName:(NSString *)MenuName Image:(UIImage *)Image View:(NSString *)View;

@end