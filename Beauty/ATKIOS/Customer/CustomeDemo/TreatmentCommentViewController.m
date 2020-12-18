//
//  TreatmentCommentViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-2-11.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "TreatmentCommentViewController.h"
#import "UIButton+InitButton.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"

@interface TreatmentCommentViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestCommentOperation;
@property (nonatomic, assign) BOOL editState;
@property (strong, nonatomic) UITextView *describeTextView;
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (strong, nonatomic) UILabel *wordCountLabel;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *editButton;
@property (strong, nonatomic) UIToolbar *accessoryInputView;
@property(strong ,nonatomic)NSString * titleStr;
@property(strong,nonatomic)TitleView *titleView;
@end

@implementation TreatmentCommentViewController
@synthesize editState;
@synthesize treatmentComment;
@synthesize describeTextView;
@synthesize placeholderLabel;
@synthesize wordCountLabel;
@synthesize bgView;
@synthesize cancelButton;
@synthesize commentButton;
@synthesize editButton;
@synthesize accessoryInputView;
@synthesize titleStr;
@synthesize titleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

- (void)viewDidLoad
{
    self.isShow_tab_nav_tab_vcButton = YES;
    [super viewDidLoad];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    [self initView];
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard) name:@"dismissKeyboard" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordCountCheck:) name:UITextViewTextDidChangeNotification object:describeTextView];
    
    if (self.treatMentOrGroup ==1) {
        titleStr = @"服务";
        //        [self GetTGDetail];
        
    }else
    {
        titleStr = @"操作";
        //        [self getTreatmentDetail];
    }
    
//    titleView.titleLabel.text = [NSString stringWithFormat:@"%@评价",titleStr];
    self.tabBarController.title =  [NSString stringWithFormat:@"%@评价",titleStr];
    
    [self getCommont];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:describeTextView];
    
    if (_requestCommentOperation && [_requestCommentOperation isExecuting]) {
        [_requestCommentOperation cancel];
        _requestCommentOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    editButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - init

- (void)initView
{
//    if (self.treatMentOrGroup ==1) {
//        titleStr = @"服务";
//    }
//    else
//    {
//        titleStr = @"操作";
//    }
    //初始化TitleView
//    titleView = [[TitleView alloc] init];
//    [self.view addSubview:[titleView getTitleView:[NSString stringWithFormat:@"%@评价",titleStr]]];
//    self.title = [NSString stringWithFormat:@"%@评价",titleStr];
//    editButton = [UIButton buttonWithTitle:@""
//                                    target:self
//                                  selector:@selector(changeStateAction:)
//                                     frame:CGRectMake(276.0f, (titleView.frame.size.height - 36.0f)/2, 36.0f, 36.0f)
//                             backgroundImg:[UIImage imageNamed:@"editButton"]
//                          highlightedImage:nil];
//    editButton.hidden = YES;
//    [titleView addSubview:editButton];
    
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0,0,kSCREN_BOUNDS.size.width, 270.0f);
    bgView.userInteractionEnabled = YES;
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.masksToBounds = YES;
    //bgView.layer.borderColor = [kTableView_LineColor CGColor];
    //bgView.layer.borderWidth = 1.0f;
    if (IOS6) {
        bgView.layer.cornerRadius = 8.0f;
    }
    [self.view addSubview:bgView];
    
    for (int i = 0; i < 5; i++) {
        UIButton *starButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f + i*60, 10.0f, 50.0f, 50.0f)];
//        [starButton addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchDown];
        starButton.userInteractionEnabled = NO;
        [starButton setTag:(100 + i)];
        starButton.adjustsImageWhenHighlighted = NO;
        starButton.showsTouchWhenHighlighted = NO;
        [starButton setBackgroundImage:[UIImage imageNamed:@"order_CommentStar_0"] forState:UIControlStateNormal];
        [starButton setBackgroundImage:[UIImage imageNamed:@"order_CommentStar_1"] forState:UIControlStateSelected];
        [bgView addSubview:starButton];
        [starButton setSelected:NO];
    }
    
    UIView *division = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 70.0f,kSCREN_BOUNDS.size.width,1.0f)];
    division.backgroundColor=kTableView_LineColor;
    [bgView addSubview:division];
    
    describeTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 80.0f, 290.0f, 180.0f)];
    [describeTextView setTextColor:[UIColor blackColor]];
    [describeTextView setTextAlignment:NSTextAlignmentLeft];
    [describeTextView setFont:kFont_Light_14];
    [describeTextView setEditable:NO];
    [describeTextView setShowsVerticalScrollIndicator:NO];
    [describeTextView setScrollEnabled:NO];
    [describeTextView setTag:105];
    [describeTextView setBackgroundColor:[UIColor clearColor]];
    [describeTextView setDelegate:self];
    if ((IOS7 || IOS8)) {
        [describeTextView setTintColor:[UIColor blueColor]];
    }
    describeTextView.userInteractionEnabled = NO;
    [bgView addSubview:describeTextView];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.5f, 5.5f, 100.0f, 20.0f)];
    [placeholderLabel setFont:kFont_Light_14];
    [placeholderLabel setTextColor:kColor_Editable];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
    
