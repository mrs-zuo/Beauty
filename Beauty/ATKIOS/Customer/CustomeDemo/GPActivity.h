//
//  GPActivity.h
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-13.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPActivity;
typedef void (^GPActivityHandler)(GPActivity *activity, NSArray *activityItems);

@interface GPActivity : NSObject
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) UIImage *image;
@property (strong, nonatomic, readonly) GPActivityHandler activityHander;

- (id)initWithTitle:(NSString *)title image:(UIImage *)image activityHander:(GPActivityHandler)activityHander;

@end
