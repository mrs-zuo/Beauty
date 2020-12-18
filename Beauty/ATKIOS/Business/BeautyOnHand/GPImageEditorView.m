//
//  GPImageEditorView.h
//  GPImageEditorView.m
//
//  Created by TRY-MAC01 on 13-10-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "GPImageEditorView.h"
#import "GPImageEditorViewController.h"
#import "DEFINE.h"
#import "UIImage+fixOrientation.h"
#define DATA_FOLDER_NAME @"AAA"


typedef NSUInteger AGMovementType;

@interface GPImageEditorView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *ratioView;
@property (nonatomic, strong) UIView *ratioControlsView;
@property (nonatomic, assign) CGFloat ratio;
@end

@implementation GPImageEditorView
@synthesize imageView, overlayView, ratioView, ratioControlsView;
@synthesize image, ratio;
@synthesize animationDuration;
@synthesize maxSize;
@synthesize viewController;

- (id)initWithImage:(UIImage *)theImage
{
    return [self initWithImage:theImage andFrame:[[UIScreen mainScreen] bounds]];
}

- (id)initWithImage:(UIImage *)theImage andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.image = theImage;
        [self initialize];
        self.maxSize = CGSizeMake(800.0f, 800.0f);
    }
    return self;
}

- (void)initialize
{
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    
    ratioControlsView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:ratioControlsView];
    
    // Overlay
    overlayView = [[UIView alloc] initWithFrame:ratioControlsView.bounds];
    overlayView.alpha = 0.6;
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.userInteractionEnabled = NO;
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [ratioControlsView addSubview:overlayView];
    
    // Ratio view
    ratioView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 60.0f, 320.0f, 320.0f)];
    ratioView.autoresizingMask = UIViewAutoresizingNone;
    [ratioControlsView addSubview:ratioView];
    ratioView.layer.borderWidth = 1.0f;
    ratioView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [ratioView addGestureRecognizer:panGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [ratioView addGestureRecognizer:pinchGestureRecognizer];
    
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleButton setFrame:CGRectMake(10.0f , [UIScreen mainScreen].bounds.size.height - 70.0f, 80.0f, 35.0f)];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [ratioControlsView addSubview:cancleButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setFrame:CGRectMake(230.0f , [UIScreen mainScreen].bounds.size.height - 70.0f, 80.0f, 35.0f)];
    [confirmButton setTitle:@"选取" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [ratioControlsView addSubview:confirmButton];
    
    
    // --init Data
    
    DLOG(@"x:%f  y:%f  w:%f  h:%f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height );
    imageView.image = image;

    CGRect imgRect = imageView.frame;
    imgRect.size = image.size;
    imageView.frame = imgRect;
    
    CGPoint ratioCenter = [ratioView convertPoint:ratioView.center toView:self];
    imageView.center = ratioCenter;
    
     DLOG(@"x:%f  y:%f  w:%f  h:%f", imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height );
    
    // configrm
    [self overlayClipping];
}

- (void)setMaxSize:(CGSize)_maxSize
{
    maxSize = _maxSize;
    CGSize imageSize = self.image.size;
    float minPIX = MIN(imageSize.width, imageSize.height);
    
     maxSize = CGSizeMake(minPIX, minPIX);

    ratio = minPIX / 320.0f;  // 该图片缩小的倍数
    imageView.transform  = CGAffineTransformScale(imageView.transform, 1.0f/ratio, 1.0f/ratio);
}

- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    
    // Left side
    CGPathAddRect(path, nil, CGRectMake(0,
                                        0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side
    CGPathAddRect(path, nil, CGRectMake(0,
                                        0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    // Bottom side
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

- (void)goBack
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [viewController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)confirmAction
{
    
    
    if (viewController) {
        if ([viewController.delegate respondsToSelector:@selector(imageEditorViewController:didEditedImage:)]) {
            [viewController.delegate imageEditorViewController:viewController didEditedImage:self.output];
        }
    }
    
//   self.imageView.image = self.output;
//  
//    NSString *newURLStr2 = [NSString stringWithFormat:@"%@.jpg", [[NSDate date] description]];
//    NSString *plistPath = [[self returnDataCachePath] stringByAppendingPathComponent:newURLStr2];
//    NSData *data = UIImageJPEGRepresentation(self.output, 1);
//    [data writeToFile:plistPath atomically:YES];
    
    [self goBack];
}

- (NSString *)returnDataCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *cachePath = [path stringByAppendingPathComponent:DATA_FOLDER_NAME];
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    if (![fileManger fileExistsAtPath:cachePath]) {
        [fileManger createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return cachePath;
}

#pragma mark - Crop

- (UIImage *)output
{
    UIImage *croppedImage = [self croppedImage:self.imageView.image];
    return croppedImage;
}

- (UIImage *)croppedImage:(UIImage *)imageToCrop
{
//    CFDataRef dataRef1 = (__bridge CFDataRef)(UIImageJPEGRepresentation(imageToCrop, 1.0f));
//    CGImageSourceRef imageRef1 = CGImageSourceCreateWithData(dataRef1, NULL);
//    NSDictionary *dict1 = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageRef1, 0, NULL);
//    NSInteger currentOrientation1 = [[dict1 valueForKey:(NSString*)kCGImagePropertyOrientation] intValue];
//    DLOG(@"%@", dict1);
    
    UIImage *newImageToCrop = [imageToCrop fixOrientation];
    
    CGRect rec0 = ratioView.frame;
    CGRect rec1 = imageView.frame;
    CGRect rect;
    rect.origin.x = (rec0.origin.x - rec1.origin.x) * ratio; // why conventWithPoint:toView:不能用
    rect.origin.y = (rec0.origin.y - rec1.origin.y) * ratio;
    rect.size.width  = 320 * ratio;
    rect.size.height = 320 * ratio;
    CGRect scaledImageRect = rect;

    UIImage *outputImage = nil;
    CGImageRef imageRef = CGImageCreateWithImageInRect(newImageToCrop.CGImage, scaledImageRect);
    outputImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return outputImage;
}


#pragma mark -

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.ratioView];
    
    CGRect rect = self.imageView.frame;
    rect.origin.y += translation.y;
    rect.origin.x += translation.x;
    
    DLOG(@"tran x:%f        y:%f", translation.x, translation.y);
    DLOG(@"imge x:%f        y:%f", rect.origin.x, rect.origin.y);
    
//    if (translation.x < 0)  // 向左
//    {
//        if (rect.origin.x < 0) rect.origin.x = 0.0f;
//    }
//    
//    if (translation.x > 0)  // 向右
//    {
//        if (rect.origin.x > 0) rect.origin.x = 0.0f;
//    }
//    
//    if (translation.y < 0) { // 向上
//       if (rect.origin.y < 0) rect.origin.y = 0.0f;
//    }
//    
//    if (translation.y > 0) // 向下
//    {
//      if (rect.origin.y > 120) rect.origin.y = 120.0f;
//    }
    [self.imageView setFrame:rect];
    
     DLOG(@"x:%f y:%f", self.imageView.frame.origin.x, self.imageView.frame.origin.y);

    [recognizer setTranslation:CGPointMake(0, 0) inView:self.ratioView];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    float scale = recognizer.scale;
    self.ratio = ratio / scale;
    imageView.transform  = CGAffineTransformScale(imageView.transform, scale, scale);
    
    recognizer.scale = 1.0;
}

@end
