//
//  MenuDoc.h
//  Customers
//
//  Created by ace-009 on 13-4-23.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuDoc : NSObject

@property (strong) NSString *MenuName;
@property (strong) UIImage *Image;
@property (strong) NSString *View;

- (id)initWithMenuName:(NSString *)MenuName Image:(UIImage *)Image View:(NSString *)View;

@end