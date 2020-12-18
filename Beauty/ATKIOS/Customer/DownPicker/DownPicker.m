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


#import "DownPicker.h"

@implementation DownPicker

// @synthesize text;
-(void) setOrderIsPaid:(NSString *)orderIsPaid
{
    _orderIsPaid = orderIsPaid;
}


-(void) setDataBalance:(NSMutableArray*) data{
    dataBalanceArray = data;
    
    
}




-(id)initWithTextField:(UITextField *)tf
{
    return [self initWithTextField:tf withData:nil];
}

-(id)initWithTextField:(UITextField *)tf withData:(NSMutableArray*) data
{
    self = [super init];
    if (self) {
        
        self->textField = tf;
        self->textField.font = kFont_Light_16;
        self->textField.textAlignment = NSTextAlignmentRight;
        self->textField.delegate = self;
     
        
        // set UI defaults
        self->toolbarStyle = UIBarStyleDefault;
		
        // set language defaults
        if (data.count == 0) {
            self->placeholder = @"Tap to choose...";
        }else{
        self->placeholder = [data objectAtIndex:0] ;
        }
       self->placeholderWhileSelecting = @"Pick an option...";
       // self->placeholder = [NSString stringWithFormat:@"%@",[data objectAtIndex:0]];
		self->toolbarDoneButtonText = @"Done";
        if ([self->textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            UIColor *color = kColor_TitlePink;
            self->textField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:placeholder attributes:@{NSForegroundColorAttributeName:color}];
        }
        // hide the caret and its blinking
        [[textField valueForKey:@"textInputTraits"]
         setValue:[UIColor clearColor]
         forKey:@"insertionPointColor"];
        
        // set the placeholder
        self->textField.placeholder = self->placeholder;
        
        
        // show the arrow image
//        self->textField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"downArrow.png"]];
//        self->textField.rightView.contentMode = UIViewContentModeScaleAspectFit;
//        self->textField.rightView.clipsToBounds = YES;
//        [self setArrowImage:[UIImage imageNamed:@"downArrow.png"]];
//        [self showArrowImage:YES];

        // set the data array (if present)
        if (data != nil) {
            [self setData: data];
        }
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{   
    self->textField.text = [dataArray objectAtIndex:row] ;
    _indexRow = row;
//    _labelBalance = [[UILabel alloc]init];
//    _labelBalance.text = [[dataBalanceArray[row] valueForKey:@"cardBalanceList"]stringValue];
//    [self.delegate labelBalanceChanges:_labelBalance.text];
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [dataArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [dataArray objectAtIndex:row] ;
}

-(void)doneClicked:(id) sender
{
    [textField resignFirstResponder];
    //hides the pickerView
    
    if (self->textField.text.length == 0) {
        self->textField.text = [dataArray objectAtIndex:0];
//        _labelBalance = [[UILabel alloc]init];
//        _labelBalance.text = [dataBalanceArray[0] valueForKey:@"cardBalanceList"];
//         
//        [self.delegate labelBalanceChanges:_labelBalance.text];
//       
    }
    [self.delegate indexRow:_indexRow];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (IBAction)showPicker:(id)sender
{
    pickerView = [[UIPickerView alloc] init];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    //If the text field is empty show the place holder otherwise show the last selected option
    if (self->textField.text.length == 0)
    {
      self->textField.placeholder = self->placeholderWhileSelecting;
    }
    else
    {
      [self->pickerView selectRow:[self->dataArray indexOfObject:self->textField.text] inComponent:0 animated:YES];
    }

    UIToolbar* toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = self->toolbarStyle;
    [toolbar sizeToFit];
    
    //to make the done button aligned to the right
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"完成"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(doneClicked:)];
    
    
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceLeft, doneButton, nil]];

    //custom input view
    textField.inputView = pickerView;
    textField.inputAccessoryView = toolbar;  
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField
{
//    if ([_orderIsPaid isEqual:@"部分付"])
//       return NO;
    if ([self->dataArray count] > 0) {
        [self showPicker:aTextField];
        return YES;
    }
    return NO;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

// Utility Methods
-(void) setData:(NSMutableArray*) data
{
    dataArray = data;
}

-(void) showArrowImage:(BOOL)b
{
    if (b == YES) {
      // set the DownPicker arrow to the right (you can replace it with any 32x24 px transparent image: changing size might give different results)
        self->textField.rightViewMode = UITextFieldViewModeAlways;
    }
    else {
        self->textField.rightViewMode = UITextFieldViewModeNever;
    }
}

-(void) setArrowImage:(UIImage*)image
{
    [(UIImageView*)self->textField.rightView setImage:image];
}

-(void) setPlaceholder:(NSString*)str
{
    self->placeholder = str;
    self->textField.placeholder = self->placeholder;
}

-(void) setPlaceholderWhileSelecting:(NSString*)str
{
    self->placeholderWhileSelecting = str;
}

-(void) setToolbarDoneButtonText:(NSString*)str
{
    self->toolbarDoneButtonText = str;
}

-(void) setToolbarStyle:(UIBarStyle)style;
{
    self->toolbarStyle = style;
}

-(UIPickerView*) getPickerView
{
    return self->pickerView;
}

-(UITextField*) getTextField
{
    return self->textField;
}

-(void) setValueAtIndex:(NSInteger)index
{
    [self pickerView:nil didSelectRow:index inComponent:0];
}


//Getter method for self.text
- (NSString*) text {
  
    return self->textField.text;
}

@end
