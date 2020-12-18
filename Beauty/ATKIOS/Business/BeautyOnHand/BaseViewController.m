//
//  BaseViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-12-5.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

// 作用
// 1、Tap View ==> 隐藏keyboard的功能
// 2、register Notification When keyboard show && hide ==> 对于编辑TableView中的内容时  tableView自动改变the height of tableView
// 3、后期加入 将向右滑动的 实现pop viewController
// 4、统一设置view的背景颜色
// 5、后期加入 将leftBarButton and rightBarButon 加入到the viewController


#import "BaseViewController.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "InitialSlidingViewController.h"

@interface BaseViewController ()
@property (weak, nonatomic) UITableView *tableView;
@property (assign, nonatomic) CGFloat standardHeight;
@property (assign ,nonatomic) BOOL keyBordWillShow;
@end

@implementation BaseViewController
@synthesize baseEditing;
@synthesize textField_Selected;
@synthesize textView_Selected;
@synthesize tableView;
@synthesize standardHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

// -- view did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.keyBordWillShow = NO;
    self.view.frame = [[[UIApplication sharedApplication] keyWindow] bounds];
   
    self.view.backgroundColor = kColor_Background_View;

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// --view did appear (add keyboardShow/keyboardHide/Tap when baseEditing is YES)
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if (baseEditing) {
        for (UIView *view in self.view.subviews) {
           if ([view isKindOfClass:[UITableView class]])
               tableView = (UITableView *)view;
            break;
        }
        
        standardHeight = kSCREN_BOUNDS.size.height - (20 + 44) - (HEIGHT_NAVIGATION_VIEW + 5);
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
        tapGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
//    }
    NSLog(@"the nsnotificationCenter is %@",[NSNotificationCenter defaultCenter]);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{   
    NSValue *keyboardValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [keyboardValue getValue:&keyboardRect];
    
    NSValue *animationDurationValue = [notification userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    CGFloat off_Height = kSCREN_BOUNDS.size.height - (20 + 44) - (HEIGHT_NAVIGATION_VIEW + 5) - keyboardRect.size.height;
    
    [UIView beginAnimations:@"showKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect table_Rect = tableView.frame;
    table_Rect.size.height = off_Height;
    tableView.frame = table_Rect;
    [UIView commitAnimations];
    
    self.keyBordWillShow = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (tableView.frame.size.height != standardHeight) {
        NSValue *animationDurationValue = [notification userInfo][UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        [UIView beginAnimations:@"showKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        CGRect table_Rect = tableView.frame;
        table_Rect.size.height = standardHeight;
        tableView.frame = table_Rect;
        [UIView commitAnimations];
    }
    self.keyBordWillShow = NO;
}

- (void)dismissKeyBoard
{
    [self.view endEditing:YES];
    [textView_Selected resignFirstResponder];
    [textField_Selected resignFirstResponder];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer.view isKindOfClass:[UIButton class]]) {
        return YES;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
//    NSLog(@"%@", NSStringFromClass([touch.view class]));
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        if (self.keyBordWillShow) {
            return YES;
        }
        return NO;
    }
    return  YES;
}

@end
