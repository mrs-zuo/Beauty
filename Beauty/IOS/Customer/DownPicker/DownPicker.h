//
//   DownPicker.h
// --------------------------------------------------------
//      Lightweight DropDownList/ComboBox control for iOS
//
// by Darkseal, 2013-2015 - MIT License
//
// Website: http://www.ryadel.com/
// GitHub:  http://www.ryadel.com/
//

#import <UIKit/UIKit.h>
@protocol labelBalanceChange <NSObject>
-(void)labelBalanceChanges:(NSString*)labelBalance;
-(void)indexRow:(NSInteger)didSelectPicker;

@end
@interface DownPicker : UIControl<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    UIPickerView* pickerView;
    IBOutlet UITextField* textField;
    NSMutableArray* dataArray;
    NSString* placeholder;
    NSString* placeholderWhileSelecting;
	NSString* toolbarDoneButtonText;
	UIBarStyle toolbarStyle;
    NSMutableArray *dataBalanceArray;
    NSString *_orderIsPaid;
}
@property (strong, nonatomic)IBOutlet UILabel *labelBalance;
@property (nonatomic, readonly) NSString* text;
@property (weak, nonatomic) id<labelBalanceChange>delegate;
@property (assign, nonatomic)NSInteger indexRow;

-(void) setOrderIsPaid:(NSString *)orderIsPaid;
-(id)initWithTextField:(UITextField *)tf;
-(id)initWithTextField:(UITextField *)tf withData:(NSMutableArray*) data;
-(void) setArrowImage:(UIImage*)image;
-(void) setData:(NSMutableArray*) data;
-(void) setDataBalance:(NSMutableArray*) data;
-(void) setPlaceholder:(NSString*)str;
-(void) setPlaceholderWhileSelecting:(NSString*)str;
-(void) setToolbarDoneButtonText:(NSString*)str;
-(void) setToolbarStyle:(UIBarStyle)style;
-(void) showArrowImage:(BOOL)b;
-(UIPickerView*) getPickerView;
-(UITextField*) getTextField;
-(void) setValueAtIndex:(NSInteger)index;
@end
