//
//  ZXServiceEffectViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/19.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
#import "PictureDisplayView.h"

@interface TMListDoc : NSObject
@property (assign, nonatomic) NSInteger treatmentID;
@property (copy, nonatomic) NSString *subServiceName;
@end

@interface ZXServiceEffectViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, PictureDisplayViewDelegate>


@property (assign, nonatomic) NSInteger treat_ID;
@property (assign, nonatomic) NSInteger customerID;

@property (assign ,nonatomic) NSInteger treatMentOrGroup;//0 group  1 teatment
@property (assign ,nonatomic) double  GroupNo;
@property (assign ,nonatomic) NSInteger OrderID;

@property (assign, nonatomic) BOOL permission_Write;

@end
