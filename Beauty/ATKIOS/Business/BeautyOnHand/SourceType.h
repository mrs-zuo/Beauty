//
//  SourceType.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/7/15.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SourceType : NSObject
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, assign) NSInteger ID;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
