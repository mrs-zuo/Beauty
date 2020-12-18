//
//  noCopyTextField.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-4-16.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface noCopyTextField : UITextField

- (id)initWithText:(NSString *)text
              frame:(CGRect)frame
                tag:(NSInteger)tag
          textColor:(UIColor*)color
        placeHolder:(NSString *)placeHolderText
      textAlignment:(NSTextAlignment)textAlignment
           delegate:(id)delegate;
@end
