//
//  ContentEditCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-9-6.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface ContentEditCell : UITableViewCell
@property (nonatomic) UIPlaceHolderTextView *contentEditText;
- (void)setContentText:(NSString *)contentText;
@end
