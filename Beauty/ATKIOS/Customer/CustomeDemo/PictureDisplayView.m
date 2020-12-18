//
//  PictureDisplayView.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "PictureDisplayView.h"
#import "UIImageView+WebCache.h"

@interface PictureDisplayView ()
@property (strong, nonatomic) UIImageView *selectedImgView;
@property (assign, nonatomic) CGFloat margin;
@property (assign, nonatomic) CGSize picSize;
@property (assign, nonatomic) CGFloat spacing;

@property (strong, nonatomic) NSMutableArray *imgsURLs;
@property (strong, nonatomic) NSMutableArray *uploadImgs;   // image + type
@property (strong, nonatomic) NSMutableArray *deleteImgs; // URL集合

@property (assign, nonatomic) int imgCount;
@end

@implementation PictureDisplayView
@synthesize picScrollView;
@synthesize picSize;
@synthesize spacing;
@synthesize margin;
@synthesize selectedImgView;
@synthesize isEditing;
@synthesize imgCount;
@synthesize imgsURLs, uploadImgs, deleteImgs;
@synthesize delegate;
@synthesize imgEditViewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        picScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        picScrollView.delegate = self;
        picScrollView.scrollEnabled = YES;
        picScrollView.contentSize = CGSizeZero;
        picScrollView.userInteractionEnabled = YES;
        picScrollView.showsHorizontalScrollIndicator = NO;
        picScrollView.pagingEnabled = YES; //是否翻页
        
        [self addSubview:picScrollView];
        
        [self setPicSize:CGSizeMake(80.0f, 80.0f)];
        [self setSpacing:10.0f];
        [self setMargin:(self.frame.size.height - picSize.height) / 2];
        
        imgsURLs  = [NSMutableArray array];
        uploadImgs = [NSMutableArray array];
        deleteImgs = [NSMutableArray array];
        imgCount = 0;
    }
    return self;
}

#pragma mark - The Method is called outside

- (id)initWithFrame:(CGRect)frame picSize:(CGSize)size spacing:(CGFloat)space
{
    self = [self initWithFrame:frame];
    if (self) {
        [self setPicSize:size];
        [self setSpacing:space];
        [self setMargin:(self.frame.size.height - picSize.height) / 2];
    }
    return self;
}

// -- 刷新
- (void)refreshScrollView
{
    NSArray *tempImageURLs = [imgsURLs copy];
    NSArray *tempUplodImgs = [uploadImgs copy];
    [imgsURLs removeAllObjects];
    imgCount = 0;
    
    [self removeAllImageViews];
    
    for (NSString *urlStr in tempImageURLs) {
        [self addImageViewByURLStr:urlStr animated:NO];
    }
    
    for (NSArray *arry in tempUplodImgs) {
        NSString *imgType = [arry objectAtIndex:0];
        UIImage *image = [arry objectAtIndex:1];
        [self addImageViewByImage:image type:imgType animated:NO];
    }
    
    if (isEditing) {
        [self addAddButton];
    }
}

- (void)setIsEditing:(BOOL)theIsEditing
{
    isEditing = theIsEditing;
    if (theIsEditing) {
        [self refreshScrollView];
    }
}

- (void)setPicturesWithURLs:(NSArray *)array
{
    imgsURLs = [NSMutableArray arrayWithArray:array];
    [self refreshScrollView];
}

- (void)scrollToNextPicture
{
    CGFloat content_W = picScrollView.contentSize.width;
    CGFloat rect_W = picScrollView.frame.size.width;
    CGFloat currentSize_W = picScrollView.contentOffset.x;
    if (currentSize_W + rect_W * 2>= content_W) {
        [picScrollView setContentOffset:CGPointMake(content_W - rect_W, 0) animated:YES];
    } else {
        [picScrollView setContentOffset:CGPointMake(currentSize_W + rect_W, 0) animated:YES];
    }
}

