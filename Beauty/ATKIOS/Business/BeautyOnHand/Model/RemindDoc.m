//
//  RemindDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-9.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "RemindDoc.h"
#import "UIPlaceHolderTextView.h"
#import "DEFINE.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"

@implementation RemindDoc



/*
- (CGFloat)remind_Height
{

    SignTextView *textField = [SignTextView share];
    CGSize maxSize = CGSizeMake(250, MAXFLOAT);
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:_remind_Content];
    NSMutableParagraphStyle *stringStyle = [[NSMutableParagraphStyle alloc] init];
    [stringStyle setLineSpacing:4];
    [attriString addAttribute:NSParagraphStyleAttributeName value:stringStyle range:NSMakeRange(0, [_remind_Content length])];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [_remind_Content length])];
    [attriString addAttribute:NSFontAttributeName value:kFont_Light_14 range:NSMakeRange(0, [_remind_Content length])];
    textField.attributedText = attriString;
    
    CGSize contentSize;
    if (IOS6) {
        textField.text = _remind_Content;
        contentSize = [textField.text sizeWithFont:kFont_Light_14 constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
        contentSize.height += 10;
    } else {
        contentSize = [textField sizeThatFits:maxSize];
    }
    return contentSize.height ;
    
}
*/

+ (NSAttributedString *)theHeight:(NSString *)content
{
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:content];
    NSMutableParagraphStyle *stringStyle = [[NSMutableParagraphStyle alloc] init];
    [stringStyle setLineSpacing:4];
    [attriString addAttribute:NSParagraphStyleAttributeName value:stringStyle range:NSMakeRange(0, [content length])];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [content length])];
    [attriString addAttribute:NSFontAttributeName value:kFont_Light_14 range:NSMakeRange(0, [content length])];
    return attriString;
}

