//
//  PhotoDoc.h
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-8.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoDoc : NSObject
@property (assign, nonatomic) NSInteger photoID;
@property (copy, nonatomic) NSString *photoURL;
@property (copy, nonatomic) NSString *photoOriginalURL;
@property (copy, nonatomic) NSString *photoDate;
@end
