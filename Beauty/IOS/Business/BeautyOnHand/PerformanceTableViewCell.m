//
//  PerformanceTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/27.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "PerformanceTableViewCell.h"
#import "UserDoc.h"

@interface PerformanceTableViewCell ()<UITextFieldDelegate>

@property (nonatomic,assign)BOOL isHaveDian;

@end
@implementation PerformanceTableViewCell

- (void)awakeFromNib {
    NSNumber *isComissionCalc = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_isComissionCalc"];
    if (isComissionCalc.boolValue) {
        _numText.hidden = NO;
        _percentLab.hidden = NO;
        _numText.enabled = YES;
    }else{
        _numText.hidden = YES;
        _percentLab.hidden = YES;
        _numText.enabled = NO;
    }
    _numText.keyboardType = UIKeyboardTypeDecimalPad;
    _numText.delegate =self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
     NSLog(@"textField(已经输入的字符) == %@ \n range(当前输入字符位置) == %@ \n string(当前输入字符) == %@ \n",textField.text,NSStringFromRange(range),string);
    if ([textField.text rangeOfString:@"."].location==NSNotFound) {
        self.isHaveDian=NO;
    }
    if ([string length]>0){ //输入字符
        unichar single=[string characterAtIndex:0];//当前输入的字符
        if ((single >='0' && single<='9') || single=='.')//数据格式正确
        {
            //首字母不能为0和小数点
//            if([textField.text length]==0){
//                if(single == '.'){
//                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
//                    return NO;
//                }
//                if (single == '0') {
//                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
//                    return NO;
//                }
//            }
            if (single=='.'){ //当前输入的字符是点
                if(!self.isHaveDian)//text中还没有小数点
                {
                    self.isHaveDian =YES;
                }else{
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }else{
                if (self.isHaveDian){//存在小数点
                    //判断小数点的位数
                    NSRange ran=[textField.text rangeOfString:@"."];
                    NSUInteger tt=range.location-ran.location;
                    if (tt > 2) {
                        return NO;
                    }
                }
            }
        }else{//输入的数据格式不正确
            [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(PerformanceTableViewCellWithDidBeginEditing:)]) {
        [self.delegate PerformanceTableViewCellWithDidBeginEditing:textField];
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(PerformanceTableViewCellWithDidEndEditing:)]) {
        [self.delegate PerformanceTableViewCellWithDidEndEditing:textField];
    }
    
}



@end
