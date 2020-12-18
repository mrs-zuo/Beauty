//
//  SetViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-9-9.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "SetViewController.h"
#import "UIButton+InitButton.h"
#import "GDataXMLDocument+ParseXML.h"
#import "LoginDoc.h"
#import "ChooseCompanyViewController.h"
#import "UIImageView+WebCache.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import <ShareSDK/ShareSDK.h>
#import "MyProfiel_ViewController.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface SetViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestChangeCustomerPhotoOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getVersionOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestLogoutOperation;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSMutableArray *loginArray;
@end

@implementation SetViewController
@synthesize titleArray;
@synthesize loginArray;

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.view.backgroundColor = kDefaultBackgroundColor;
    self.title = @"设置";
    
    [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20 - 5)];
    titleArray = [NSArray arrayWithObjects:@"密码修改", nil];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = kColor_Clear;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestChangeCustomerPhotoOperation || [_requestChangeCustomerPhotoOperation isExecuting]) {
        [_requestChangeCustomerPhotoOperation cancel];
        _requestChangeCustomerPhotoOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kTableView_WithTitle;
    } else {
        return kTableView_Margin;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_COMPANYLIST"];
    self.loginArray = [NSMutableArray array];
    
    for (NSDictionary *dict in data) {
        LoginDoc *loginDoc = [[LoginDoc alloc] init];
        [loginDoc setValuesForKeysWithDictionary:dict];
        [self.loginArray addObject:loginDoc];
    }
  
    if (loginArray.count == 1) {
        return 4;
    } else {
        return 5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_DefaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"SetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryView.backgroundColor = kColor_TitlePink;
        cell.textLabel.font = kNormalFont_14;
        cell.textLabel.textColor = kColor_TitlePink;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    UILabel *quitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 320, 20)];
    quitLabel.textColor = kColor_TitlePink;
    quitLabel.backgroundColor = [UIColor clearColor];
    quitLabel.textAlignment = NSTextAlignmentCenter;
    quitLabel.font = kNormalFont_14;
    static NSString *quitCellIndentify = @"QuitSetCell";
    UITableViewCell *quitCell = [tableView dequeueReusableCellWithIdentifier:quitCellIndentify];
    if (quitCell == nil) {
        quitCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:quitCellIndentify];
        quitCell.accessoryType = UITableViewCellAccessoryNone;
        quitCell.selectionStyle = UITableViewCellSelectionStyleGray;
        quitCell.accessoryView.backgroundColor = kColor_TitlePink;
        quitCell.backgroundColor = [UIColor whiteColor];
        [quitCell addSubview:quitLabel];
    }
    
    if (loginArray.count == 1) {
        if (indexPath.section == 0) {
            cell.textLabel.text = @"我的资料";
            return cell;
        } else if (indexPath.section == 1) {
            cell.textLabel.text = @"密码修改";
            return cell;
        }
        else if(indexPath.section == 2) {
            cell.textLabel.text = @"关于我们";
            return cell;
        } else {
            quitCell.backgroundColor = [UIColor clearColor];
            UIView * pinkView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, kSCREN_BOUNDS.size.width -10, kTableView_DefaultCellHeight)];
            pinkView.backgroundColor = kMainPinkColor;
            [quitCell.contentView addSubview:pinkView];
            quitLabel.text = @"登出当前账号";
            quitLabel.textColor = [UIColor whiteColor];
            return quitCell;
        }
    } else {
        if (indexPath.section == 0) {
            cell.textLabel.text = @"我的资料";
            return cell;
        } else if (indexPath.section == 1) {
            cell.textLabel.text = @"密码修改";
            return cell;
        } else if(indexPath.section == 2) {
            cell.textLabel.text = @"商家切换";
            return cell;
        }
        else if(indexPath.section == 3) {
            cell.textLabel.text = @"关于我们";
            return cell;
        } else {
            quitCell.backgroundColor = [UIColor clearColor];
            UIView * pinkView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, kSCREN_BOUNDS.size.width -10, kTableView_DefaultCellHeight)];
            pinkView.backgroundColor = kMainPinkColor;
            [quitCell.contentView addSubview:pinkView];
            quitLabel.text = @"登出当前账号";
            quitLabel.textColor = [UIColor whiteColor];
            return quitCell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;

    if (loginArray.count == 1) {
        if (indexPath.section == 0) {
            MyProfiel_ViewController * profiel = [[MyProfiel_ViewController alloc] init];
            [self.navigationController pushViewController:profiel animated:YES];
            
        } else if(indexPath.section == 1) {
            [self performSegueWithIdentifier:@"goCustomeRalterPasswordViewFromSetView" sender:self];
        } else if (indexPath.section == 2){
            [self performSegueWithIdentifier:@"goAboutUsViewFromSetView" sender:self];
        }else {
            [self cancelOrderAction];
        }
    } else {
        if (indexPath.section == 0) {
            MyProfiel_ViewController * profiel = [[MyProfiel_ViewController alloc] init];
            [self.navigationController pushViewController:profiel animated:YES];
        } else if(indexPath.section == 1) {
            [self performSegueWithIdentifier:@"goCustomeRalterPasswordViewFromSetView" sender:self];
        } else if (indexPath.section == 3){
            [self performSegueWithIdentifier:@"goAboutUsViewFromSetView" sender:self];
        } else if (indexPath.section == 2){
            [self performSegueWithIdentifier:@"goChooseCompanyViewFromSetView" sender:self];
        }
        else {
            [self cancelOrderAction];
        }
    }
}

