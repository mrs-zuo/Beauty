//
//  NumTextField.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-2-2.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TEXTTYPE) {
    TEXTTYPEMONEY,
    TEXTTYPENUM
};
@class NumTextField;
typedef void (^TextFieldStartEdit)(NumTextField *textField);
typedef void (^TextFieldEndEdit)(NumTextField *textField);

@interface NumTextField : UITextField<UITextFieldDelegate>
@property (nonatomic, assign) int textLength;
@property (nonatomic, assign) TEXTTYPE  inputType;
@property (nonatomic, strong) TextFieldStartEdit startBlock;
@property (nonatomic, strong) TextFieldEndEdit   endBlock;
@end
