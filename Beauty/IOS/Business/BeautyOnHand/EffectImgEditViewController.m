//
//  EffectImgEditViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-22.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "EffectImgEditViewController.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "UILabel+InitLabel.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "UIImage+Compress.h"
#import "GPBHTTPClient.h"


@implementation EffectImgDoc

@end

#define IMG_SCROLL_LEFT_0 [UIImage imageNamed:@"imgScroll_L0"]
#define IMG_SCROLL_LEFT_1 [UIImage imageNamed:@"imgScroll_L1"]
#define IMG_SCROLL_RIGHT_0 [UIImage imageNamed:@"imgScroll_R0"]
#define IMG_SCROLL_RIGHT_1 [UIImage imageNamed:@"imgScroll_R1"]

@interface EffectImgEditViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *uploadImageOperation;
// -- view
@property (strong, nonatomic) UIButton *beforePrevBtn;
@property (strong, nonatomic) UIButton *beforeNextBtn;
@property (strong, nonatomic) UIButton *afterPervBtn;
@property (strong, nonatomic) UIButton *afterNextBtn;
@property (strong, nonatomic) NSArray *beforeArray;
@property (strong, nonatomic) NSArray *afterArray;
@property (strong, nonatomic) PictureDisplayView *beforePictureDisplayView;
@property (strong, nonatomic) PictureDisplayView *afterPictureDisplayView;
@end

@implementation EffectImgEditViewController
@synthesize beforeEffectArray;
@synthesize afterEffectArray;
@synthesize beforePrevBtn, beforeNextBtn, beforePictureDisplayView;
@synthesize afterPervBtn, afterNextBtn, afterPictureDisplayView;
@synthesize treat_ID;
@synthesize afterArray, beforeArray;
@synthesize groupNo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)setBeforeEffectArray:(NSMutableArray *)_beforeEffectArray
{
    beforeEffectArray = _beforeEffectArray;
    
    NSMutableArray *tmpBeforArray = [NSMutableArray array];
    for (EffectImgDoc *effectDoc in beforeEffectArray) {
        [tmpBeforArray addObject:effectDoc.imageURL];
    }
    beforeArray = tmpBeforArray;
}

