//
//  BeautyRecordPhotoTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/2/29.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "BeautyRecordPhotoTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "BranchShopRes.h"
#import "TGPicListRes.h"

@interface BeautyRecordPhotoTableViewCell() <UIGestureRecognizerDelegate>
{
    NSMutableArray *arrs;
}
@end

@implementation BeautyRecordPhotoTableViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self  = [super initWithFrame:frame]) {
       
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(id)data
{
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    const CGFloat interval = 10.0f;
    const CGFloat imageView_Width =  (kSCREN_BOUNDS.size.width - (5 * interval)) / 4;
    const CGFloat imageView_Height = (kSCREN_BOUNDS.size.width - (5 * interval)) / 4;
    if ([data isKindOfClass:[NSArray class]]) {  // 美丽记录
       arrs = [NSMutableArray array];
        [arrs addObjectsFromArray:data];
        if (arrs.count > 0) {
            for (int i = 0; i < arrs.count; i ++) {
                NSInteger row =  i % 4;
                NSInteger col = i / 4;
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((row + 1) * interval + row * imageView_Width, (col + 1) *interval  + col * imageView_Height, imageView_Width, imageView_Height)];
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.userInteractionEnabled = YES;
                imageView.tag = 100 + i;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
                tap.delegate = self;
                [imageView addGestureRecognizer:tap];
                NSString *imgStr = arrs[i];
                [imageView setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"People-default"] options:SDWebImageCacheMemoryOnly];
                [self.contentView addSubview:imageView];
            }
        }
    }
    
}

-(void)setTGList:(NSMutableArray *)tGList
{    
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    const CGFloat tagLab_Height = 20;
    const CGFloat interval = 10.0f;
    const CGFloat imageView_Width =  (kSCREN_BOUNDS.size.width - (5 * interval)) / 4;
    const CGFloat imageView_Height = (kSCREN_BOUNDS.size.width - (5 * interval)) / 4;

    arrs = [NSMutableArray array];
    [arrs addObjectsFromArray:tGList];
    if (self.addImage) { //最后一个是新增
        [arrs addObject:@"xinzeng"];
    }
    if (arrs.count > 0) {
        for (int i = 0; i < arrs.count; i ++) {
            NSInteger row =  i % 4;
            NSInteger col = i / 4;
            TGPicListRes  *tGPicListRes = arrs[i];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((row + 1) * interval + row * imageView_Width, (col *(tagLab_Height + 10)) + (col + 1) *interval  + col * imageView_Height, imageView_Width, imageView_Height)];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            imageView.tag = 100 + i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
            tap.delegate = self;
            [imageView addGestureRecognizer:tap];
            [self.contentView addSubview:imageView];
            
            UILabel *tagLab = [[UILabel alloc]initWithFrame:CGRectMake((row + 1) * interval + row * imageView_Width, imageView.frame.origin.y + imageView.frame.size.height + interval, imageView_Width, tagLab_Height)];
            tagLab.layer.cornerRadius = 10;
            tagLab.layer.masksToBounds = YES;
            tagLab.font=kNormalFont_14;
            tagLab.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:tagLab];

            if (self.addImage && (i == arrs.count - 1)) { // 最后一个新增
                [imageView setImage:[UIImage imageNamed:@"AddImgBtn_bg"]];
                }else{
                if (tGPicListRes.imageURL && tGPicListRes.imageURL.length >0) {
                    [imageView setImageWithURL:[NSURL URLWithString:tGPicListRes.imageURL] placeholderImage:[UIImage imageNamed:@"People-default"] options:SDWebImageCacheMemoryOnly];
                }
                if (tGPicListRes.imageTag && ![tGPicListRes.imageTag isKindOfClass:[NSNull class]] && tGPicListRes.imageTag.length > 0) {
                     tagLab.text = tGPicListRes.imageTag;
                }
            }
        }
    }

}
- (void)tap:(UITapGestureRecognizer *)ges
{
    if ([ges.view isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)ges.view;
        if (self.addImage) {
            self.tapImage(imgView,arrs);
        }
    }
}

#pragma mark - 
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    return YES;
}

@end
