//
//  AwaitView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/26.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AwaitView.h"
#import "DFUITableView.h"
@implementation AwaitView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor yellowColor];
        self.buttonView = [[UIView alloc] init];
        self.buttonView.backgroundColor = [UIColor orangeColor];

        self.backgroundColor = [UIColor redColor];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.buttonView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_buttonView];
        [self addSubview:_tableView];
/*
        NSDictionary *viewsDic = @{@"buttonView":self.buttonView, @"tableView":self.tableView};
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-44]];
        
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.buttonView.superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeHeight multiplier:0 constant:44]];
*/
//        NSArray *constraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tableView]-5-[buttonView]" options:0 metrics:nil views:viewsDic];

        NSDictionary *dic = NSDictionaryOfVariableBindings(_buttonView, _tableView);
        NSArray *constraint1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView][_buttonView]-0-|" options:0 metrics:nil views:dic];
        NSArray *constraint2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:dic];

        NSArray *constraint3 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_buttonView]-0-|" options:0 metrics:nil views:dic];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-44]];
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.buttonView.superview attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.buttonView attribute:NSLayoutAttributeHeight multiplier:0 constant:44]];
        
        
        [self addConstraints:constraint1];
        [self addConstraints:constraint2];
        [self addConstraints:constraint3];

//        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:0 constant:0.0]];

        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