+ (AFHTTPRequestOperation *)requestRemindList:(void (^)(NSArray *, NSError *))block
{
    NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"BranchID\":%ld}", (long)ACC_ACCOUNTID, (long)ACC_BRANCHID];

    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Notice/GetRemindListByAccountID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSMutableArray *remindList = [NSMutableArray array];
            UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, MAXFLOAT)];
            textField.font = kFont_Light_14;
            textField.allowsEditingTextAttributes = YES;
            CGSize maxSize = CGSizeMake(250, MAXFLOAT);
            
            NSArray *vistArray = [data objectForKey:@"VisitList"];
            NSArray *remindArray = [data objectForKey:@"RemindList"];
            NSArray *birthdayArray = [data objectForKey:@"BirthdayList"];
            if ((NSNull *)vistArray == [NSNull null]) {
                vistArray = nil;
            }
            if ((NSNull *)remindArray == [NSNull null]) {
                remindArray = nil;
            }
            if ((NSNull *)birthdayArray == [NSNull null]) {
                birthdayArray = nil;
            }

            [remindArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                RemindDoc *visit = [[RemindDoc alloc] init];
                [visit setRemind_Content:[obj objectForKey:@"RemindContent"]];
                [visit setRemind_Time:[obj objectForKey:@"ScheduleTime"]];
                [visit setOrderID:[[obj objectForKey:@"OrderID"] integerValue]];
                [visit setRemind_Type:RemindTypeService];
                textField.attributedText = [self theHeight:visit.remind_Content];
                if (IOS6) {
                    [visit setRemind_Height:([visit.remind_Content sizeWithFont:kFont_Light_14 constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping].height + 10)];
                } else {
                    [visit setRemind_Height:[textField sizeThatFits:maxSize].height];
                }
                [remindList addObject:visit];
            }];
            
            [vistArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                RemindDoc *visit = [[RemindDoc alloc] init];
                [visit setRemind_Content:[obj objectForKey:@"RemindContent"]];
                [visit setRemind_Time:[obj objectForKey:@"UpdateTime"]];
                [visit setOrderID:[[obj objectForKey:@"OrderID"] integerValue]];
                [visit setRemind_Type:RemindTypeVisit];
                textField.attributedText = [self theHeight:visit.remind_Content];
                if (IOS6) {
                    [visit setRemind_Height:([visit.remind_Content sizeWithFont:kFont_Light_14 constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping].height + 10)];
                } else {
                    [visit setRemind_Height:[textField sizeThatFits:maxSize].height];
                }
                [remindList addObject:visit];
            }];

            [birthdayArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                RemindDoc *visit = [[RemindDoc alloc] init];
                [visit setRemind_Content:[obj objectForKey:@"RemindContent"]];
                [visit setRemind_Brith:[obj objectForKey:@"BirthDay"]];
                [visit setRemind_Type:RemindTypeBrithday];
                textField.attributedText = [self theHeight:visit.remind_Content];
                if (IOS6) {
                    [visit setRemind_Height:([visit.remind_Content sizeWithFont:kFont_Light_14 constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping].height + 10)];
                } else {
                    [visit setRemind_Height:[textField sizeThatFits:maxSize].height];
                }
                [remindList addObject:visit];
            }];
            if (block) {
                block([remindList copy], nil);
            }
        } failure:^(NSInteger code, NSString *error) {
            if (error.length == 0) {
                error = @"网络异常";
            }
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];

        }];
    } failure:^(NSError *error) {
        block([NSArray array], error);
    }];
    
    
    
    
    
    
    /*
    return  [[GPHTTPClient shareClient] requestGetRemindListWithSuccess:^(id xml) {
                [GDataXMLDocument parseXML2:xml success:^(GDataXMLElement *contentData, NSString *mesg) {
                NSMutableArray *remindList = [NSMutableArray array];
                UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, MAXFLOAT)];
                textField.font = kFont_Light_14;
                textField.allowsEditingTextAttributes = YES;
                CGSize maxSize = CGSizeMake(250, MAXFLOAT);
                
                for (GDataXMLElement *data in [contentData elementsForName:@"Visit"]) {
                    RemindDoc *visit = [[RemindDoc alloc] init];
                    [visit setRemind_Content:[[[data elementsForName:@"RemindContent"] objectAtIndex:0] stringValue]];
                    [visit setRemind_Time:[[[data elementsForName:@"UpdateTime"] objectAtIndex:0] stringValue]];
                    [visit setOrderID:[[[[data elementsForName:@"OrderID"] objectAtIndex:0] stringValue] integerValue]];
                    [visit setRemind_Type:RemindTypeVisit];
                    textField.attributedText = [self theHeight:visit.remind_Content];
                    
                    if (IOS6) {
                        [visit setRemind_Height:([visit.remind_Content sizeWithFont:kFont_Light_14 constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping].height + 10)];
                    } else {
                        [visit setRemind_Height:[textField sizeThatFits:maxSize].height];
                    }
                    
                    [remindList addObject:visit];

                }
                for (GDataXMLElement *data in [contentData elementsForName:@"Remind"]) {
                    RemindDoc *remind = [[RemindDoc alloc] init];
                    [remind setRemind_Content:[[[data elementsForName:@"RemindContent"] objectAtIndex:0] stringValue]];
                    [remind setRemind_Time:[[[data elementsForName:@"ScheduleTime"] objectAtIndex:0] stringValue]];
                    [remind setOrderID:[[[[data elementsForName:@"OrderID"] objectAtIndex:0] stringValue] integerValue]];
                    [remind setRemind_Type:RemindTypeService];

                    textField.attributedText = [self theHeight:remind.remind_Content];

                    if (IOS6) {
                        [remind setRemind_Height:([remind.remind_Content sizeWithFont:kFont_Light_14 constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping].height + 10)];
                    } else {
                        [remind setRemind_Height:[textField sizeThatFits:maxSize].height];
                    }

                    [remindList addObject:remind];
                }
                for (GDataXMLElement *data in [contentData elementsForName:@"Birthday"]) {
                    RemindDoc *brith = [[RemindDoc alloc] init];
                    [brith setRemind_Content:[[[data elementsForName:@"RemindContent"] objectAtIndex:0] stringValue]];
                    [brith setRemind_Brith:[[[data elementsForName:@"BirthDay"] objectAtIndex:0] stringValue]];
                    [brith setRemind_Type:RemindTypeBrithday];
                    
                    textField.attributedText = [self theHeight:brith.remind_Content];

                    if (IOS6) {
                        [brith setRemind_Height:([brith.remind_Content sizeWithFont:kFont_Light_14 constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping].height + 10)];
                    } else {
                        [brith setRemind_Height:[textField sizeThatFits:maxSize].height];
                    }

                    [remindList addObject:brith];
                }

                    if (block) {
                        block([remindList copy], nil);
                    }
                
            } failure:^(NSString *mesg, NSInteger errorFlag) {
                if (mesg.length == 0) {
                    mesg = @"网络异常";
                }
                [SVProgressHUD showErrorWithStatus2:mesg touchEventHandle:^{}];
            }];
        
    } failure:^(NSError *error) {
        block([NSArray array], error);
    }];
    */
}



@end
