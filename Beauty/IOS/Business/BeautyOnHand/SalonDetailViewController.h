//
//  SalonDetailViewController.h
//  CustomeDemo
//
//  Created by macmini on 13-7-5.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@class CompanyDoc;

@interface SalonDetailViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
@property (strong) CompanyDoc *company;
@property (weak,nonatomic) IBOutlet UITableView *tablesView;
@property (strong,nonatomic) NSMutableArray *ImgList;
@property (assign,nonatomic) NSInteger branchId;    //接收用ID
@property (assign,nonatomic) NSInteger tag;    //接收用标记
@property (copy, nonatomic) NSString* businessName;

@end
