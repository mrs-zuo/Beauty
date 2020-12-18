//
//  ViewController.m
//  merNew
//
//  Created by MAC_Lion on 13-7-23.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "MerchantInfoViewController.h"
#import "MerchantDoc.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "DEFINE.h"
#import "MerchantEditCell.h"
#import "MerchantPhotoView.h"

#import "UIImageView+WebCache.h"

@interface MerchantInfoViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetBeautyShopInfoOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetBeautyShopImagesOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateBeautyShopInfoOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *uploadImageOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *deleteImageOperation;

@property (strong, nonatomic) MerchantPhotoView *merchantPhotoView;
@property (strong, nonatomic) NSArray *merchantImgArray;

@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *textArray;
@property (strong, nonatomic) UITextView *textView_selected;
@property (assign, nonatomic) CGFloat text_Height;//  作用:记录textView 高度  比较textView前后两次的高度
@property (assign, nonatomic) CGFloat text_Y;     // 记录被选择的textView的(Y+Height)值
@property (assign, nonatomic) CGFloat cell_AddressText_Height_Temp;
@property (assign, nonatomic) CGFloat cell_RemarkText_Height_Temp;
@property (assign, nonatomic) CGFloat cell_NetText_Height_Temp;
@end

@implementation MerchantInfoViewController
@synthesize merchantPhotoView;
@synthesize merchantImgArray;
@synthesize titleArray;
@synthesize textArray;
@synthesize textView_selected;
@synthesize text_Height,text_Y;
@synthesize merchantDoc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_requestGetBeautyShopInfoOperation || [_requestGetBeautyShopInfoOperation isExecuting]) {
        [_requestGetBeautyShopInfoOperation cancel];
        _requestGetBeautyShopInfoOperation = nil;
    }
    
    if (_requestGetBeautyShopImagesOperation || [_requestGetBeautyShopImagesOperation isExecuting]) {
        [_requestGetBeautyShopImagesOperation cancel];
        _requestGetBeautyShopImagesOperation = nil;
    }
    
    if (_requestUpdateBeautyShopInfoOperation|| [_requestUpdateBeautyShopInfoOperation isExecuting]) {
        [_requestUpdateBeautyShopInfoOperation cancel];
        _requestUpdateBeautyShopInfoOperation = nil;
    }
    
    if (_uploadImageOperation|| [_uploadImageOperation isExecuting]) {
        [_uploadImageOperation cancel];
        _uploadImageOperation = nil;
    }
    
    if (_deleteImageOperation|| [_deleteImageOperation isExecuting]) {
        [_deleteImageOperation cancel];
        _deleteImageOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cell_AddressText_Height_Temp = 0;
    _cell_RemarkText_Height_Temp = 0;
    _cell_NetText_Height_Temp = 0;
    
    titleArray = [[NSArray alloc] initWithObjects:@"名称", @"简介", @"联系人", @"电话", @"传真", @"邮编", @"地址", @"网址", nil];
    [self initTableView];
    [self requestGetBeautyShopInfo];
    [self requestGetBeautyShopImages];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name: UITextViewTextDidChangeNotification object:nil];
}

- (void)initTableView
{
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView  = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 330.0f, 100.0f)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    merchantPhotoView = [[MerchantPhotoView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 310.0f, 100.0f)];
    [merchantPhotoView updatePhotos:merchantImgArray];
    [merchantPhotoView setViewController:self];
    [headerView addSubview:merchantPhotoView];
    _tableView.tableHeaderView = headerView;
    
    merchantPhotoView.backgroundColor = [UIColor whiteColor];
    merchantPhotoView.layer.borderColor = [kTableView_LineColor CGColor];
    merchantPhotoView.layer.borderWidth = 1.0f;
    merchantPhotoView.layer.cornerRadius = 4.0f;
    merchantPhotoView.layer.masksToBounds = YES;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -5.0f, 330.0f, 50.0f)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    UIButton *footerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [footerButton setFrame:CGRectMake(40.0f, -5.0f, 240.0f, 40.0f)];
    [footerButton setBackgroundImage:[UIImage imageNamed:@"customer_AddButtonLong"] forState:UIControlStateNormal];
    [footerButton addTarget:self action:@selector(updateMerchantInfo) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:footerButton];
    _tableView.tableFooterView = footerView;
}