- (void)scrollToPreviouPicture
{
    CGFloat rect_W = picScrollView.frame.size.width;
    CGFloat currentOffset_Y = picScrollView.contentOffset.x;
    if (currentOffset_Y - rect_W <= 0) {
        [picScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [picScrollView setContentOffset:CGPointMake(currentOffset_Y - rect_W , 0) animated:YES];
    }
}

- (NSArray *)getDeleteImageURLsArray
{
    return self.deleteImgs;
}

- (NSArray *)getUploadImagesAndTypes
{
    return self.uploadImgs;
}

#pragma mark - Add ImageView

// --单个 添加imageView by URL
- (void)addImageViewByURLStr:(NSString *)imgURL animated:(BOOL)animated
{
    [imgsURLs addObject:imgURL];
    
    CGFloat imgView_X = (picSize.width + spacing) * imgCount;
    CGFloat imgView_Y = margin;
    UIImageView *newImgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgView_X, imgView_Y, picSize.width, picSize.height)];
    newImgView.userInteractionEnabled = YES;
    newImgView.tag = imgCount;
    //newImgView.layer.borderColor = [kTableView_LineColor CGColor];
    //newImgView.layer.borderWidth = 0.8f;
    //newImgView.layer.cornerRadius = 4.0f;
    newImgView.layer.masksToBounds = NO;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topThePicture:)];
    [newImgView addGestureRecognizer:tapGestureRecognizer];
    
    CGFloat content_W = self.picScrollView.contentSize.width;
    CGFloat content_H = self.picScrollView.contentSize.height;
    if (imgCount == 0) {
        content_W = content_W + picSize.width;
    } else {
        content_W = content_W + picSize.width + spacing;
    }
    [picScrollView setContentSize:CGSizeMake(content_W, content_H)];
    
    if (animated) {
        [UIView beginAnimations:@"addimgView" context:nil];
        [UIView setAnimationDelay:0.3f];
        [picScrollView addSubview:newImgView];
        [UIView commitAnimations];
    } else {
        [picScrollView addSubview:newImgView];
    }
    
    if (isEditing) {
        [self addDeleteButtonWithImageView:newImgView];
    }
    if (picSize.width == 120.0f) {
        [newImgView setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed:@"load_120X120"]];
    } else {
        [newImgView setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed:@"load_80X80"]];
    }
    
    imgCount ++;
}

// --单个 添加imageView by image
- (void)addImageViewByImage:(UIImage *)image type:(NSString *)type animated:(BOOL)animated
{
    NSArray *valueArray = [NSArray arrayWithObjects:type, image, nil];
    [uploadImgs addObject:valueArray];
    
    CGFloat imgView_X = picScrollView.contentSize.width + spacing;
    CGFloat imgView_Y = margin;
    UIImageView *newImgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgView_X, imgView_Y, picSize.width, picSize.height)];
    [newImgView setUserInteractionEnabled:YES];
    [newImgView setImage:image];
    [newImgView setTag:imgCount];
    //newImgView.layer.borderColor = [kTableView_LineColor CGColor];
    //newImgView.layer.borderWidth = 0.8f;
    //newImgView.layer.cornerRadius = 4.0f;
    newImgView.layer.masksToBounds = NO;
    
    CGFloat content_W = self.picScrollView.contentSize.width;
    CGFloat content_H = self.picScrollView.contentSize.height;
    content_W = content_W + spacing + picSize.width;
    [picScrollView setContentSize:CGSizeMake(content_W, content_H)];
    
    if (animated) {
        [UIView beginAnimations:@"addimgView" context:nil];
        [UIView setAnimationDelay:0.3f];
        [picScrollView addSubview:newImgView];
        [UIView commitAnimations];
    } else {
        [picScrollView addSubview:newImgView];
    }
    
    if (isEditing) {
        [self addDeleteButtonWithImageView:newImgView];
    }
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topThePicture:)];
    [newImgView addGestureRecognizer:tapGestureRecognizer];
    
    imgCount ++;
}

// --添加添加按钮
- (void)addAddButton
{
    CGFloat imgView_X = picScrollView.contentSize.width + spacing;
    CGFloat imgView_Y = margin;
    UIImageView *addImgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgView_X, imgView_Y, picSize.width, picSize.height)];
    [addImgView setImage:[UIImage imageNamed:@"AddImgBtn_bg"]];
    [addImgView setUserInteractionEnabled:YES];
    [addImgView setTag:imgCount];
    [picScrollView addSubview:addImgView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImgViewAction:)];
    [addImgView addGestureRecognizer:tapGestureRecognizer];
    
    CGFloat content_W = self.picScrollView.contentSize.width;
    CGFloat content_H = self.picScrollView.contentSize.height;
    content_W = content_W + spacing + picSize.width;
    [picScrollView setContentSize:CGSizeMake(content_W, content_H)];
}

