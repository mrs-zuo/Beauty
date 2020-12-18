//
//  DeliveryView.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/5.
//  Copyright © 2016年 ace-009. All rights reserved.
//


#import "DeliveryView.h"
#import "UIImageView+WebCache.h"




@interface DeliveryView()

@end
@implementation DeliveryView
const NSInteger  kContentTag = 10;
const NSInteger  kImageView_ThumbnailURLTag = 20;
const CGFloat kCusHeight = 40;

- (void)initView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(5, (self.frame.size.height - (3 * kCusHeight) - 1) / 2 - 64, self.frame.size.width -10, (3 * kCusHeight) + 1)];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, kCusHeight)];
    titleLab.textColor = kColor_Black;
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont boldSystemFontOfSize:18.0f];
    titleLab.text = @"交付编号";
    [view addSubview:titleLab];
    
    UIView *linView1 = [[UIView alloc]initWithFrame:CGRectMake(0, titleLab.frame.origin.y + titleLab.frame.size.height, view.frame.size.width, 0.5)];
    linView1.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:linView1];
    
    
    UILabel *contentLab = [[UILabel alloc]initWithFrame:CGRectMake(0, linView1.frame.origin.y + linView1.frame.size.height, view.frame.size.width, kCusHeight)];
    contentLab.textColor = [UIColor blueColor];
    contentLab.textAlignment = NSTextAlignmentCenter;
    contentLab.font = [UIFont systemFontOfSize:17.0f];
    contentLab.tag = kContentTag;
    [view addSubview:contentLab];
    
    UIView *linView2 = [[UIView alloc]initWithFrame:CGRectMake(0, contentLab.frame.origin.y + contentLab.frame.size.height, view.frame.size.width, 0.5)];
    linView2.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:linView2];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =  CGRectMake(0, linView2.frame.origin.y + linView2.frame.size.height , view.frame.size.width, kCusHeight);
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];

}

- (void)initSignImageView
{
    CGFloat y = (kSCREN_BOUNDS.size.height - 64 -((4 * kCusHeight) + (kSCREN_BOUNDS.size.width *(kSCREN_BOUNDS.size.width / kSCREN_BOUNDS.size.height))  + 40 + 2)) / 2;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(5, y, self.frame.size.width -10, (4 * kCusHeight) + (kSCREN_BOUNDS.size.width *(kSCREN_BOUNDS.size.width / kSCREN_BOUNDS.size.height)) + 2)];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, kCusHeight)];
    titleLab.textColor = kColor_Black;
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont boldSystemFontOfSize:18.0f];
    titleLab.text = @"交付编号";
    [view addSubview:titleLab];
    
    UIView *linView1 = [[UIView alloc]initWithFrame:CGRectMake(0, titleLab.frame.origin.y + titleLab.frame.size.height, view.frame.size.width, 0.5)];
    linView1.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:linView1];
    
    
    UILabel *contentLab = [[UILabel alloc]initWithFrame:CGRectMake(0, linView1.frame.origin.y + linView1.frame.size.height, view.frame.size.width, kCusHeight)];
    contentLab.textColor = [UIColor blueColor];
    contentLab.textAlignment = NSTextAlignmentCenter;
    contentLab.font = [UIFont systemFontOfSize:17.0f];
    contentLab.tag = kContentTag;
    [view addSubview:contentLab];
    
    UIView *linView2 = [[UIView alloc]initWithFrame:CGRectMake(0, contentLab.frame.origin.y + contentLab.frame.size.height, view.frame.size.width, 0.5)];
    linView2.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:linView2];
    
    UILabel *signTitleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, linView2.frame.origin.y + linView2.frame.size.height, view.frame.size.width, kCusHeight)];
    signTitleLab.textColor = kColor_Black;
    signTitleLab.textAlignment = NSTextAlignmentCenter;
    signTitleLab.font = [UIFont boldSystemFontOfSize:18.0f];
    signTitleLab.text = @"顾客签字";
    [view addSubview:signTitleLab];

    UIView *linView3 = [[UIView alloc]initWithFrame:CGRectMake(0, signTitleLab.frame.origin.y + signTitleLab.frame.size.height, view.frame.size.width, 0.5)];
    linView3.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:linView3];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, linView3.frame.origin.y + linView3.frame.size.height, view.frame.size.width, kSCREN_BOUNDS.size.width *(kSCREN_BOUNDS.size.width / kSCREN_BOUNDS.size.height))];
    imageView.tag = kImageView_ThumbnailURLTag;
    [view addSubview:imageView];
    
    UIView *linView4 = [[UIView alloc]initWithFrame:CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height, view.frame.size.width, 0.5)];
    linView4.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:linView4];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =  CGRectMake(0, linView4.frame.origin.y + linView4.frame.size.height , view.frame.size.width, kCusHeight);
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
}

-(void)setGroupNo:(NSString *)groupNo
{
    UILabel *contentLab = [self viewWithTag:kContentTag];
    contentLab.text = groupNo;
}
- (void)setThumbnailURL:(NSString *)thumbnailURL
{
    if (thumbnailURL) {
        NSArray *tempArrs = [thumbnailURL componentsSeparatedByString:@"&th"];
        NSString *urlStr =  tempArrs.firstObject;
        UIImageView *imageView = [self viewWithTag:kImageView_ThumbnailURLTag];
        [imageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
        }];
    }
}

- (void)btnClick:(UIButton *)sender
{
    self.deliveryViewConfrimBlock();
}


@end
