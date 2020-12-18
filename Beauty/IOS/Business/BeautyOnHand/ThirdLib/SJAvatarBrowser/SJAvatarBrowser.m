//
//  SJAvatarBrowser.m
//  zhitu
//
//  Created by 陈少杰 on 13-11-1.
//  Copyright (c) 2013年 聆创科技有限公司. All rights reserved.
//

#import "SJAvatarBrowser.h"
#import "UIButton+InitButton.h"

static CGRect oldframe;
@implementation SJAvatarBrowser
+(void)showImage:(UIImageView*)avatarImageView img:(UIImage *)img
{
    UIImage *image;
    if (img) {
        image = img;
    }else{
      image = avatarImageView.image;
    }
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
        backgroundView.backgroundColor=[UIColor blackColor];
        backgroundView.alpha=0;
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
        imageView.image=image;
        imageView.tag=1;
        [backgroundView addSubview:imageView];
        [window addSubview:backgroundView];
    
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
        [backgroundView addGestureRecognizer: tap];
    
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
            backgroundView.alpha=1;
            NSData *data =  UIImageJPEGRepresentation(image, 1.0);
            UIImage *img = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
            [imageView setImage:img];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
    
        } completion:^(BOOL finished) {
           
        }];
}
//+(void)showImage:(UIImageView *)avatarImageView{
//    UIImage *image=avatarImageView.image;
//    UIWindow *window=[UIApplication sharedApplication].keyWindow;
//    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//    oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
//    backgroundView.backgroundColor=[UIColor blackColor];
//    backgroundView.alpha=0;
//    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
//    imageView.image=image;
//    imageView.tag=1;    
//    [backgroundView addSubview:imageView];
//    [window addSubview:backgroundView];
//    
//    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
//    [backgroundView addGestureRecognizer: tap];
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
//        backgroundView.alpha=1;
//        NSData *data =  UIImageJPEGRepresentation(image, 1.0);
//        UIImage *img = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
//        [imageView setImage:img];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//
//    } completion:^(BOOL finished) {
//       
//    }];
//}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

@end
