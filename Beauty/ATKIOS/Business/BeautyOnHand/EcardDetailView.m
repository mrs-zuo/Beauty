//
//  EcardDetailView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-28.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "EcardDetailView.h"

@implementation EcardDetailView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    
    return self;
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 39.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ecard = @"ECARD";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ecard];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ecard];
    }
    cell.textLabel.text = @"ceshiceshi";
    cell.detailTextLabel.text = @"awfeoj";
    
    return cell;

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