//    [placeholderLabel setText:@"请输入评论..."];
    [placeholderLabel setTag:106];
    [describeTextView addSubview:placeholderLabel];
    
//    wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, 160.0f, 80.0f, 20.0f)];
//    [wordCountLabel setFont:kFont_Light_12];
//    [wordCountLabel setTextColor:kColor_Editable];
//    [wordCountLabel setBackgroundColor:[UIColor clearColor]];
//    [wordCountLabel setTextAlignment:NSTextAlignmentRight];
//    [wordCountLabel setText:@"0/200"];
//    [wordCountLabel setTag:107];
//    [describeTextView addSubview:wordCountLabel];
    
//    cancelButton = [UIButton buttonWithTitle:@""
//                                      target:self
//                                    selector:@selector(cancelAction:)
//                                       frame:CGRectMake(5.0f, 325.0f, 150.0f, 36.0f)
//                               backgroundImg:[UIImage imageNamed:@"common_cancel"]
//                            highlightedImage:nil];
//    [cancelButton setTag:107];
//    [cancelButton setHidden:YES];
//    [self.view addSubview:cancelButton];
//    
//    commentButton = [UIButton buttonWithTitle:@""
//                                       target:self
//                                     selector:@selector(coAction:)
//                                        frame:CGRectMake(165.0f, 325.0f, 150.0f, 36.0f)
//                                backgroundImg:[UIImage imageNamed:@"common_notarize"]
//                             highlightedImage:nil];
//    [commentButton setTag:108];
//    [commentButton setHidden:YES];
//    [self.view addSubview:commentButton];
}

- (void)initData
{
    if (treatmentComment == nil) {
        treatmentComment = [[CommentDoc alloc] init];
    }
}

#pragma mark - dismissKeyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView beginAnimations:@"anim" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    CGRect listFrame = CGRectMake(0.0f, -135, self.view.frame.size.width, self.view.frame.size.height);//处理移动事件，将各视图设置最终要达到的状态
    self.view.frame = listFrame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.view.frame.origin.y != 0) {
        [UIView beginAnimations:@"showKeyboard" context:nil];
        [UIView setAnimationDuration:0.1];
        CGRect rect = self.view.frame;
        rect.origin.y = 0.0f;
        self.view.frame = rect;
        [UIView commitAnimations];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    [describeTextView resignFirstResponder];
}

- (void)initInputAccessoryView
{
    if (accessoryInputView == nil) {
        accessoryInputView  = [[UIToolbar alloc] init];
        accessoryInputView.barStyle = UIBarStyleBlackTranslucent;
        accessoryInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [accessoryInputView sizeToFit];
        CGRect frame1 = accessoryInputView.frame;
        frame1.size.height = 44.0f;
        accessoryInputView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [accessoryInputView setItems:array];
    }
}

#pragma mark - reload

- (void)reloadData
{
    if(treatmentComment.comment_ReviewID == 0) {
        editState = YES;
        editButton.hidden = YES;
        [cancelButton setHidden:NO];
        [commentButton setHidden:NO];
//        [describeTextView setEditable:n];
        treatmentComment.comment_Score = -1;
        describeTextView.textColor = kColor_Editable;
//        [describeTextView setUserInteractionEnabled:YES];
        for (int i = 0; i < 5; i++) {
            UIButton *button = (UIButton *)[bgView viewWithTag:(100 + i)];
            [button setSelected:NO];
            [button setBackgroundImage:[UIImage imageNamed:@"order_CommentStar_0"] forState:UIControlStateNormal];
        }
    } else {
        editState = NO;
        editButton.hidden = NO;
        [cancelButton setHidden:YES];
        [commentButton setHidden:YES];
        [describeTextView setEditable:NO];
        [describeTextView setUserInteractionEnabled:NO];
        for (int i = 0; i < treatmentComment.comment_Score; i++) {
            UIButton *button = (UIButton *)[bgView viewWithTag:(100 + i)];
            [button setSelected:YES];
            [button setBackgroundImage:[UIImage imageNamed:@"order_CommentStar_1"] forState:UIControlStateNormal];
        }
        
        [describeTextView setText:treatmentComment.comment_Describe];
        [wordCountLabel setText:[NSString stringWithFormat:@"%lu/200", (unsigned long)treatmentComment.comment_Describe.length]];
    }
    
    if (treatmentComment.comment_Describe != nil) {
        [placeholderLabel setHidden:YES];
    }
}

