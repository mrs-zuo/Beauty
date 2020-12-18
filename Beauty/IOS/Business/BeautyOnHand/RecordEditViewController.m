//
//  RecordEditViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "RecordEditViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "NSString+Additional.h"
#import "DEFINE.h"
#import "SVProgressHUD.h"
#import "RecordDoc.h"
#import "InitialSlidingViewController.h"
#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "NavigationView.h"
#import "UIButton+InitButton.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "FooterView.h"
#import "AppDelegate.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "noCopyTextField.h"
#import "Tags.h"
#import "LabelChooseController.h"
#import "GPBHTTPClient.h"

@interface RecordEditViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *updateRecordInfoOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *addRecordInfoOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *deleteRecordOperation;

@property (strong, nonatomic) UIDatePicker *datePicker;

//
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (assign, nonatomic) CGRect prevCaretRect;

@property (nonatomic, strong) NSMutableArray *tagArray;

@end

@implementation RecordEditViewController
@synthesize recordDoc;
@synthesize isEditing;
@synthesize datePicker;
@synthesize tagArray;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!tagArray) {
        tagArray = [NSMutableArray array];
    }
    [_tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setBaseEditing:NO];
    [self initTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:)   name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)initTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"新增咨询记录"];
    [self.view addSubview:navigationView];
        NSLog(@"the rec_visible1 is %d",recordDoc.IsVisible);
    if (isEditing) {
        navigationView.titleLabel.text = @"编辑咨询记录";
    } else {
        navigationView.titleLabel.text = @"新增咨询记录";
        recordDoc = [[RecordDoc alloc] init];
        recordDoc.IsVisible = NO;
    }
    NSLog(@"the rec_visible123 is %d",recordDoc.IsVisible);
    [_tableView setAllowsSelection:NO];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setAutoresizingMask:UIViewAutoresizingNone];
    [_tableView setDelegate:self];
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f  - 5.0f);
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f  -5.0f);
    }
    
    if (isEditing) {
        FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:nil submitAction:@selector(editRecordAction) deleteImg:nil deleteAction:@selector(deleteAction)];
        [footerView showInTableView:_tableView];
    } else {
        FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:nil  submitTitle:@"确  定" submitAction:@selector(addRecordAction)];
        [footerView showInTableView:_tableView];
    }
    
    _initialTVHeight = _tableView.frame.size.height;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    if (section == 0) return 1;
    if (section == 1) return 2;
    if (section == 2) return 2;
    if (section == 3) return 1;
    if (section == 4) return 2;
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
    //    static NSString *cellIndentify = @"RecordEdit_TITLE_CELL";
    //    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
      //  if (cell == nil) {
      //      cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        NormalEditCell *cell = [[NormalEditCell alloc]init];
            cell.backgroundColor = [UIColor whiteColor];
   //     }
        UITableViewCell *addCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            addCell.textLabel.font = kFont_Light_16;
            addCell.textLabel.textColor = kColor_DarkBlue;
            addCell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (IOS6) {
            addCell.backgroundColor = [UIColor whiteColor];
        }
        
        
        cell.valueText.delegate = self;
        switch (indexPath.section) {
            case 0:
            {
                cell.titleLabel.text = @"时间";
                //去掉可编辑textField，使用nocopytextfield,禁用菜单
                [cell.valueText removeFromSuperview];
                cell.valueText = [[noCopyTextField alloc]init];
                cell.valueText.autoresizingMask = UIViewAutoresizingNone;
                cell.valueText.textColor = kColor_Editable;
                cell.valueText.font = kFont_Light_16;
                cell.valueText.textAlignment = NSTextAlignmentRight;
                cell.valueText.borderStyle = UITextBorderStyleNone;
                cell.valueText.returnKeyType = UIReturnKeyDone;
                cell.valueText.delegate = self;
                cell.valueText.frame = CGRectMake(100.0f, kTableView_HeightOfRow/2 - 30.0f/2, 200, 30.0f);
                if (IOS6) {
                    cell.valueText.frame = CGRectMake(100.0f, kTableView_HeightOfRow/2 - 7.0, 200, 30.0f);
                }
                cell.valueText.text = recordDoc.RecordTime;
                cell.valueText.userInteractionEnabled = YES;
                if((IOS7 || IOS8))
                    [cell.valueText setTintColor:[UIColor clearColor]];
                cell.valueText.placeholder = @"请点击输入咨询日期";
                [cell addSubview:cell.valueText];
                UIButton *button = (UIButton *)[cell viewWithTag:1010];
                if (button) {
                    [button removeFromSuperview];
                }
                break;
            }
            case 1:
            {
                cell.titleLabel.text = @"咨询";
                cell.valueText.text = @"";
                cell.valueText.userInteractionEnabled = NO;
                UIButton *button = (UIButton *)[cell viewWithTag:1010];
                if (button) {
                    [button removeFromSuperview];
                }
                break;
            }
            case 2:
            {
                cell.titleLabel.text = @"建议";
                cell.valueText.text = @"";
                cell.valueText.userInteractionEnabled = NO;
                UIButton *button = (UIButton *)[cell viewWithTag:1010];
                if (button) {
                    [button removeFromSuperview];
                }
                break;
            }
            case 3:
            {
                cell.titleLabel.text = @"允许顾客查看";
                cell.valueText.text = @"";
                UIButton *permitButton = [UIButton buttonWithTitle:@""
                                                          target:self
                                                        selector:@selector(permitAction:)
                                                           frame:CGRectMake(277.0f, 9.0f, 21.0f, 21.0f)
                                                     backgroundImg:(recordDoc.IsVisible ? [UIImage imageNamed:@"zixun_Permit"]:[UIImage imageNamed:@"zixun_NoPermit"])
                                                highlightedImage:nil];
                permitButton.tag = 1010;
//                [permitButton setImage:[UIImage imageNamed:@"zixun_NoPermit"] forState:UIControlStateSelected];
                UIButton *button = (UIButton *)[cell viewWithTag:1010];
                if ( !button ) {
                   [cell addSubview:permitButton];
                }
                UITapGestureRecognizer *cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(permitAction:)];
                cellTap.numberOfTapsRequired = 1;
                cellTap.numberOfTouchesRequired = 1;
                cellTap.delegate = self;
                cell.valueText.userInteractionEnabled = NO;
                [cell.contentView addGestureRecognizer:cellTap];
                break;
            }
            case 4:
            {
                addCell.textLabel.text = @"标签";
                UIButton *editButton = [UIButton buttonWithTitle:@""
                                                          target:self
                                                        selector:@selector(changeRemark)
                                                           frame:CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                                   backgroundImg:[UIImage imageNamed:@"tjbiaoqian"]
                                                highlightedImage:nil];
                editButton.tag = 1003;
                if (IOS6) {
                    editButton.frame = CGRectMake(262, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
                }
                [addCell.contentView addSubview:editButton];
                
                return addCell;
            }
            default:
                break;
        }
        return cell;
        
    } else {
    
        if (indexPath.section == 4) {
            UITableViewCell *viewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            viewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (IOS6) {
                viewCell.backgroundColor = [UIColor whiteColor];
            }
            [self addLabel:tagArray cell:viewCell];
            return viewCell;

        } else {
            static NSString *cellIndentify = @"RecordEdit_Content_CELL";
            ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                cell.backgroundColor = [UIColor whiteColor];
            }
            cell.delegate = self;
            cell.contentEditText.returnKeyType = UIReturnKeyDefault;
            switch (indexPath.section) {
                case 1:
                    [cell setContentText:recordDoc.Problem];
                    break;
                case 2:
                    [cell setContentText:recordDoc.Suggestion];
                    break;
            }
            return cell;
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return kTableView_HeightOfRow;
    } else {
        if (indexPath.section == 1) {
            return recordDoc.height_Problem;
        } else if (indexPath.section == 2) {
            return recordDoc.height_Suggestion;
        } else if (indexPath.section == 4) {
            return kTableView_HeightOfRow;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 3 && indexPath.row == 0) {
//        UIButton *button = (UIButton *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:1010];
//        button.selected = !button.selected;
//        recordDoc.rec_Visible = !button.selected;
//    }
//}

#pragma mark tag
- (void)addLabel:(NSArray *)array cell:(UITableViewCell *)cell
{
    
    for (int i = 0; i < [array count]; i ++) {
        Tags *thetag = (Tags *)[array objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bqshanchu"]];
        CGRect lastFrame;
        if (i == 0) {
            lastFrame = CGRectMake(5, 11, 0, 0);
        } else
            lastFrame = ((UIButton *)[cell.contentView.subviews lastObject]).frame;
        CGPoint point = CGPointMake(lastFrame.origin.x + lastFrame.size.width, lastFrame.origin.y);
        NSString *name = nil;
        if (thetag.Name.length > 5) {
            name = [[thetag.Name substringToIndex:5] stringByAppendingString:@"…"];
            
        } else
            name = thetag.Name;
        CGSize size = [name sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(80, 20) lineBreakMode:NSLineBreakByTruncatingTail];
        
        
        
        
        imageView.frame = CGRectMake(size.width, -5, 15, 15);
        size.width += 20;
        CGRect newFrame = CGRectMake(point.x, point.y ,size.width ,size.height );
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        label.textAlignment = NSTextAlignmentLeft;
        label.font = kFont_Light_16;
        label.text = name;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.backgroundColor = [UIColor clearColor];
        
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        //        label.lineBreakMode = UILineBreakModeTailTruncation;
        //        button.titleLabel.font = kFont_Light_16;
        //        button.titleLabel.frame = CGRectMake(0, 0, 80, 16);
        //        [button setTitle:thetag.Name forState:UIControlStateNormal];
        //        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        button.frame = newFrame;
        
        button.tag = i;
        [button addSubview:imageView];
        [button addSubview:label];
        [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:button];
        
    }
    
}


- (void)click:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    
    NSLog(@"the click label Tag is %ld", (long)((UILabel *)sender).tag);
    NSInteger tag = button.tag;
    if (IOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否删除标签：%@",((Tags *)tagArray[tag]).Name] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [tagArray removeObjectAtIndex:tag];
            NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:4];
            [_tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"cancle click");
        }];
        
        [alert addAction:action1];
        [alert addAction:action2];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"是否删除标签：%@",((Tags *)tagArray[tag]).Name] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [tagArray removeObjectAtIndex:tag];
                NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:4];
                [_tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        
    }
    
}




