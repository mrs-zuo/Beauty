//
//  CosmetologistListViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitialSlidingViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "AccountDoc.h"
@class AccountDoc;
@interface CosmetologistListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myListView;

@property (strong) NSMutableArray *cosmetologist;

@property (strong) AccountDoc *AccountDoc;
@property (strong) AccountDoc *cs;


@property (assign, nonatomic) NSInteger cos_CompanyID;
@property (assign, nonatomic) NSInteger cos_UserID;
@property (copy, nonatomic) NSString *cos_Name;
@property (copy, nonatomic) NSString *cos_Title;
@property (copy, nonatomic) NSString *cos_Department;
@property (copy, nonatomic) NSString *cos_Available;  //帐户是否激活
@property (copy, nonatomic) NSString *cos_HeadImgURL;
@property (copy, nonatomic) NSString *cos_Expert;
@property (copy, nonatomic) NSString *cos_Introduction;
@property (copy, nonatomic) NSString *cos_Mobile;



- (IBAction)addCosmetologistAction:(id)sender;
@end