#pragma mark - button

- (void)changeStateAction:(id)sender
{
    editButton.hidden = YES;
    editState = YES;
    describeTextView.editable = YES;
    [cancelButton setHidden:NO];
    [commentButton setHidden:NO];
    describeTextView.textColor = kColor_Editable;
    [describeTextView setUserInteractionEnabled:YES];
}

- (void)commentAction:(id)sender
{
    if (editState == YES) {
        UIButton *button = (UIButton *)sender;
        for (int i = 0; i < 5; i++) {
            UIButton *changeButton = (UIButton *)[bgView viewWithTag:(100 + i)];
            if (i <= button.tag - 100) {
                [changeButton setSelected:YES];
                [changeButton setBackgroundImage:[UIImage imageNamed:@"order_CommentStar_1"] forState:UIControlStateNormal];
            } else {
                [changeButton setSelected:NO];
                [changeButton setBackgroundImage:[UIImage imageNamed:@"order_CommentStar_0"] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)cancelAction:(id)sender
{
    editButton.hidden = NO;
    editState = NO;
    describeTextView.editable = NO;
    [cancelButton setHidden:YES];
    [commentButton setHidden:YES];
    describeTextView.textColor = [UIColor blackColor];
    [describeTextView setUserInteractionEnabled:NO];
    for (int i = 0; i < 5; i++) {
        UIButton *button = (UIButton *)[bgView viewWithTag:(100 + i)];
        if (i < treatmentComment.comment_Score) {
            [button setSelected:YES];
            [button setBackgroundImage:[UIImage imageNamed:@"order_CommentStar_1"] forState:UIControlStateNormal];
        } else {
            [button setSelected:NO];
            [button setBackgroundImage:[UIImage imageNamed:@"order_CommentStar_0"] forState:UIControlStateNormal];
        }
    }

    [describeTextView setText:treatmentComment.comment_Describe];
    [wordCountLabel setText:[NSString stringWithFormat:@"%lu/200", (unsigned long)treatmentComment.comment_Describe.length]];
}

- (void)coAction:(id)sender
{
    describeTextView.textColor = [UIColor blackColor];
    editButton.hidden = NO;
    
    int number = 0;
    for (int i = 0; i < 5; i++) {
        UIButton *button = (UIButton *)[bgView viewWithTag:(100 + i)];
        if (button.selected == YES) {
            number++;
        }
    }
    
    CommentDoc *submitCommentDoc = [[CommentDoc alloc] init];
    submitCommentDoc.comment_TreatmentID = treatmentComment.comment_TreatmentID;
    submitCommentDoc.comment_ReviewID = treatmentComment.comment_ReviewID;
    submitCommentDoc.comment_Score = number;
    submitCommentDoc.comment_Describe = describeTextView.text;
    
    if (treatmentComment.comment_ReviewID == 0) {
        [self addCommentWithCommentDoc:submitCommentDoc];
    } else {
        [self updateCommentWithCommentDoc:submitCommentDoc];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self initInputAccessoryView];
    textView.inputAccessoryView = accessoryInputView;
    [placeholderLabel setHidden:YES];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        [placeholderLabel setHidden:NO];
    } else {
        [placeholderLabel setHidden:YES];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char *ch = [text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    //if (*ch == 32) return NO;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *range = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:range.start offset:0];
        if (!position) {
            if (textView.text.length >= 200) {
                return NO;
            }
        }
    } else {
        if (textView.text.length >= 200) {
                return NO;
        }
    }
    if ([text isEqualToString:@""]) {
        return YES;
    }
    return YES;
}

#pragma mark -WordCheck

- (void)wordCountCheck:(NSNotification *)notiFi
{
    UITextView *textView = (UITextView *)notiFi.object;
    NSString *textContext = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *range = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:range.start offset:0];
        if (!position) {
            if (textView.text.length >= 200) {
                textView.text = [textContext substringToIndex:200];
            }
        [wordCountLabel setText:[NSString stringWithFormat:@"%lu/200", (unsigned long)textView.text.length]];
        }
    } else {
        if (textView.text.length >= 200) {
            textView.text = [textContext substringToIndex:200];
        }
        [wordCountLabel setText:[NSString stringWithFormat:@"%lu/200", (unsigned long)textView.text.length]];
    }
    
}
#pragma mark - 接口

- (void)getCommont
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"TreatmentID":@(treatmentComment.comment_TreatmentID)};
    _requestCommentOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Review/GetReviewDetailForTM"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            treatmentComment.comment_ReviewID = [data[@"ReviewID"] integerValue];
            treatmentComment.comment_Score = [data[@"Satisfaction"] intValue];
            treatmentComment.comment_Describe = data[@"Comment"] == [NSNull null] ? nil : data[@"Comment"];
            [self reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];

    } failure:^(NSError *error) {
        
    }];