#pragma mark permitAction
- (void)permitAction:(id)sender
{
//    UIButton *button = (UIButton *)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    UIButton *button = (UIButton *)[[_tableView cellForRowAtIndexPath:indexPath] viewWithTag:1010];
    button.selected = !button.selected;
    NSLog(@"the rec is1 %d",recordDoc.IsVisible);
    recordDoc.IsVisible = !recordDoc.IsVisible;
    [button setBackgroundImage: (recordDoc.IsVisible ? [UIImage imageNamed:@"zixun_Permit"]:[UIImage imageNamed:@"zixun_NoPermit"]) forState:UIControlStateNormal];
    NSLog(@"the rec is2 %d",recordDoc.IsVisible);
//    button.selected = !button.selected;
//    recordDoc.rec_Visible = button.selected;
//    button.imageView = [UIImage imageNamed:@"zixun_NoPermit"];
    
}


#pragma mark chooseTag
- (void)changeRemark
{
    [self.view endEditing:YES];
    LabelChooseController *lab = [[LabelChooseController alloc] init];
    lab.chooseArray = tagArray;
    lab.type = CHOOSEADD;
    [self.navigationController pushViewController:lab animated:YES];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.textField_Selected = textField;
    [self scrollToTextField:textField];
    
    NSIndexPath *indexPath;
    if (IOS6 || IOS8) {
        NormalEditCell *cell = (NormalEditCell *)textField.superview.superview;
        indexPath = [_tableView indexPathForCell:cell];
    } else if (IOS7) {
        NormalEditCell *cell = (NormalEditCell *)textField.superview.superview.superview;
        indexPath = [_tableView indexPathForCell:cell];
    }
    
    if (indexPath.section == 0) {
        if (datePicker == nil) {
            datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
            [datePicker setDate:[NSDate date]];
            [datePicker setDatePickerMode:UIDatePickerModeDate];
            [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
            [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            CGRect frame = self.inputView.frame;
            frame.size = [datePicker sizeThatFits:CGSizeZero];
            self.inputView.frame = frame;
            datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        }
        
        __autoreleasing UIToolbar *inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [inputAccessoryView sizeToFit];
        CGRect frame1 = inputAccessoryView.frame;
        frame1.size.height = 44.0f;
        inputAccessoryView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:kColor_White];
        
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [inputAccessoryView setItems:array];
        
        textField.inputView = datePicker;
        textField.inputAccessoryView = inputAccessoryView;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)dateChanged:(id)sender
{
    NormalEditCell *cell = (NormalEditCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *dateStr = [NSString stringWithFormat:@"%@", [datePicker.date.description substringToIndex:10]];
    [cell.valueText setText:dateStr];
    [recordDoc setRecordTime:dateStr];
}

- (void)done:(id)sender
{
    [self dateChanged:nil];
    [super dismissKeyBoard];
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
            if (textView.text.length >= 300) {
                textView.text = [textContext substringToIndex:300];
            }
        }
    } else {
        if (textView.text.length >= 300) {
            textView.text = [textContext substringToIndex:300];
        }
    }
}
#pragma mark - ContentEditCellDelegate

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    self.textView_Selected = contentText;
   // [self scrollToTextView:contentText];
   // [self scrollToCursorForTextView:contentText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordCountCheck:) name:UITextViewTextDidChangeNotification object:contentText];
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
   // [self scrollToTextView:textView];
   [self scrollToCursorForTextView:textView];
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (indexPath.section == 1) {
        [recordDoc setProblem:contentText.text];
    } else if (indexPath.section == 2) {
        [recordDoc setSuggestion:contentText.text];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:contentText];
    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char *ch = [text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    //if (*ch == 32) return NO;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *range = [contentText markedTextRange];
        UITextPosition *position = [contentText positionFromPosition:range.start offset:0];
        if (!position) {
            if (contentText.text.length >= 300) {
                return NO;
            }
        }
    } else {
        if (contentText.text.length >= 300) {
            return NO;
        }
    }
    if ([text isEqualToString:@""]) {
        return YES;
    }
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (indexPath.section == 1 && indexPath.row == 1) {
        recordDoc.height_Problem = height;
        recordDoc.Problem = contentText.text;
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        recordDoc.height_Suggestion = height;
        recordDoc.Suggestion = contentText.text;
    }
    
    [_tableView beginUpdates];
    [_tableView endUpdates];
}