// --添加删除按钮
- (void)addDeleteButtonWithImageView:(UIImageView *)theImageView
{
    CGFloat deleteImg_X = theImageView.frame.size.width - 20.0f;
    CGFloat deleteImg_Y = 0.0f;
    UIImageView *deleteImgView = [[UIImageView alloc] init];
    [deleteImgView setFrame:CGRectMake(deleteImg_X, deleteImg_Y, 20.0f, 20.0f)];
    [deleteImgView setImage:[UIImage imageNamed:@"deleteBtn_bg"]];
    [deleteImgView setUserInteractionEnabled:YES];
    [deleteImgView setTag:theImageView.tag + 1000];
    [theImageView addSubview:deleteImgView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeImgViewAction:)];
    [deleteImgView addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - Remove ImageView

// --删除单个 imageView
- (void)removeImageViewWithIndex:(int)index animated:(BOOL)animated
{
    if (index < [imgsURLs count]) {  // 删除的是URL ImgView
        NSString *urlStr = [imgsURLs objectAtIndex:index];
        [deleteImgs addObject:urlStr];
        
        imgCount --;
    } else  if (isEditing && index == ([imgsURLs count] + [uploadImgs count])) {  // 删除的是AddImgView
        // do noting
    } else {  // 删除的是UpladImgs
        NSUInteger theIndex = index - [imgsURLs count];
        [uploadImgs removeObjectAtIndex:theIndex];
        imgCount --;
    }
    
    CGSize scrollView_Content_Size = picScrollView.contentSize;
    scrollView_Content_Size.width -= (picSize.width + spacing);
    picScrollView.contentSize = scrollView_Content_Size;
    
    
    UIImageView *deleteImgView = [self searchTheImageViewByTag:index];
    if (!deleteImgView) {
        NSAssert(!deleteImgView, @"未找到tag的ImageView");
    }
    
    if (animated) {
        [UIView beginAnimations:@"deleteImg" context:nil];
        [UIView setAnimationDelay:0.3f];
        [deleteImgView removeFromSuperview];
        deleteImgView = nil;
        [UIView commitAnimations];
    } else {
        [deleteImgView removeFromSuperview];
        deleteImgView = nil;
    }
}

// --删除所有 imageViews
- (void)removeAllImageViews
{
    for (UIImageView *imageView in picScrollView.subviews) {
        [imageView removeFromSuperview];
    }
    [picScrollView setContentSize:CGSizeZero];
}

// 根据ImageView的tag  找到该ImageView
- (UIImageView *)searchTheImageViewByTag:(int)tag
{
    for (UIImageView *tmpImgView in picScrollView.subviews) {
        if (tmpImgView.tag == tag) {
            return tmpImgView;
        }
    }
    return nil;
}

#pragma mark - Action

- (void)removeImgViewAction:(UIGestureRecognizer *)gestureRecognizer
{
    UIImageView *deleteImgView = (UIImageView *)gestureRecognizer.view;
    NSInteger index = deleteImgView.tag - 1000;
    if (index < [imgsURLs count]) // 删除的是URL ImgView
    {
        NSString *theURLStr = [imgsURLs objectAtIndex:index];
        [imgsURLs removeObjectAtIndex:index];
        [deleteImgs addObject:theURLStr];
    }
    else  if (isEditing && index == ([imgsURLs count] + [uploadImgs count]))
    {  // 删除的是AddImgView
        NSAssert(0, @"+++++错误:AddImgView将要错误删除");
    }
    else
    {  // 删除的是UpladImgs
        NSInteger theIndex = index - [imgsURLs count];
        [uploadImgs removeObjectAtIndex:theIndex];
    }
    [self refreshScrollView];
}

- (void)addImgViewAction:(UIGestureRecognizer *)gestureRecognizer
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"上传图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从图库中获取", nil];
    UIViewController *theController = imgEditViewController;
    [actionSheet showInView:theController.view];
}

- (void)topThePicture:(UIGestureRecognizer *)gestureRecognizer
{
//    selectedImgView = (UIImageView *)gestureRecognizer.view;
//    
//    UIImageView *deleteImgView = (UIImageView *)gestureRecognizer.view;
//    [self removeImageViewWithIndex:deleteImgView.tag - 1000 animated:YES];
}

- (UIImageView *)checkImageViewByTag:(int)tag
{
    for (UIImageView *theImgView in picScrollView.subviews) {
        if (theImgView.tag == tag) {
            return theImgView;
        }
    }
    return nil;
}

#pragma UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffSet_X = self.picScrollView.contentOffset.x;
    CGFloat contentSize_W = self.picScrollView.contentSize.width;
    CGFloat rect_W = self.picScrollView.frame.size.width;
    
    if ([delegate respondsToSelector:@selector(pictureDisplayView:leftmost:rightmost:)]) {
        if (contentOffSet_X <= 0)
        {
            [delegate pictureDisplayView:self leftmost:YES rightmost:NO];
        }
        else if (contentOffSet_X >= contentSize_W - rect_W)
        {
            [delegate pictureDisplayView:self leftmost:NO rightmost:YES];
        }
        else if (rect_W >= contentSize_W)
        {
            [delegate pictureDisplayView:self leftmost:YES rightmost:YES];
        }
        else
        {
            [delegate pictureDisplayView:self leftmost:NO rightmost:NO];
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
            cameraController.delegate = self;
            cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            cameraController.allowsEditing = YES;
            [imgEditViewController presentModalViewController:cameraController animated:YES];
        }
    }  else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
            photoController.delegate = self;
            photoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            photoController.allowsEditing = YES;
            [imgEditViewController presentModalViewController:photoController animated:YES];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

UIImage *uploadImg = nil;
NSString *imgType = @"";

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    uploadImg = [info objectForKey:UIImagePickerControllerEditedImage];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
        NSString *fileName = [asset.defaultRepresentation filename];
        NSString *fileType = [[fileName componentsSeparatedByString:@"."] objectAtIndex:1];
        imgType = [NSString stringWithFormat:@".%@", fileType];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error:%@  Address:%s", error.description, __FUNCTION__);
    }];
    [self performSelector:@selector(saveImage) withObject:nil afterDelay:0.5];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)saveImage
{
    [self removeImageViewWithIndex:imgCount animated:NO];
    [self addImageViewByImage:uploadImg type:imgType animated:YES];
    [self addAddButton];
}

@end