- (void)setAfterEffectArray:(NSMutableArray *)_afterEffectArray
{
    afterEffectArray = _afterEffectArray;
    
    NSMutableArray *tmpBeforArray = [NSMutableArray array];
    for (EffectImgDoc *effectDoc in afterEffectArray) {
        [tmpBeforArray addObject:effectDoc.imageURL];
    }
    afterArray = tmpBeforArray;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //解决ios8调用相机然后裁剪图片后，状态栏消失（调用拍照页面时，会自动隐藏状态栏，所有只要页面还在拍照页及后续调用的图片裁剪页，以下代码无效，所以需要在此处调用以显示状态栏）
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    NSString *title;
    switch (self.effectType) {
        case EffectImgEditViewControllerType_TG:
        {
                title = @"服务效果编辑";
        }
            break;
        case EffectImgEditViewControllerType_TM:
        {
            title = @"操作效果编辑";

        }
            break;
            
        default:
            break;
    }
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:title];
    [self.view addSubview:navigationView];
    
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
         _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(uploadEffectImg)];
    [footerView showInTableView:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        NSString *cellIdentity = @"titleCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
            cell.backgroundColor = [UIColor whiteColor];
        }
        cell.textLabel.font = kFont_Medium_16;
        cell.textLabel.textColor = kColor_DarkBlue;
        
        if (indexPath.section == 0) {
            cell.textLabel.text = @"操作前照片";
        } else {
            cell.textLabel.text = @"操作后照片";
        }
        return cell;
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        
        NSString *cellIdentity = @"beforeCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.backgroundColor = [UIColor whiteColor];
        
        beforePrevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [beforePrevBtn setFrame:CGRectMake(0.0f, 40.0f, 14.0f, 20.0f)];
        [beforePrevBtn setBackgroundImage:IMG_SCROLL_LEFT_1 forState:UIControlStateNormal];
        [beforePrevBtn setBackgroundImage:IMG_SCROLL_LEFT_0 forState:UIControlStateSelected];
        [beforePrevBtn addTarget:self action:@selector(beforePreviousAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:beforePrevBtn];
        [beforePrevBtn setSelected:YES];
        
        beforeNextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [beforeNextBtn setFrame:CGRectMake(310.0f - 14.0f, 40.0f, 14.0f, 20.0f)];
        [beforeNextBtn setBackgroundImage:IMG_SCROLL_RIGHT_1 forState:UIControlStateNormal];
        [beforeNextBtn setBackgroundImage:IMG_SCROLL_RIGHT_0 forState:UIControlStateSelected];
        [beforeNextBtn addTarget:self action:@selector(beforeNextAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:beforeNextBtn];
        
        beforePictureDisplayView = [[PictureDisplayView alloc] initWithFrame:CGRectMake(25.0f, 0.0f, 260.0f, 100.0f) picSize:CGSizeMake(80.0f, 80.0f) spacing:10.0f];
        [beforePictureDisplayView setPicturesWithURLs:beforeArray];
        [beforePictureDisplayView setIsEditing:YES];
        [beforePictureDisplayView setImgEditViewController:self];
        [beforePictureDisplayView setDelegate:self];
        [cell.contentView addSubview:beforePictureDisplayView];
        return cell;
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        
        NSString *cellIdentity = @"afterCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.backgroundColor = [UIColor whiteColor];
        
        afterPervBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [afterPervBtn setFrame:CGRectMake(0.0f, 40.0f, 14.0f, 20.0f)];
        [afterPervBtn setBackgroundImage:IMG_SCROLL_LEFT_1 forState:UIControlStateNormal];
        [afterPervBtn setBackgroundImage:IMG_SCROLL_LEFT_0 forState:UIControlStateSelected];
        [afterPervBtn addTarget:self action:@selector(afterPreviousAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:afterPervBtn];
        [afterPervBtn setSelected:YES];
        
        afterNextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [afterNextBtn setFrame:CGRectMake(310.0f - 14.0f, 40.0f, 14.0f, 20.0f)];
        [afterNextBtn setBackgroundImage:IMG_SCROLL_RIGHT_1 forState:UIControlStateNormal];
        [afterNextBtn setBackgroundImage:IMG_SCROLL_RIGHT_0 forState:UIControlStateSelected];
        [afterNextBtn addTarget:self action:@selector(afterNextAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:afterNextBtn];
        
        afterPictureDisplayView = [[PictureDisplayView alloc] initWithFrame:CGRectMake(25.0f, 0.0f, 260.0f, 100.0f) picSize:CGSizeMake(80.0f, 80.0f) spacing:10.0f];
        [afterPictureDisplayView setPicturesWithURLs:afterArray];
        [afterPictureDisplayView setDelegate:self];
        [afterPictureDisplayView setIsEditing:YES];
        [afterPictureDisplayView setImgEditViewController:self];
        [cell.contentView addSubview:afterPictureDisplayView];
        return cell;
    }
    return nil;
}

- (void)beforePreviousAction:(id)sender
{
    [beforePictureDisplayView scrollToPreviouPicture];
}

- (void)beforeNextAction:(id)sender
{
    [beforePictureDisplayView scrollToNextPicture];
}

- (void)afterPreviousAction:(id)sender
{
    [afterPictureDisplayView scrollToPreviouPicture];
}

- (void)afterNextAction:(id)sender
{
    [afterPictureDisplayView scrollToNextPicture];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return kTableView_HeightOfRow;
    } else {
        return 100.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}


#pragma mark - PictureDisplayViewDelegate

- (void)pictureDisplayView:(PictureDisplayView *)pictureDisplayView leftmost:(BOOL)isLeftmost rightmost:(BOOL)isRightmost
{
    if (pictureDisplayView == beforePictureDisplayView) {
        [beforePrevBtn setSelected:isLeftmost];
        [beforeNextBtn setSelected:isRightmost];
    } else if (pictureDisplayView == afterPictureDisplayView) {
        [afterPervBtn setSelected:isLeftmost];
        [afterNextBtn setSelected:isRightmost];
    }
}

#pragma mark - Upload Image
- (void)uploadEffectImg
{
    // before
    NSArray *before_deleteImgArray = [beforePictureDisplayView getDeleteImageURLsArray];
    NSArray *before_uploadImgArray = [beforePictureDisplayView getUploadImagesAndTypes];
    
    NSArray *after_deleteImgArray = [afterPictureDisplayView getDeleteImageURLsArray];
    NSArray *after_uploadImgArray = [afterPictureDisplayView getUploadImagesAndTypes];
    
    // -- 删除图片 拼接ImageIDXML
    NSMutableArray *dele_ImgID = [NSMutableArray array];
    for (NSString *imgUrl in before_deleteImgArray) {
        for (EffectImgDoc *effImg in beforeEffectArray) {
            if ([imgUrl isEqualToString:effImg.imageURL]) {
                [dele_ImgID addObject:[NSString stringWithFormat:@"{\"ImageID\":%ld}", (long)effImg.imageID]];
            }
        }
    }
    
    for (NSString *imgUrl in after_deleteImgArray) {
        for (EffectImgDoc *effImg in afterEffectArray) {
            if ([imgUrl isEqualToString:effImg.imageURL]) {
                [dele_ImgID addObject:[NSString stringWithFormat:@"{\"ImageID\":%ld}", (long)effImg.imageID]];
            }
        }
    }

    
    
//    NSMutableString *delete_ImgXML = [NSMutableString string];
//    for (NSString *str in before_deleteImgArray) {
//        for (EffectImgDoc *effectImg in beforeEffectArray) {
//            if ([str isEqualToString:effectImg.imageURL]) {
//                GDataXMLElement *imageEle = [GDataXMLElement elementWithName:@"ImageID" stringValue:[NSString stringWithFormat:@"%ld", (long)effectImg.imageID]];
//                [delete_ImgXML appendString:[imageEle XMLString]];
//            }
//        }
//    }
//    
//    for (NSString *str in after_deleteImgArray) {
//        for (EffectImgDoc *effectImg in afterEffectArray) {
//            if ([str isEqualToString:effectImg.imageURL]) {
//                GDataXMLElement *imageEle = [GDataXMLElement elementWithName:@"ImageID" stringValue:[NSString stringWithFormat:@"%ld", (long)effectImg.imageID]];
//                [delete_ImgXML appendString:[imageEle XMLString]];
//            }
//        }
//    }
    
    NSMutableArray *addArray = [NSMutableArray array];
    for (NSArray *arr in before_uploadImgArray) {
        UIImage *image = (UIImage *)[arr objectAtIndex:1];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
        NSString *imgString  = [imageData base64Encoding];
        NSString *imgFormat  = [arr objectAtIndex:0];
        
        NSString *jsonString = [NSString stringWithFormat:@"{\"ImageType\":0,\"ImageString\":\"%@\",\"ImageFormat\":\"%@\"}",imgString, imgFormat];
        [addArray addObject:jsonString];
    }
    
    

    for (NSArray *arr in after_uploadImgArray) {
        UIImage *image = (UIImage *)[arr objectAtIndex:1];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
        NSString *imgString  = [imageData base64Encoding];
        NSString *imgFormat  = [arr objectAtIndex:0];
        
        NSString *jsonString = [NSString stringWithFormat:@"{\"ImageType\":1,\"ImageString\":\"%@\",\"ImageFormat\":\"%@\"}",imgString, imgFormat];
        [addArray addObject:jsonString];
    }
    /*
    // ---上传图片 拼接imageXML
    NSMutableString *upload_ImgXML = [NSMutableString string];
    for (NSArray *arr in before_uploadImgArray) {
        
        UIImage *image = (UIImage *)[arr objectAtIndex:1];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
        NSString *imgString  = [imageData base64Encoding];
        NSString *imgFormat  = [arr objectAtIndex:0];
        
        GDataXMLElement *rootElement = [GDataXMLElement elementWithName:@"AddImage"];
        GDataXMLElement *treatTypeEle = [GDataXMLElement elementWithName:@"TreatmentType" stringValue:@"0"];
        GDataXMLElement *imgStringEle = [GDataXMLElement elementWithName:@"ImageString" stringValue:imgString];
        GDataXMLElement *imgFormatEle = [GDataXMLElement elementWithName:@"ImageFormat" stringValue:imgFormat];
        [rootElement addChild:treatTypeEle];
        [rootElement addChild:imgStringEle];
        [rootElement addChild:imgFormatEle];
        [upload_ImgXML appendString:[rootElement XMLString]];
    }
    
    
    for (NSArray *arr in after_uploadImgArray) {
        UIImage *image = (UIImage *)[arr objectAtIndex:1];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
        NSString *imgString  = [imageData base64Encoding];
        NSString *imgFormat  = [arr objectAtIndex:0];
        
        GDataXMLElement *rootElement = [GDataXMLElement elementWithName:@"DeleteImage"];
        GDataXMLElement *treatTypeEle = [GDataXMLElement elementWithName:@"TreatmentType" stringValue:@"1"];
        GDataXMLElement *imgStringEle = [GDataXMLElement elementWithName:@"ImageString" stringValue:imgString];
        GDataXMLElement *imgFormatEle = [GDataXMLElement elementWithName:@"ImageFormat" stringValue:imgFormat];
        [rootElement addChild:treatTypeEle];
        [rootElement addChild:imgStringEle];
        [rootElement addChild:imgFormatEle];
        [upload_ImgXML appendString:[rootElement XMLString]];
    }

    if ([delete_ImgXML length] == 0)
        delete_ImgXML = [NSMutableString stringWithString:@""];
    
    if ([upload_ImgXML length] == 0)
        upload_ImgXML = [NSMutableString stringWithString:@""];
    
//    NSString *request_UploadImgXML = [[upload_ImgXML stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
//    NSString *request_DeleteImgXML = [[delete_ImgXML stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    */
    NSString *request_UploadImgJson = [addArray componentsJoinedByString:@","];
    NSString *request_DeleteImgJson = [dele_ImgID componentsJoinedByString:@","];
    
    [self requestEffectImage:request_UploadImgJson deleteImage:request_DeleteImgJson];
}

#pragma mark - 接口
- (void)requestEffectImage:(NSString *)uploadImageXML deleteImage:(NSString *)deleteImageXML
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];

    NSString *par;
    
    switch (self.effectType) {
        case EffectImgEditViewControllerType_TG:
        {
            par = [NSString stringWithFormat:@"{\"GroupNo\":%f,\"CustomerID\":%ld,\"AddImage\":[%@],\"DeleteImage\":[%@]}",groupNo,(long)self.customerID,uploadImageXML, deleteImageXML];
        }
            break;
        case EffectImgEditViewControllerType_TM:
        {
            par = [NSString stringWithFormat:@"{\"TreatmentID\":%ld,\"GroupNo\":%f,\"CustomerID\":%ld,\"AddImage\":[%@],\"DeleteImage\":[%@]}", (long)treat_ID,groupNo,(long)self.customerID,uploadImageXML, deleteImageXML];
        }
            break;
            
        default:
            break;
    }
//    {"TreatmentID":153933,"GroupNo":1539330054584518,"CustomerID":123456,"AddImage":[{"ImageFormat":".JPEG","ImageType":0,"ImageString":""}],"DeleteImage":[{"ImageID":2}]}
    
    _uploadImageOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Image/UpdateServiceEffectImage" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                
            }];
        }];
    } failure:^(NSError *error) {
        
    }];

    
    /*
   _uploadImageOperation = [[GPHTTPClient shareClient] requestUploadImageAndDeleteImageWithTreatmentId:treat_ID customerId:_customerID uploadImageXML:uploadImageXML deleteImageXML:deleteImageXML success:^(id xml) {
       [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {} failure:^{}];
   } failure:^(NSError *error) { [SVProgressHUD dismiss];}];
     */
}

@end
