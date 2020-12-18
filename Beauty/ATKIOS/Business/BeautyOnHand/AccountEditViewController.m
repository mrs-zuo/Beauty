//
//  AccountEditViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-12-10.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "AccountEditViewController.h"
#import "UIImageView+WebCache.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "AccountDoc.h"
#import "FooterView.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "AppDelegate.h"
#import "UIImage+Compress.h"
#import "UIImage+fixOrientation.h"
#import "LoginDoc.h"
#import "GPBHTTPClient.h" 
#import "NSData+Base64.h"
static UIImage  *localImage = nil;
static NSString *localImagType = nil;

@interface AccountEditViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *updateAccountOperation;
@property (strong, nonatomic) UITextField *textField_Selected;
@property (assign, nonatomic) CGFloat table_Height;
@property (strong, nonatomic) AccountDoc *accountDoc;
@property (strong, nonatomic) NSMutableArray *loginArray;
@end

@implementation AccountEditViewController
@synthesize textField_Selected;
@synthesize table_Height;
@synthesize accountDoc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_updateAccountOperation && [_updateAccountOperation isExecuting]) {
        [_updateAccountOperation cancel];
        _updateAccountOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
}

- (void)initTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"编辑基本信息"];
    [self.view addSubview:navigationView];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView  = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    table_Height = _tableView.frame.size.height;
    
    if (accountDoc == nil) {
        accountDoc = [[AccountDoc alloc]init];
        accountDoc.cos_CompanyID = ACC_COMPANTID;
        accountDoc.cos_UserID = ACC_ACCOUNTID;
        accountDoc.cos_Name  = ACC_ACCOUNTName;
        accountDoc.cos_Mobile = ACC_LAST_LoginMoblie;
        accountDoc.cos_HeadImgURL = ACC_ACCOUNTHeadImg;
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self
                                                      submitImg:[UIImage imageNamed:@"buttonLong_Confirm"]
                                                    submitTitle:@"确定"
                                                   submitAction:@selector(updateAccountHeadImage)];
    [footerView showInTableView:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)done
{
    [self dismissKeyBoard];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //解决ios8调用相机然后裁剪图片后，状态栏消失（调用拍照页面时，会自动隐藏状态栏，所有只要页面还在拍照页及后续调用的图片裁剪页，以下代码无效，所以需要在此处调用以显示状态栏）
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellIndentify = @"UpdateImgCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (70-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
        cell.backgroundColor = [UIColor whiteColor];

        UILabel *titleLabel    = (UILabel *)[cell viewWithTag:100];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
        titleLabel.font = kFont_Medium_16;
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.text = @"头像";
        [imageView setImageWithURL:[NSURL URLWithString:ACC_ACCOUNTHeadImg] placeholderImage:[UIImage imageNamed:@"loading_HeadImg80"]];
        return cell;
        
    } else if (indexPath.section == 1) {
        static NSString *cellIndentify = @"UpdatePwdCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow - 12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
        cell.backgroundColor = [UIColor whiteColor];
    
        UILabel *titleLabel    = (UILabel *)[cell viewWithTag:100];
        titleLabel.font = kFont_Medium_16;
        titleLabel.textColor = kColor_DarkBlue;
        titleLabel.text = @"修改密码";
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  indexPath.section == 0 ? 70.0f : kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"goAccountRalterPasswordViewFromSetView" sender:self];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"更换头像" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
        [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
                    cameraController.delegate = self;
                    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    cameraController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:cameraController animated:YES completion:^{}];
                }
            }  else if (buttonIndex == 1) {
                [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
                    photoController.delegate = self;
                    photoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    photoController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:photoController animated:YES completion:^{}];
                }
            }
        }];
       
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                NSString *fileName = [asset.defaultRepresentation filename];
                NSString *fileType = [[fileName componentsSeparatedByString:@"."] objectAtIndex:1];
                localImagType = [NSString stringWithFormat:@".%@", fileType];
            } failureBlock:^(NSError *error) {
                DLOG(@"Error:%@  Address:%s", error.description, __FUNCTION__);
            }];
        } else {
            localImagType = @".JPG";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateDidChangeWindowFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillComeOutImagePickerControllerNotification object:nil];
        GPImageEditorViewController *imageEditorVewController = [[GPImageEditorViewController alloc] init];
        imageEditorVewController.editImage = originImage;
        imageEditorVewController.delegate = self;
        [picker pushViewController:imageEditorVewController animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateDidChangeWindowFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillComeOutImagePickerControllerNotification object:nil];
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - GPImageEditorViewControllerDelegate

