//
//  MyProfielEdit_ViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/10/13.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "MyProfielEdit_ViewController.h"
#import "VPImageCropperViewController.h"


#define ORIGINAL_MAX_WIDTH 640.0f

@interface MyProfielEdit_ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic ,assign) NSInteger chooseGirl;
@property (nonatomic,strong) UITableView *myTableView;
@property (weak, nonatomic) AFHTTPRequestOperation *requestProfeil;
@property (weak, nonatomic) AFHTTPRequestOperation *requestMyProfiel;
@property (nonatomic ,strong) UIImage * headerImage;

@end

@implementation MyProfielEdit_ViewController
@synthesize myTableView;

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    self.title = @"修改资料";
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    [self initTableView];
    
    self.chooseGirl = self.gender;
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height - 49)];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];
    
 
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, 320.0f, 49.0f)];

    [self.view addSubview:footView];
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    
    UIButton *add_Button = [UIButton buttonWithTitle:@"保存"
                                              target:self
                                            selector:@selector(commitAction:)
                                               frame:CGRectMake(5,5, kSCREN_BOUNDS.size.width - 10, 39.0)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    add_Button.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
    add_Button.titleLabel.font=kNormalFont_14;
    [footView addSubview:add_Button];
    
    self.headerImage = nil;
}

-(void)commitAction:(UIButton *)sender
{
    
    if (self.customerName.length ==0 || [self.customerName isKindOfClass:[NSNull class]]) {
        [SVProgressHUD showSuccessWithStatus2:@"姓名不能为空!"];
        return;
    }
    [self changePhotoWith:self.headerImage];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 70;
    } else {
        return kTableView_DefaultCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentify = [NSString stringWithFormat:@"cell_%@",indexPath];
    NormalEditCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.userInteractionEnabled = NO;
    }else
    {
        [cell removeFromSuperview];
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.userInteractionEnabled = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
        {
            cell.titleLabel.frame = CGRectMake(10, 0, 130, 65);
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(300, (70 -12)/2, 10, 12)];
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [cell.contentView addSubview:arrowsImage];
            cell.titleLabel.text = @"头像";
            cell.valueText.text= @"";
            
            UIImageView *portraitImageView = (UIImageView *)[cell.contentView viewWithTag:1000];
            if (!portraitImageView) {
                portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(235, 5, 60, 60)];
                if (IOS6) {
                    [portraitImageView setFrame:CGRectMake(230, 5, 60, 60)];
                }
                portraitImageView.tag = 1000;
                portraitImageView.layer.masksToBounds = YES;
                portraitImageView.layer.cornerRadius = CGRectGetHeight(portraitImageView.bounds) / 2;
                [cell.contentView addSubview:portraitImageView];
            }
            [portraitImageView setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults]objectForKey:@"CUSTOMER_HEADIMAGE"]] placeholderImage:[UIImage imageNamed:@"People-default"]];
            
            if (self.headerImage) {
                portraitImageView.image = self.headerImage;
            }
        }
            break;
        case 1:
        {
            cell.titleLabel.text = @"姓名";
            cell.valueText.text= self.customerName;
            cell.valueText.delegate = self;
            cell.valueText.userInteractionEnabled = YES;
        }
            break;
        case 2:
        {
            cell.titleLabel.text = @"性别";
            cell.valueText.text= @"";
            UIButton * sexBoyBt = (UIButton *)[cell.contentView viewWithTag:5001];
            if (!sexBoyBt) {
                sexBoyBt =[[UIButton alloc] initWithFrame:CGRectMake(180, 10, 30, 30)];
                [sexBoyBt setImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
                [sexBoyBt setImage:[UIImage imageNamed:@"icon_Selected"] forState:UIControlStateSelected];
                sexBoyBt.tag = 5001;
                [sexBoyBt addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:sexBoyBt];
            }
            
            UILabel *boylLable = [[UILabel alloc] initWithFrame:CGRectMake(220, 15, 20, kLabel_DefaultHeight)];
            boylLable.text = @"男";
            [cell.contentView addSubview:boylLable];

            UIButton * sexGirlBt = (UIButton *)[cell.contentView viewWithTag:5002];
            if (!sexGirlBt) {
                sexGirlBt =[[UIButton alloc] initWithFrame:CGRectMake(250, 10, 30, 30)];
                [sexGirlBt setImage:[UIImage imageNamed:@"icon_unSelected"] forState:UIControlStateNormal];
                [sexGirlBt setImage:[UIImage imageNamed:@"icon_Selected"] forState:UIControlStateSelected];
                sexGirlBt.tag = 5002;
                [sexGirlBt addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
                sexGirlBt.selected = NO;
                sexGirlBt.tag = 1;
                [cell.contentView addSubview:sexGirlBt];
            }
            
            UILabel *girlLable = [[UILabel alloc] initWithFrame:CGRectMake(290, 15, 20, kLabel_DefaultHeight)];
            girlLable.text = @"女";
            [cell.contentView addSubview:girlLable];
            
            sexBoyBt.tag = 2;
            sexBoyBt.selected = NO;
            if (self.chooseGirl) {//为1选择为男
                sexBoyBt.selected = YES;
            }else{//为0选择为女
                sexGirlBt.selected = YES;
            }
        }
            break;
            
        default:
            break;
    }
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        [choiceSheet showInView:self.view];
    }
}

