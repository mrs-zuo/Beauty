//
//  BeautyCommentsTableViewCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/1.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeautyCommentsTableViewCell : UITableViewCell <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *comTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLab;

@end
