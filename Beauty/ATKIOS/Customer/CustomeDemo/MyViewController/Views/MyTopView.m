//
//  MyTopView.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/21.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "MyTopView.h"
#import "CustomerInfoRes.h"

@interface MyTopView ()
{
    UIView* goBackgroundView;
    CGRect defaultRect;
}
@end
@implementation MyTopView

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self bringSubviewToFront:_photoImgView];
    _photoImgView.layer.masksToBounds = YES;
    _photoImgView.layer.cornerRadius = CGRectGetHeight(_photoImgView.bounds) / 2;
    UITapGestureRecognizer *tap  =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showcode:)];
    [_codeImgView addGestureRecognizer:tap];
}
-(void)setCodeUrlString:(NSString *)codeUrlString
{
    NSData *codeData  =[NSData dataWithContentsOfURL:[NSURL URLWithString:[codeUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    UIImage *codeImg = [UIImage imageWithData:codeData];
    [_codeImgView setImage:codeImg];
}
-(void)setData:(id)data
{
    if([data isKindOfClass:[NSMutableArray class]]){
        NSMutableArray *temp = (NSMutableArray *)data;
        if (temp.count >0) {
            CustomerInfoRes *res = temp[0];
            _lab1.text = [NSString stringWithFormat:@"%d",res.AllOrderCount];
            _lab2.text = [NSString stringWithFormat:@"%d",res.UnPaidCount];
            _lab3.text = [NSString stringWithFormat:@"%d",res.NeedConfirmTGCount];
            _lab4.text = [NSString stringWithFormat:@"%d",res.NeedReviewTGCount];
            _nameLab.text = res.CustomerName;
            _numLab.text = res.LoginMobile;
            [_photoImgView setImageWithURL:[NSURL URLWithString:res.HeadImageURL] placeholderImage:[UIImage imageNamed:@"People-default"] options:SDWebImageCacheMemoryOnly];
        }
        
    }
}
#pragma mark - 按钮事件

- (IBAction)btnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(MyTopView:button:)]) {
        [self.delegate MyTopView:self button:sender];
    }

}

-(void)showcode:(UIGestureRecognizer *)gestureRecognizer
{
    UIImage *image = _codeImgView.image;
    if (!image) return;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    goBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    defaultRect = [_codeImgView convertRect:_codeImgView.bounds toView:window];//关键代码，坐标系转换
    goBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:defaultRect];
    imageView.image = image;
    imageView.tag = 1;
    UIImageView *fakeImageView = [[UIImageView alloc]initWithFrame:defaultRect];
    [goBackgroundView addSubview:fakeImageView];
    [goBackgroundView addSubview:imageView];
    [window addSubview:goBackgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [goBackgroundView addGestureRecognizer:tap];
    _codeImgView.alpha = 0;
    [UIView animateWithDuration:0.5f animations:^{
        imageView.frame=CGRectMake(20.0f,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width - 40.0f, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width - 40.0f);
        
        goBackgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
    } completion:^(BOOL finished) {
    }];
    
}
- (void)hideImage:(UITapGestureRecognizer*)tap{
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.5f animations:^{
        imageView.frame = defaultRect;
        goBackgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
      _codeImgView.alpha = 1;
        [goBackgroundView removeFromSuperview];
    }];
}

@end
