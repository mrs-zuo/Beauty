//
//  MyTopView.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/21.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyTopView;
@protocol MyTopViewDelegate <NSObject>

-(void)MyTopView:(MyTopView *)myTopView button:(UIButton *)butt;

@end

@interface MyTopView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *backImgView;

@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;
@property (weak, nonatomic) IBOutlet UILabel *lab1;
@property (weak, nonatomic) IBOutlet UILabel *lab2;
@property (weak, nonatomic) IBOutlet UILabel *lab3;
@property (weak, nonatomic) IBOutlet UILabel *lab4;

@property (nonatomic,copy) NSString *codeUrlString;


- (IBAction)btnClick:(UIButton *)sender;

@property (nonatomic, weak) id<MyTopViewDelegate>delegate;

@property(nonatomic,weak) id data;


@end
