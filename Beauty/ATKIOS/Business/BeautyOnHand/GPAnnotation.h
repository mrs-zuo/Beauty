//
//  GPAnnotation.h
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-6.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GPAnnotation : NSObject <MKAnnotation>
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@end