#pragma mark - Keyboard Notification

-(void)keyboardWillShown:(NSNotification*)notification {
    
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
    _tableView.frame = tvFrame;
    [UIView commitAnimations];
    
   // [self scrollToTextField:self.textField_Selected];
}

-(void)keyboardWillHidden:(NSNotification*)notification
{
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _tableView.frame = tvFrame;
}

- (void)scrollToTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath* path = [_tableView indexPathForCell:cell];
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)scrollToTextView:(UITextView *)textView
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview;
    }
    NSIndexPath* path = [_tableView indexPathForCell:cell];
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.end];
    CGRect newCursorRect = [_tableView convertRect:cursorRect fromView:textView];
    NSLog(@"the origin y is %f, %f ,%f %@",cursorRect.origin.y, newCursorRect.origin.y ,newCursorRect.size.height,textView.selectedTextRange.start );
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        _prevCaretRect = newCursorRect;
        [self.tableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(290.0f, 500.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    rect.size.width = 300;
    textView.frame = rect;
    
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

- (void)dismissKeyBoard
{
    [self.textField_Selected resignFirstResponder];
    [self.textView_Selected resignFirstResponder];
    
    
    if (_initialTVHeight != 0) {
        CGRect tableFrame = _tableView.frame;
        tableFrame.size.height =  _initialTVHeight;
        _tableView.frame = tableFrame;
    }
}


#pragma mark - Custom

- (void)addRecordAction
{
    [self.textField_Selected resignFirstResponder];
    [self.textView_Selected resignFirstResponder];
    
    if (recordDoc.RecordTime.length == 0 || recordDoc.Problem.length == 0) {
        [SVProgressHUD showErrorWithStatus2:@"时间和咨询不允许为空！" touchEventHandle:^{}];
        return;
    }
    
    if (kMenu_Type == 1) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        recordDoc.CustomerID = appDelegate.customer_Selected.cus_ID;
        NSMutableString *string = [NSMutableString string];
        if ([tagArray count]) {
            for (Tags *ta in tagArray) {
                [string appendFormat:@"|%ld",(long)ta.tagID];
            }
            [string appendString:@"|"];
        }

        recordDoc.tagIDs = string;
        [self addRecordInfoWithRecordDoc:recordDoc];
    }
}

- (void)editRecordAction
{
    [self.textField_Selected resignFirstResponder];
    [self.textView_Selected resignFirstResponder];
    
    if (recordDoc.RecordTime.length == 0 || recordDoc.Problem.length == 0) {
        [SVProgressHUD showErrorWithStatus2:@"时间和咨询不允许为空！" touchEventHandle:^{}];
        return;
    }

    [self updateRecordInfoWithRecordDoc:recordDoc];
}

- (void)deleteAction
{
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定删除该记录?" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alterView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
        [self deleteRecordInfoWithRecordId:recordDoc.RecordID];
        }
    }];
}

