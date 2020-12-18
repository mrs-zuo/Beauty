//
//  SelectViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/17.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectViewControllerDelegate;
@interface SelectViewController : UIViewController
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSString *selectTitle;
@property (nonatomic, strong) NSString *selectName;
@property (nonatomic, weak) id<SelectViewControllerDelegate> delegate;
@end
@protocol SelectViewControllerDelegate <NSObject>

- (void)selectNameOfFilterNameObject:(NSString *)nameObject titleName:(NSString *)title;

@end