//choose sex
-(void)chooseSex:(UIButton *)sender
{
    if (sender.tag ==1) {//女
        self.chooseGirl = 0;
    }else//男
    {
        self.chooseGirl = 1;
    }
    [myTableView reloadData];
}


- (void)changePhotoWith:(UIImage *)image
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSData *imageData = UIImageJPEGRepresentation([self scaleToSize:image size:CGSizeMake(1280, 1280)], 0.3);
    NSString *imageString = [imageData base64Encoding];
    
    NSDictionary *para;
    if (!self.headerImage) {
        
        para = @{
                 @"CustomerName":self.customerName,
                 @"Gender":@(self.chooseGirl),
                 };

    }else
    {
        para = @{@"CustomerName":self.customerName,
                 @"Gender":@(self.chooseGirl),
                 @"HeadFlag":@1,
                 @"ImageType":@".jpg",
                 @"ImageString":imageString
                 };
    }
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    _requestProfeil = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Customer/updateCustomerBasic"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"修改资料成功"];
            [self getMyProfiel];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSInteger code, NSString *error) {
             [SVProgressHUD showSuccessWithStatus2:error];
            
        }];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        
    }];
}


-(void)getMyProfiel{
    
    NSDictionary * para = @{@"ImageHeight":@160,@"ImageWidth":@160};
    _requestMyProfiel = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Customer/getCustomerBasic"  showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message){
            
            [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:@"HeadImageURL"] forKey:@"CUSTOMER_HEADIMAGE"];
             [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:@"CustomerName"] forKey:@"CUSTOMER_SELFNAME"];
            //[SVProgressHUD showSuccessWithStatus2:@"修改资料成功"];
            
            
        }failure:^(NSInteger code, NSString *error) {
            
        }];

    } failure:^(NSError *error) {
        
    }];
    
}


#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        self.headerImage = editedImage;
        [myTableView reloadData];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController
{
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    portraitImg = [self imageByScalingToMaxSize:portraitImg];
    // 裁剪
    VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
    imgEditorVC.delegate = self;
    [picker pushViewController:imgEditorVC animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^(){
        
    }];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //留用
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //留用
}

#pragma mark - camera utility

- (BOOL)isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL)isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL)doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)isPhotoLibraryAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)canUserPickVideosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)canUserPickPhotosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark - image scale utility

- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark TextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textField.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    }
    
    return YES;

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:textField];
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString =  textField.text;
    
    if (toBeString.length > 20)
        textField.text = [toBeString substringToIndex:20];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:textField];
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textField.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    }
    
    self.customerName = textField.text;
    [myTableView reloadData];
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}



@end