#pragma mark - 接口

- (void)updateRecordInfoWithRecordDoc:(RecordDoc *)newRecordDoc
{
    [SVProgressHUD showWithStatus:@"Loading"];
//    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"CompanyID\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"TagIDs\":\"%@\"}", ];
//
//    _updateRecordInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Record/updateRecord" andParameters:nil WithSuccess:^(id json) {
//        
//    } failure:^(NSError *error) {
//        
//    }];
    
    
    
    
    _updateRecordInfoOperation = [[GPHTTPClient shareClient] requestUpdateRecordInfoWithRecordInfo:newRecordDoc success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {} failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)addRecordInfoWithRecordDoc:(RecordDoc *)newRecordDoc
{
    if (kMenu_Type == 1 && ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNoChooserCustomerNotification object:nil];
        return;
    }

    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"CompanyID\":%ld,\"AccountID\":%ld,\"CustomerID\":%ld,\"RecordTime\":\"%@\",\"Problem\":\"%@\",\"Suggestion\":\"%@\",\"TagIDs\":\"%@\",\"IsVisible\":%ld}", (long)ACC_BRANCHID, (long)ACC_COMPANTID, (long)ACC_ACCOUNTID, (long)newRecordDoc.CustomerID, newRecordDoc.RecordTime, [OverallMethods EscapingString:newRecordDoc.Problem], [OverallMethods EscapingString:newRecordDoc.Suggestion], newRecordDoc.tagIDs, (long)newRecordDoc.IsVisible];
    
    _updateRecordInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Record/addRecord" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];

    
    /*
    _updateRecordInfoOperation = [[GPHTTPClient shareClient] requestAddRecordInfoWithRecordInfo:newRecordDoc success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {} failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}

- (void)deleteRecordInfoWithRecordId:(NSInteger)recordId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"RecordID\":%ld}", (long)ACC_ACCOUNTID, (long)recordId];
    
    _updateRecordInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Record/deleteRecord" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];

    } failure:^(NSError *error) {
        
    }];

    
    /*
    
    _deleteRecordOperation = [[GPHTTPClient shareClient] requestDeleteRecordInfoWithRecordId:recordId success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {} failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}



@end