#pragma mark - 页面切换

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goChooseCompanyViewFromSetView"]) {
        ChooseCompanyViewController *detailController = segue.destinationViewController;
        detailController.loginArray = loginArray;
        detailController.pwdBase64 =    [[NSUserDefaults standardUserDefaults]objectForKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
        detailController.nameBase64  =   [[NSUserDefaults standardUserDefaults]objectForKey:@"LAST_LOGIN_CUSTOMUSERNAME"];
        detailController.loginType = NO;
    }
}	

#pragma mark - cancelAction

- (void)cancelOrderAction
{
    UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确认登出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self logout];
    }
}

#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        [self changePhotoWith:editedImage];
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
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
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
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NarBaClient"] forBarMetrics:UIBarMetricsDefault];
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    portraitImg = [self imageByScalingToMaxSize:portraitImg];
    // 裁剪
    VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
    imgEditorVC.delegate = self;
    [picker pushViewController:imgEditorVC animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NarBaClient"] forBarMetrics:UIBarMetricsDefault];
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

#pragma mark - 接口
// 获取程序最新版本
- (void)requestAppVersion
{
    NSString *version = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString *database = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DATABASE"];
    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString forKey:@"CUSTOMER_DATABASE"];
    
    NSDictionary *para =@{@"DeviceType":@0,
                          @"ClientType":@1,
                          @"CurrentVersion":version};
    _getVersionOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/version/getServerVersion"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [[NSUserDefaults standardUserDefaults] setObject:database forKey:@"CUSTOMER_DATABASE"];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            NSString *version = data[@"Version"] == [NSNull null] ? @"":data[@"Version"];
            NSInteger mustUpgrade = [data[@"MustUpgrade"] integerValue];
            appDelegate.isShowVersionUpdate = 0; //需要显示升级提示框（解决不点击升级框，直接切换到后台后再激活程序，会多次弹出升级框）
            
            if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] == NSOrderedDescending) {
                if (mustUpgrade == 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新版本，是否升级？" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/mei-li-yue-ding/id787185607"]];
                        }
                    }];
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/mei-li-yue-ding/id787185607"]];
                        }else
                            exit(0);
                    }];
                }
            } else if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] == NSOrderedSame){
                [SVProgressHUD showSuccessWithStatus2:@"已经是最新版了！"];
                [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"CUSTOMER_MUSTUPDATE"];
            }else{
                [SVProgressHUD showSuccessWithStatus2:@"已经是最新版了！"];
                [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"CUSTOMER_MUSTUPDATE"];
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:database forKey:@"CUSTOMER_DATABASE"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的网络貌似不给力，\n请检查网络设置" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
    }];

}
- (void)changePhotoWith:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation([self scaleToSize:image size:CGSizeMake(1280, 1280)], 0.3);
    NSString *imageString = [imageData base64Encoding];

    NSDictionary *para = @{@"ImageString":imageString,
                           @"ImageType":@".jpg",
                           @"ImageWidth":@1280,
                           @"ImageHeight":@1280};
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    _requestChangeCustomerPhotoOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/updateUserHeadImage"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:1000];
            [imageView setImageWithURL:[NSURL URLWithString:data] placeholderImage:[UIImage imageNamed:@"People-default"]];
            
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"CUSTOMER_HEADIMAGE"];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {

    }];
}


-(void)logout
{
    [SVProgressHUD showWithStatus:@"Loading"];
    //退出的时候，注销注册的微博和微信
    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiFav];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiSession];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiTimeline];
    _requestLogoutOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Login/Logout"  showErrorMsg:NO  parameters:nil WithSuccess:^(id json) {

    } failure:^(NSError *error) {
    }];
    [self clearAndOut];
}

-(void)clearAndOut
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_USERID"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYID"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHID"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHCOUNT"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYCODE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYABBREVIATION"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_SELFNAME"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_HEADIMAGE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DISCOUNT"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DATABASE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYSCALE"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PROMOTION"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_REMINDCOUNT"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYLIST"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PAYCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CONFIRMCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CURRENCYTOKEN"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_ADVANCED"];
    [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"isAutoLogin"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"login_selected_compmay"];
    
    LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:loginVC animated:YES completion:^{
        
    }];
    
    [SVProgressHUD dismiss];
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
