//
//  ZXOrderSearchViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/18.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "BaseViewController.h"
@class ZXOrderSearchViewController;
@protocol ZXOrderSearchViewControllerDelegate <NSObject>

- (void)ZXOrderSearchViewController:(ZXOrderSearchViewController *)orderSearchViewController searchBar:(UISearchBar *)searchBar;

@end

@interface ZXOrderSearchViewController : BaseViewController

@property (nonatomic,assign) id <ZXOrderSearchViewControllerDelegate>delegate;
@end
