//
//  AccountEditViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-12-10.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GPImageEditorViewController.h"

@interface AccountEditViewController : BaseViewController<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, GPImageEditorViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
