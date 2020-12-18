//
//  EditPhotoViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/1.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//
#define MAX_LIMIT_NUMS     20

typedef NS_ENUM(NSInteger, EditPhotoViewControllerOpType) {
    EditPhotoViewControllerOpType_Delete = 0,
    EditPhotoViewControllerOpType_Confirm = 1
};
const CGFloat imgView_Width = 300;
const CGFloat textView_Height = 80;

#import "EditPhotoViewController.h"
#import "GPHTTPClient.h"
#import "BeautyRecordViewController.h"
#import "CustomerTGPicRes.h"

@interface EditPhotoViewController ()<UIGestureRecognizerDelegate,UITextViewDelegate>
{
    UIView *_backView;
    UITextView *_editPhotoTextView;
    UILabel *_placeholderLab;
}
@property (weak, nonatomic) AFHTTPRequestOperation *requestEditCustomerPicOperation;
@property(nonatomic,assign)EditPhotoViewControllerOpType  opTye;

@end

@implementation EditPhotoViewController

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
    self.title = @"编辑照片";
}
- (void)initView
{
    self.view.backgroundColor = RGBA(241, 241, 241, 1);
    
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, kNavigationBar_Height,kSCREN_BOUNDS.size.width, imgView_Width + textView_Height + 20)];
    _backView.backgroundColor = kColor_White;
    [self.view addSubview:_backView];
    
    CGFloat x = (kSCREN_BOUNDS.size.width - imgView_Width) / 2;
    UIImageView *photoImgView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 10, imgView_Width,imgView_Width)];
    photoImgView.userInteractionEnabled = YES;
    [photoImgView setImageWithURL:[NSURL URLWithString:self.tGPicListRes.imageURL] placeholderImage:[UIImage imageNamed:@"People-default"] options:SDWebImageCacheMemoryOnly];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [photoImgView addGestureRecognizer:tap];
    [_backView addSubview:photoImgView];
    
    
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, photoImgView.frame.origin.y + photoImgView.frame.size.height + 1, kSCREN_BOUNDS.size.width - 20, 1)];
    _backView.backgroundColor = kColor_FootView;
    [_backView addSubview:lineView];
    
    _editPhotoTextView = [[UITextView alloc]initWithFrame:CGRectMake(10,photoImgView.frame.origin.y + photoImgView.frame.size.height + 10, kSCREN_BOUNDS.size.width - 20, textView_Height)];
    _editPhotoTextView.delegate = self;
    _editPhotoTextView.font = kFont_Light_17;
    _editPhotoTextView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    [_editPhotoTextView setReturnKeyType:UIReturnKeyDone];
    _placeholderLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, _editPhotoTextView.frame.size.width - 20, 30)];
    if ([self.tGPicListRes.imageTag isEqualToString:@""]) {
        _placeholderLab.text = @"留下你的标签";
    }else{
        _editPhotoTextView.text = self.tGPicListRes.imageTag;
    }
    _placeholderLab.textColor = [UIColor lightGrayColor];
    [_editPhotoTextView addSubview:_placeholderLab];
    [_backView addSubview:_editPhotoTextView];
    
    
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - 60 + 20, kSCREN_BOUNDS.size.width, 60)];
    bottomView.backgroundColor = kColor_White;
    [self.view addSubview:bottomView];
    CGFloat btnWidth = (kSCREN_BOUNDS.size.width  - 30) / 2;
    UIButton *deletBtn = [UIButton buttonWithTitle:@"删除" target:self selector:@selector(delet:) frame:CGRectMake(10, 10,btnWidth, 40) backgroundImg:nil highlightedImage:nil];
    deletBtn.backgroundColor = KColor_NavBarTintColor;
    [bottomView addSubview:deletBtn];

    UIButton *confirmBtn = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(confirm:) frame:CGRectMake(btnWidth + 20, 10,  btnWidth, 40) backgroundImg:nil highlightedImage:nil];
    confirmBtn.backgroundColor = KColor_NavBarTintColor;
    [bottomView addSubview:confirmBtn];
    
    
}
#pragma mark -  按钮事件
- (void)confirm:(UIButton *)sender
{
    [self.view endEditing:YES];
    self.tGPicListRes.imageTag = _editPhotoTextView.text;
    self.opTye = EditPhotoViewControllerOpType_Confirm;
    [self requestrequestEditCustomerPic];
    
}
- (void)delet:(UIButton *)sender
{
    [self.view endEditing:YES];
    self.opTye = EditPhotoViewControllerOpType_Delete;
    [self requestrequestEditCustomerPic];

}
-(void)tap:(UIGestureRecognizer *)ges
{
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.opTye = EditPhotoViewControllerOpType_Confirm;
    [self.view endEditing:YES];
}
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

#pragma mark- 键盘
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect rect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect bottomRect = _backView.frame;
        bottomRect.origin.y -=  textView_Height;
        _backView.frame = bottomRect;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _backView.frame = CGRectMake(0, kNavigationBar_Height,kSCREN_BOUNDS.size.width, imgView_Width + textView_Height + 20);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -  接口

- (void)requestrequestEditCustomerPic
{
    //    /image/editCustomerPic 修改记录
    //    所需参数
    //    {"RecordImgID":"2012568547854","GroupNo":160,"ImageTag":"160","Type":1}
    //
    //    Type==1 删除TG的美丽记录 GroupNo必传
    //    Type==2 删除的美丽记录的单张照片 RecordImgID必传
    //    Type==3 修改美丽记录TAG RecordImgID必传
    NSDictionary *paraGet ;
    switch (self.opTye) {
        case EditPhotoViewControllerOpType_Confirm:
        {
            paraGet  = @{@"GroupNo":self.shopRes.groupNo,
                         @"RecordImgID":self.tGPicListRes.recordImgID,
                         @"ImageTag":self.tGPicListRes.imageTag,
                         @"Type":@(3),
                         };
        }
            break;
        case EditPhotoViewControllerOpType_Delete:
        {
        paraGet  = @{@"GroupNo":self.shopRes.groupNo,
                     @"RecordImgID":self.tGPicListRes.recordImgID,
                     @"ImageTag":self.tGPicListRes.imageTag,
                     @"Type":@(2),
                                };
        }
            break;
            
        default:
            break;
    }
  
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestEditCustomerPicOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/editCustomerPic"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if ([data isKindOfClass:[NSNumber class]]) {
                NSNumber  *dataNum = (NSNumber *)data;
                if (dataNum.boolValue) {
                    NSLog(@"删除成功");
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    NSLog(@"删除失败");
                }
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}


@end