- (void)dismissKeyBoard
{
    if (_tableView.frame.origin.y != 0) {
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        CGRect tableFrame = _tableView.frame;
        tableFrame.origin.y = 0;
        _tableView.frame = tableFrame;
        [_tableView setFrame:CGRectMake(-5.0f, 35.0f, 330.0f, 375.0f)];
        [UIView commitAnimations];
    }
    [textView_selected resignFirstResponder];
}

- (void)textChanged:(NSNotification *)notification
{
    UITextView *textView = textView_selected;
    
    // 判断textView是否为地址textView 或者为备注textView
    if (textView.tag == 101 || textView.tag == 106 || textView.tag == 107) {
        float nowHeight = textView.contentSize.height;
        if (nowHeight != text_Height) {
            text_Height = nowHeight;
            CGRect textRect = textView.frame;
            textRect.size.height = text_Height;
            textView.frame = textRect;
            
            // 当输入的内容 多行显示 则_tableView的frame从新变化
            CGRect rect = [textView convertRect:textView.bounds toView:_tableView];
            text_Y = rect.origin.y + textView.contentSize.height + 20 + 44.0f;
            [self keyboardWillShow];
            
            if (textView.tag == 101) {
                _cell_AddressText_Height_Temp = text_Height;
            } else if(textView.tag == 106) {
                _cell_RemarkText_Height_Temp = text_Height;
            } else if(textView.tag == 107) {
                _cell_NetText_Height_Temp = text_Height;
            }
            
            [self tableViewNeedsToUpdateHeight];  //更改cell高度
        }
    }
}

- (void)tableViewNeedsToUpdateHeight
{
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    [_tableView beginUpdates];
    [_tableView endUpdates];
    [UIView setAnimationsEnabled:animationsEnabled];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView_selected = textView;
    text_Height = textView.contentSize.height;
    
    CGRect textRect = [textView convertRect:textView.bounds toView:_tableView];
    text_Y = textRect.origin.y + textView.contentSize.height  + 20.0f;
    
    [self keyboardWillShow];
    
    return YES;
}