- (void)imageEditorViewController:(GPImageEditorViewController *)vController didEditedImage:(UIImage *)image
{
    UIImage *pressImg = [image scaleToSize:kImage_CompressSize];
    
    localImage =  [pressImg fixOrientation];
    UIImageView *imageView = (UIImageView *)[_tableView viewWithTag:101];
    imageView.image = localImage;
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateDidChangeWindowFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillComeOutImagePickerControllerNotification object:nil];
}

#pragma mark - When the keyboard display

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [keyboardValue getValue:&keyboardRect];
    
    
    NSValue *animationDurationValue = [notification userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGFloat off_Y = table_Height - keyboardRect.size.height + 50;
    CGRect rect = _tableView.frame;
    rect.size.height = off_Y;
    
    [UIView beginAnimations:@"showKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    _tableView.frame = rect;
    [UIView commitAnimations];
    
}

//恢复tableView的高度
- (void)restoreHeightOfTableView
{
    if (_tableView.frame.size.height != table_Height) {
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        CGRect tableFrame = _tableView.frame;
        tableFrame.size.height =  table_Height;
        _tableView.frame = tableFrame;
        [UIView commitAnimations];
    }
}

#pragma mark - 接口

- (void)updateAccountHeadImage
{
    if (localImagType.length == 0 || localImage == nil) {
        [SVProgressHUD showErrorWithStatus2:@"请选择一张图片!" duration:kSvhudtimer touchEventHandle:^{
            
        }];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *imgStr  = @"";
    if (localImage) {
        NSData *imgData = UIImageJPEGRepresentation(localImage, 0.3f);
        imgStr = [imgData base64EncodedString];
    }
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"UserID\":%ld,\"UserType\":%d,\"ImageString\":\"%@\",\"ImageType\":\"%@\",\"ImageHeight\":160,\"ImageWidth\":160}", (long)ACC_COMPANTID, (long)ACC_ACCOUNTID, 1, imgStr, localImagType];

    
    _updateAccountOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Image/updateUserHeadImage" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                NSLog(@"the data is class  %@", [data class]);
                if (data > 0) {
                    NSArray *comData = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_COMPANYLIST"];
                    NSMutableArray *mutableData = [NSMutableArray array]; //解决BranchList 为null崩溃的问题
                    if(_loginArray)
                        [ _loginArray removeAllObjects];
                    else
                        _loginArray = [[NSMutableArray alloc] init];
                    
                    NSInteger branchCount = 0;
                    NSInteger companyCount = 0;
                    for(NSDictionary *obj in comData){
                        NSMutableDictionary *mutableObj = [NSMutableDictionary dictionaryWithDictionary:obj]; //解决BranchList 为null崩溃的问题
                        LoginDoc *loginDoc = [[LoginDoc alloc]init];
                        loginDoc.accountId = [[obj objectForKey:@"AccountID"] integerValue];
                        loginDoc.companyId = [[obj objectForKey:@"CompanyID"] integerValue];
                        loginDoc.branchCount  = [[obj objectForKey:@"BranchCount"] integerValue];  // BranchID == 0 则没有BranchID
                        loginDoc.userName  = [obj objectForKey:@"AccountName"];
                        loginDoc.headImg   = [obj objectForKey:@"HeadImageURL"];
                        [mutableObj setValue:data forKey:@"HeadImageURL"];
                        loginDoc.companyCode = [obj objectForKey:@"CompanyCode"];
                        loginDoc.companyScale = [[obj objectForKey:@"CompanyScale"] integerValue];  // 0小店  1大店
                        loginDoc.moneyIcon = [obj objectForKey:@"CurrencySymbol"];
                        loginDoc.advanced = [obj objectForKey:@"Advanced"];
                        loginDoc.companyAbbreviation = [obj objectForKey:@"CompanyAbbreviation"];
                        loginDoc.branchList = [NSMutableArray array];
                        NSArray *branchArray = [obj objectForKey:@"BranchList"];
                        if ((NSNull *)branchArray == [NSNull null]){
                            [mutableObj setValue:nil forKey:@"BranchList"];
                            branchArray = nil;
                        }
                        for (NSDictionary * branch in branchArray){
                            BranchDoc *branchDoc = [[BranchDoc alloc] init];
                            branchDoc.branchId = [[branch objectForKey:@"BranchID"] integerValue];
                            branchDoc.branchName = [branch objectForKey:@"BranchName"];
                            [loginDoc.branchList addObject:branchDoc];
                            branchCount ++;
                        }
                        [mutableData addObject:mutableObj];
                        companyCount ++;
                        [_loginArray addObject:loginDoc];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:mutableData forKey:@"ACCOUNT_COMPANYLIST"]; //修改头像URL
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ACCOUNT_HEADIMAGE"]; //修改头像URL
                }
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    /*
    _updateAccountOperation = [[GPHTTPClient shareClient] requestUpdateAccountWithHeadImage:localImage imageType:localImagType success:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if ([contentData stringValue].length > 0) {
                NSArray *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_COMPANYLIST"];
                NSMutableArray *mutableData = [NSMutableArray array]; //解决BranchList 为null崩溃的问题
                
                if(_loginArray)
                    [ _loginArray removeAllObjects];
                else
                    _loginArray = [[NSMutableArray alloc] init];
                
                NSInteger branchCount = 0;
                NSInteger companyCount = 0;
                for(NSDictionary *obj in data){
                    NSMutableDictionary *mutableObj = [NSMutableDictionary dictionaryWithDictionary:obj]; //解决BranchList 为null崩溃的问题
                    LoginDoc *loginDoc = [[LoginDoc alloc]init];
                    loginDoc.accountId = [[obj objectForKey:@"AccountID"] integerValue];
                    loginDoc.companyId = [[obj objectForKey:@"CompanyID"] integerValue];
                    loginDoc.branchCount  = [[obj objectForKey:@"BranchCount"] integerValue];  // BranchID == 0 则没有BranchID
                    loginDoc.userName  = [obj objectForKey:@"AccountName"];
                    loginDoc.headImg   = [obj objectForKey:@"HeadImageURL"];
                    [mutableObj setValue:contentData.stringValue forKey:@"HeadImageURL"];
                    loginDoc.companyCode = [obj objectForKey:@"CompanyCode"];
                    loginDoc.companyScale = [[obj objectForKey:@"CompanyScale"] integerValue];  // 0小店  1大店
                    loginDoc.moneyIcon = [obj objectForKey:@"CurrencySymbol"];
                    loginDoc.advanced = [obj objectForKey:@"Advanced"];
                    loginDoc.companyAbbreviation = [obj objectForKey:@"CompanyAbbreviation"];
                    loginDoc.branchList = [NSMutableArray array];
                    NSArray *branchArray = [obj objectForKey:@"BranchList"];
                    if ((NSNull *)branchArray == [NSNull null]){
                        [mutableObj setValue:nil forKey:@"BranchList"];
                        branchArray = nil;
                    }
                    for (NSDictionary * branch in branchArray){
                        BranchDoc *branchDoc = [[BranchDoc alloc] init];
                        branchDoc.branchId = [[branch objectForKey:@"BranchID"] integerValue];
                        branchDoc.branchName = [branch objectForKey:@"BranchName"];
                        [loginDoc.branchList addObject:branchDoc];
                        branchCount ++;
                    }
                    [mutableData addObject:mutableObj];
                    companyCount ++;
                    [_loginArray addObject:loginDoc];
                }
                [[NSUserDefaults standardUserDefaults] setObject:mutableData forKey:@"ACCOUNT_COMPANYLIST"]; //修改头像URL
                [[NSUserDefaults standardUserDefaults] setObject:contentData.stringValue forKey:@"ACCOUNT_HEADIMAGE"]; //修改头像URL
            }
        } failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}

@end
