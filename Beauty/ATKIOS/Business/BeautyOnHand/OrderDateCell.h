////
////  OrderDateCell.h
////  GlamourPromise.Cosmetology.B
////
////  Created by GuanHui on 13-8-5.
////  Copyright (c) 2013年 ZhongHe. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//
//typedef enum {
//     OrderDateCellModeDisplayCourse,  // 显示课程时间      [状态:titleNumber、图标(完成、备注、上传图片)、不可编辑的TextField]
//     OrderDateCellModeDisplayContact, // 显示联系时间      [状态:titleNumber、不可编辑的TextField]
//} OrderDateCellMode;
//
//@protocol OrderDateCellDelete;
//
//@class ScheduleDoc;
//@class OrderEditViewController;
//@interface OrderDateCell : UITableViewCell<UITextFieldDelegate>
//@property (nonatomic) UILabel *titleLabel;
//@property (nonatomic) UILabel *accNameLabel;
//@property (nonatomic) UITextField *timeText;
//@property (nonatomic) UIButton *deleteBtn;
//@property (nonatomic) UIImageView *statusImgView0;  // treatment完成状态
//@property (nonatomic) UIImageView *statusImgView1;  // 是否填写了remark
//@property (nonatomic) UIImageView *statusImgView2;  // 是否上传了图片
//@property (nonatomic) UIImageView *statusImgView3;  // 是否评价了该treatment
//
//@property (weak, nonatomic) id <OrderDateCellDelete> delegate;
//@property (weak, nonatomic) OrderEditViewController *orderEditViewController;
//
//- (void)updateData:(ScheduleDoc *)scheduleDoc mode:(OrderDateCellMode)orderDateCellMode canEdited:(BOOL)edited;
//@end
//
//@protocol OrderDateCellDelete <NSObject>
//- (void)chickDeleteRowButton:(OrderDateCell *)cell;
//@end