- (void)keyboardWillShow
{
    CGFloat keyboard_Hegith = 252.0f - 44.0f;
    CGFloat keyboard_Y = kSCREN_BOUNDS.size.height - 20.0f - keyboard_Hegith;
    CGFloat offSet = 0.0f;
    if (text_Y > keyboard_Y) {
        offSet = - (text_Y - keyboard_Y + 15.0f) ;
        
        if (offSet < - keyboard_Hegith) {
            offSet = - keyboard_Hegith;
        }
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        
        CGRect tableFrame = _tableView.frame;
        tableFrame.origin.y = offSet;
        _tableView.frame = tableFrame;
        [UIView commitAnimations];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char * ch=[text cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    //限制姓名和手机号的长短
    int tag = [textView tag];
    if (tag == 100 || tag == 102) {  // 姓名 称呼
        if ([textView.text length] >= 11) return NO;
    } else if(tag == 103) { // 手机
        if ([textView.text length] >= 11) return NO;
    } else if(tag == 105) { // 手机
        if ([textView.text length] >= 6) return NO;
    }
    
    if (tag == 100 || tag == 102) {
        if([text isEqualToString:@"\n"]){
            [self dismissKeyBoard];
            return NO;
        }
    }
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titleArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        if (_cell_AddressText_Height_Temp != 0) {
            return _cell_AddressText_Height_Temp + 12.0f;
        }
    }
    
    if (indexPath.row == 6) {
        if (_cell_RemarkText_Height_Temp != 0) {
            return _cell_RemarkText_Height_Temp + 12.0f;
        }
    }
    
    if (indexPath.row == 7) {
        if (_cell_NetText_Height_Temp != 0) {
            return _cell_NetText_Height_Temp + 12.0f;
        }
    }
    
    return kTableView_HeightOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"mer_cell";
    MerchantEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MerchantEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.contentText.tag = indexPath.row + 100;
    
    cell.contentText.delegate = self;
    cell.titleNameLabel.text = [titleArray objectAtIndex:indexPath.row ];
    
    switch (indexPath.row) {
        case 0:
            cell.contentText.scrollEnabled = NO;
            cell.contentText.keyboardType = UIKeyboardTypeDefault;
            cell.contentText.returnKeyType=UIReturnKeyDone;
            break;
        case 1:
            cell.contentText.scrollEnabled = YES;
            cell.contentText.keyboardType = UIKeyboardTypeDefault;
            break;
        case 2:
            cell.contentText.scrollEnabled = NO;
            cell.contentText.keyboardType = UIKeyboardTypeDefault;
            cell.contentText.returnKeyType=UIReturnKeyDone;
            break;
        case 3:
            cell.contentText.scrollEnabled = NO;
            cell.contentText.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 4:
            cell.contentText.scrollEnabled = NO;
            cell.contentText.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 5:
            cell.contentText.scrollEnabled = NO;
            cell.contentText.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 6:
            cell.contentText.scrollEnabled = YES;
            cell.contentText.keyboardType = UIKeyboardTypeDefault;
            break;
        case 7:
            cell.contentText.scrollEnabled =YES;
            cell.contentText.keyboardType = UIKeyboardTypeDefault;
            break;
        default:
            break;
            
    }
    
    switch (indexPath.row) {
        case 0:
            cell.contentText.text = merchantDoc.mer_Name;
            break;
        case 1:
            if(merchantDoc.mer_Intro.length!=0){
                [cell.contentText setText:merchantDoc.mer_Intro];
                CGSize size = [merchantDoc.mer_Intro sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(202.0f, 400.0f) lineBreakMode:NSLineBreakByWordWrapping];
                CGRect decRect = cell.contentText.frame;
                decRect.size.height = size.height+12.0f;
                cell.contentText.frame = decRect;
            }
            cell.contentText.text = merchantDoc.mer_Intro;
            break;
        case 2:
            cell.contentText.text = merchantDoc.mer_Linkman;
            break;
        case 3:
            cell.contentText.text = merchantDoc.mer_Phone;
            break;
        case 4:
            cell.contentText.text = merchantDoc.mer_Fax;
            break;
        case 5:
            cell.contentText.text = merchantDoc.mer_Postcode;
            break;
        case 6:
            if(merchantDoc.mer_Address.length!=0){
                [cell.contentText setText:merchantDoc.mer_Address];
                CGSize size = [merchantDoc.mer_Address sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(202.0f, 400.0f) lineBreakMode:NSLineBreakByWordWrapping];
                CGRect decRect = cell.contentText.frame;
                decRect.size.height = size.height+12.0f;
                cell.contentText.frame = decRect;
            }
            
            cell.contentText.text = merchantDoc.mer_Address;
            break;
        case 7:
            if(merchantDoc.mer_Url.length!=0){
                [cell.contentText setText:merchantDoc.mer_Url];
                CGSize size = [merchantDoc.mer_Url sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(202.0f, 400.0f) lineBreakMode:NSLineBreakByWordWrapping];
                CGRect decRect = cell.contentText.frame;
                decRect.size.height = size.height+12.0f;
                cell.contentText.frame = decRect;
            }
            
            cell.contentText.text = merchantDoc.mer_Url;
            break;
        default:
            break;
    }
    
    return cell;
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    merchantDoc = [self fetchTextViewContent];
}

// 临时保存修改的内容
- (MerchantDoc *)fetchTextViewContent
{
    UITextView *textView_Name = (UITextView *)[_tableView viewWithTag:100];
    UITextView *textView_Intro = (UITextView *)[_tableView viewWithTag:101];
    UITextView *textView_Linkman = (UITextView *)[_tableView viewWithTag:102];
    UITextView *textView_Phone = (UITextView *)[_tableView viewWithTag:103];
    UITextView *textView_Fax = (UITextView *)[_tableView viewWithTag:104];
    UITextView *textView_Postcode = (UITextView *)[_tableView viewWithTag:105];
    UITextView *textView_Address = (UITextView *)[_tableView viewWithTag:106];
    UITextView *textView_Url = (UITextView *)[_tableView viewWithTag:107];
    
    MerchantDoc *theMerchanDoc = [[MerchantDoc alloc] init];
    [theMerchanDoc setMer_Name:(textView_Name == nil ? merchantDoc.mer_Name : textView_Name.text)];
    [theMerchanDoc setMer_Intro:(textView_Intro == nil ? merchantDoc.mer_Intro : textView_Intro.text)];
    [theMerchanDoc setMer_Linkman:(textView_Linkman == nil ? merchantDoc.mer_Linkman : textView_Linkman.text)];
    [theMerchanDoc setMer_Phone:(textView_Phone == nil ? merchantDoc.mer_Phone : textView_Phone.text)];
    [theMerchanDoc setMer_Fax:(textView_Fax == nil ? merchantDoc.mer_Fax : textView_Fax.text)];
    [theMerchanDoc setMer_Postcode:(textView_Postcode == nil ? merchantDoc.mer_Postcode : textView_Postcode.text)];
    [theMerchanDoc setMer_Address:(textView_Address == nil ? merchantDoc.mer_Address : textView_Address.text)];
    [theMerchanDoc setMer_Url:(textView_Url == nil ? merchantDoc.mer_Url : textView_Url.text)];
    
    return theMerchanDoc;
}


- (void)updateMerchantInfo
{
    // before
    NSArray *before_deleteImgArray = [merchantPhotoView.pictureDisplayView getDeleteImageURLsArray];
    NSArray *before_uploadImgArray = [merchantPhotoView.pictureDisplayView getUploadImagesAndTypes];
    if ([before_deleteImgArray count] > 0) {
        NSString *imageURLs = [before_deleteImgArray componentsJoinedByString:@","];
        NSArray *array = [imageURLs componentsSeparatedByString:@"&"];
      //  NSString *tmpStr = [NSString stringWithFormat:@"%@,", [array objectAtIndex:0]];
     //   [self deleteEffectImageWithImageURLs:tmpStr];
    }
    
    if ([before_uploadImgArray count] > 0) {
        NSMutableArray *imageArray = [NSMutableArray array];
        NSMutableArray *typeArray  = [NSMutableArray array];
        for (NSArray *arr in before_uploadImgArray) {
            [imageArray addObject:[arr objectAtIndex:1]];
            [typeArray addObject:[arr objectAtIndex:0]];
        }
        if ([imageArray count] > 0 && [typeArray count] > 0 ) {
          //  [self uploadEffectImageWithImages:imageArray imageTypes:typeArray category:0];
        }
    }
}

#pragma mark - 接口

- (void)requestGetBeautyShopInfo
{
    [SVProgressHUD show];
    _requestGetBeautyShopInfoOperation = [[GPHTTPClient shareClient] requestGetBeautyShopInfoWithSuccess:^(id xml) {
        [SVProgressHUD dismiss];
//        
//        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
//        NSArray *datas = [document nodesForXPath:@"//ds" error:nil];
//        NSString *mName = [[[[datas objectAtIndex:0] elementsForName:@"Name"] objectAtIndex:0] stringValue];
//        NSString *mIntro = [[[[datas objectAtIndex:0] elementsForName:@"Summary"] objectAtIndex:0]  stringValue];
//        NSString *mLinkman = [[[[datas objectAtIndex:0] elementsForName:@"Contact"] objectAtIndex:0] stringValue];
//        NSString *mPhone = [[[[datas objectAtIndex:0] elementsForName:@"Phone"] objectAtIndex:0] stringValue];
//        NSString *mFax = [[[[datas objectAtIndex:0] elementsForName:@"Fax"] objectAtIndex:0] stringValue];
//        NSString *mAddress = [[[[datas objectAtIndex:0] elementsForName:@"Address"] objectAtIndex:0] stringValue];
//        NSString *mPostcode = [[[[datas objectAtIndex:0] elementsForName:@"Zip"] objectAtIndex:0] stringValue];
//        NSString *mUrl = [[[[datas objectAtIndex:0] elementsForName:@"Web"] objectAtIndex:0] stringValue];
//        if (merchantDoc == nil) {
//            merchantDoc = [[MerchantDoc alloc] init];
//        }
//        [merchantDoc setMer_Name:mName];
//        [merchantDoc setMer_Intro:mIntro];
//        [merchantDoc setMer_Linkman:mLinkman];
//        [merchantDoc setMer_Phone:mPhone];
//        [merchantDoc setMer_Fax:mFax];
//        [merchantDoc setMer_Postcode:mPostcode];
//        [merchantDoc setMer_Address:mAddress];
//        [merchantDoc setMer_Url:mUrl];
//        
//        CGSize size = [merchantDoc.mer_Address sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(202.0f, 400.0f) lineBreakMode:NSLineBreakByWordWrapping];
//        CGRect decRect ;
//        decRect.size.height = size.height;
//        if(merchantDoc.mer_Address.length!=0){
//            _cell_AddressText_Height_Temp =decRect.size.height+_cell_AddressText_Height_Temp+12.0f;
//        }
//        
//        CGSize size1 = [merchantDoc.mer_Intro sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(202.0f, 400.0f) lineBreakMode:NSLineBreakByWordWrapping];
//        CGRect decRect1;
//        decRect1.size.height = size1.height;
//        if(merchantDoc.mer_Intro.length!=0){
//            _cell_RemarkText_Height_Temp=decRect1.size.height+_cell_RemarkText_Height_Temp+12.0f;
//        }
//        
//        CGSize size2 = [merchantDoc.mer_Url sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(202.0f, 400.0f) lineBreakMode:NSLineBreakByWordWrapping];
//        CGRect decRect2;
//        decRect2.size.height = size2.height;
//        if(merchantDoc.mer_Url.length!=0){
//            _cell_NetText_Height_Temp=decRect2.size.height+_cell_NetText_Height_Temp+12.0f;
//        }
//        
//        [self tableViewNeedsToUpdateHeight];
//        [_tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error:%@ Address:%s", error.description, __FUNCTION__);
    }];
}

- (void)requestGetBeautyShopImages
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestGetBeautyShopImagesOperation = [[GPHTTPClient shareClient] requestGetBeautyShopImages:^(id xml) {
//        [SVProgressHUD dismiss];
//        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
//        NSArray *datas = [document nodesForXPath:@"//soap:Body" error:nil];
//        NSString *result = [[datas objectAtIndex:0] stringValue];
//        NSString *resultStr = [result substringToIndex:[result length] - 1];
//        merchantImgArray = [resultStr componentsSeparatedByString:@","];
//        [merchantPhotoView updatePhotos:merchantImgArray];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error:%@ Address:%s", error.description, __FUNCTION__);
    }];
}