//    _requestCommentOperation = [[GPHTTPClient shareClient] requestOrderCommentByTreatmentId:treatmentComment.comment_TreatmentID success:^(id xml) {
//        [SVProgressHUD dismiss];
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData) {
//            treatmentComment.comment_ReviewID = [[[[contentData elementsForName:@"ReviewID"] objectAtIndex:0] stringValue] intValue];
//            treatmentComment.comment_Score = [[[[contentData elementsForName:@"Satisfaction"] objectAtIndex:0] stringValue] intValue];
//            treatmentComment.comment_Describe = [[[contentData elementsForName:@"Comment"] objectAtIndex:0] stringValue];
//            [self reloadData];
//        } failure:^{}];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}

- (void)addCommentWithCommentDoc:(CommentDoc *)commentDoc
{
    if (commentDoc.comment_Describe.length > 200) {
        [SVProgressHUD showErrorWithStatus2:@"评价不能超过200个字。"];
        return;
    }
    
    if ((commentDoc.comment_Describe.length == 0 || commentDoc.comment_Describe == nil) && commentDoc.comment_Score == 0) {
        [SVProgressHUD showErrorWithStatus2:@"评价为空。"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Loading"];

    NSDictionary *para = @{@"TreatmentID":@(treatmentComment.comment_TreatmentID),
//                           @"OrderID":@(_orderId),
                           @"Satisfaction":@(commentDoc.comment_Score),
                           @"Comment":commentDoc.comment_Describe};
    _requestCommentOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/review/addReview"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            treatmentComment.comment_Score = commentDoc.comment_Score;
            treatmentComment.comment_Describe = commentDoc.comment_Describe;
            treatmentComment.comment_ReviewID = [data integerValue];
            [self reloadData];
            [SVProgressHUD dismiss];            
        } failure:^(NSInteger code, NSString *error) {
            
        }];

    } failure:^(NSError *error) {
        
    }];
    
//    _requestCommentOperation = [[GPHTTPClient shareClient] requestAddOrderCommentByCommentDoc:commentDoc andOrderID:_orderId success:^(id xml) {
//        [SVProgressHUD dismiss];
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData) {
//            treatmentComment.comment_ReviewID = [[[[contentData elementsForName:@"ReviewID"] objectAtIndex:0] stringValue] intValue];
//            treatmentComment.comment_Score = commentDoc.comment_Score;
//            treatmentComment.comment_Describe = commentDoc.comment_Describe;
//            [self reloadData];
//        } failure:^{}];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}

- (void)updateCommentWithCommentDoc:(CommentDoc *)commentDoc
{
    if (commentDoc.comment_Describe.length > 200) {
        [SVProgressHUD showErrorWithStatus2:@"评价不能超过200个字。"];
        return;
    }
    
    if (commentDoc.comment_Describe.length == 0) {
        commentDoc.comment_Describe = @"";
    }
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"TreatmentID":@(treatmentComment.comment_TreatmentID),
                           @"ReviewID":@(commentDoc.comment_ReviewID),
                           @"Satisfaction":@(commentDoc.comment_Score),
                           @"Comment":commentDoc.comment_Describe};
    _requestCommentOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Review/GetReviewDetailForTM"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {

            treatmentComment.comment_Score = commentDoc.comment_Score;
            treatmentComment.comment_Describe = commentDoc.comment_Describe;
            [self reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        
    }];
    
//    _requestCommentOperation = [[GPHTTPClient shareClient] requestUpdateOrderCommentByCommentDoc:commentDoc success:^(id xml) {
//        [SVProgressHUD dismiss];
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData) {
//            treatmentComment.comment_Score = commentDoc.comment_Score;
//            treatmentComment.comment_Describe = commentDoc.comment_Describe;
//            [self reloadData];
//        } failure:^{}];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}

@end
