//
//  AddPhotoViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/3.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//
#define MAX_LIMIT_NUMS     20

const CGFloat backGroundView_Height= 320;
const CGFloat imgView_Width = 300;


#import "AddPhotoViewController.h"
#import "GPHTTPClient.h"
#import "UIImage+Compress.h"
#import "UIImage+fixOrientation.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GPImageEditorViewController.h"

@interface AddPhotoViewController ()<UIGestureRecognizerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,GPImageEditorViewControllerDelegate>
{
    UITextView *_editPhotoTextView;
    UILabel *_placeholderLab;
    UIImage *uploadImg;
    NSString *imgType;
}
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIImageView *photoImgView;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateServiceEffectImageOperation;
@end


@implementation AddPhotoViewController
@synthesize bottomView;


- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    [self initData];
    [self initView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)initData
{
    self.title = @"上传照片";
}
- (void)initView
{
    self.view.backgroundColor = RGBA(241, 241, 241, 1);
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, kNavigationBar_Height, kSCREN_BOUNDS.size.width, backGroundView_Height)];
    backGroundView.backgroundColor = kColor_White;
    [self.view addSubview:backGroundView];
    CGFloat x = (kSCREN_BOUNDS.size.width-imgView_Width) / 2;
    _photoImgView = [[UIImageView alloc]initWithFrame:CGRectMake(x, (backGroundView_Height - imgView_Width) / 2, imgView_Width,imgView_Width)];
    [_photoImgView setImage:[UIImage imageNamed:@"AddImgDefault"]];
    _photoImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [_photoImgView addGestureRecognizer:tap];
    [backGroundView addSubview:_photoImgView];

    


    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - 60 + 20, kSCREN_BOUNDS.size.width, 60)];
    bottomView.backgroundColor = kColor_White;
    [self.view addSubview:bottomView];
    
    _editPhotoTextView = [[UITextView alloc]initWithFrame:CGRectMake(10,10, kSCREN_BOUNDS.size.width - 20 - 60, 40)];
    _editPhotoTextView.delegate = self;
    _editPhotoTextView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0);
    _editPhotoTextView.font = kNormalFont_14;
    [_editPhotoTextView setReturnKeyType:UIReturnKeyDone];
    [bottomView addSubview:_editPhotoTextView];
    
    _placeholderLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, kSCREN_BOUNDS.size.width - 20, 30)];
    _placeholderLab.textAlignment = NSTextAlignmentLeft;
    _placeholderLab.text = @"留下你的标签";
    _placeholderLab.font=kNormalFont_14;
    _placeholderLab.textColor = [UIColor lightGrayColor];
    [_editPhotoTextView addSubview:_placeholderLab];
    
    [bottomView addSubview:_editPhotoTextView];
    
    UIButton *confirmBtn = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(confirm:) frame:CGRectMake(kSCREN_BOUNDS.size.width - 10 - 60, 10,  60, 40) backgroundImg:nil highlightedImage:nil];
    confirmBtn.backgroundColor = KColor_NavBarTintColor;
    [bottomView addSubview:confirmBtn];
    
    
}
#pragma mark -  按钮事件
- (void)confirm:(UIButton *)sender
{
    [self.view endEditing:YES];
    if ([_photoImgView.image isEqual:[UIImage imageNamed:@"AddImgDefault"]]) {
        [SVProgressHUD showErrorWithStatus:@"请上传一张图片"];
        return;
    }
    [self requestUpdateServiceEffectImage];
}

-(void)tap:(UIGestureRecognizer *)ges
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"上传图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从图库中获取", nil];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    bottomView.frame = CGRectMake(0, kSCREN_BOUNDS.size.height - 60 + 20, kSCREN_BOUNDS.size.width, 60);
    CGRect rect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = rect.origin.y;
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect bottomRect = bottomView.frame;
        bottomRect.origin.y -= (y - kNavigationBar_Height);
        bottomView.frame = bottomRect;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        bottomView.frame = CGRectMake(0, kSCREN_BOUNDS.size.height - 60 + 20, kSCREN_BOUNDS.size.width, 60);
    } completion:^(BOOL finished) {

    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
            cameraController.allowsEditing = NO;
            [self presentViewController:cameraController animated:YES completion:^{}];
        }
    }  else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
            photoController.delegate = self;
            photoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            photoController.allowsEditing = NO;
            [self presentViewController:photoController animated:YES completion:^{}];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        uploadImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                NSString *fileName = [asset.defaultRepresentation filename];
                NSString *fileType = [[fileName componentsSeparatedByString:@"."] objectAtIndex:1];
                imgType = [NSString stringWithFormat:@".%@", fileType];
            } failureBlock:^(NSError *error) {
                DLOG(@"Error:%@  Address:%s", error.description, __FUNCTION__);
            }];
        } else {
            imgType = @".JPG";
        }
        GPImageEditorViewController *imageEditorVewController = [[GPImageEditorViewController alloc] init];
        imageEditorVewController.editImage = uploadImg;
        imageEditorVewController.delegate = self;
        [picker pushViewController:imageEditorVewController animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

    [picker dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - GPImageEditorViewControllerDelegate

- (void)imageEditorViewController:(GPImageEditorViewController *)vController didEditedImage:(UIImage *)image
{
    uploadImg = [image scaleToSize:CGSizeMake(2560.0f, 2560.0f)];
    uploadImg = [uploadImg fixOrientation];
    [_photoImgView setImage:uploadImg];
}


#pragma mark - UITextViewDelegate;
#pragma mark- textViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_LIMIT_NUMS) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx++;
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            //既然是超出部分截取了，哪一定是最大限制了。
        }
        return NO;
    }
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0) {
        _placeholderLab.text = @"";
    }else {
        _placeholderLab.text = @"留下你的标签";
    }
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_NUMS)
    {
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        
        [textView setText:s];
    }
}

#pragma mark - 接口
- (void)requestUpdateServiceEffectImage
{
    //    /image/UpdateServiceEffectImage 上传删除图片
    //    所需参数
    //    {"GroupNo":1539330054584518,"CustomerID":123456,"Comment":"dasadsadsdasads","AddImage":[{"ImageFormat":".JPEG","ImageType":0,"ImageString":""}],"DeleteImage":[{"ImageID":2}]}
    //    返回参数
    //    {"Data":true,"Code":"1","Message":null}
    //    {"Data":false,"Code":"0","Message":null}
    UIImage *image = _photoImgView.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
    NSString *imgString  = [imageData base64Encoding];
    NSDictionary *addImageDic = @{@"ImageFormat":@".JPEG",@"ImageType":@(0),@"ImageString":imgString,@"ImageTag":_editPhotoTextView.text};
    NSArray *addImageArrs = @[addImageDic];
    NSDictionary *paraGet = @{@"GroupNo":self.shopRes.groupNo,
                              @"Comment":self.shopRes.comments,
                              @"CustomerID":@(CUS_CUSTOMERID),
                              @"AddImage":addImageArrs,
                              };
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestUpdateServiceEffectImageOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/UpdateServiceEffectImage"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if ([data isKindOfClass:[NSNumber class]]) {
                NSNumber  *dataNum = (NSNumber *)data;
                if (dataNum.boolValue) {
                    NSLog(@"照片上传成功");
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    NSLog(@"照片上传失败");
                }
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}
@end