- (void)requestUpdateBeautyShopInfo
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestUpdateBeautyShopInfoOperation = [[GPHTTPClient shareClient] requestUpdateBeautyShopInfoWithMerchantDoc:merchantDoc success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(int code) {} failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error:%@ Address:%s", error.description, __FUNCTION__);
    }];
}

//
//- (void)uploadEffectImageWithImages:(NSArray *)images imageTypes:(NSArray *)imageTypes category:(int)categroy
//{
//    [SVProgressHUD showWithStatus:@"Loading"];
//    _uploadImageOperation  = [[GPHTTPClient shareClient] requestUploadMoreImage:images imageType:imageTypes objectType:4 objectId:1 category:categroy success:^(id xml) {
//        [SVProgressHUD dismiss];[GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(int code) {} failure:^{}];} failure:^(NSError *error) {[SVProgressHUD dismiss];
//            NSLog(@"Error:%@ Address:%s", error.description, __FUNCTION__);
//        }];
//}
//
//- (void)deleteEffectImageWithImageURLs:(NSString *)imageURLs
//{
//    [SVProgressHUD showWithStatus:@"Loading"];
//    _deleteImageOperation = [[GPHTTPClient shareClient] requestDeleteMoreImage:imageURLs success:^(id xml) {
//        [SVProgressHUD dismiss];
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(int code) {} failure:^{}];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//        NSLog(@"Error:%@ Address:%s", error.description, __FUNCTION__);
//    }];
//}

@end
