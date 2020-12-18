//
//  StatementCategoryDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/5.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatementCategoryDoc : NSObject
@property (nonatomic, strong) NSString *CategoryName;
@property (nonatomic, assign) NSInteger ID;
- (id)initWithDictionary:(NSDictionary *)dic;
@end
