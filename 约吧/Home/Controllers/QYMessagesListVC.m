//
//  QYMessagesListVC.m
//  约吧
//
//  Created by 云菲 on 4/6/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYMessagesListVC.h"
#import "UIView+Extension.h"

@interface QYMessagesListVC () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation QYMessagesListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(100, 0, 165, 33)];
//    self.navigationItem.titleView = titleView;
//    CGPoint point = [self.navigationController.navigationBar convertPoint:titleView.frame.origin fromView:titleView];
//    CGFloat x = kScreenW * 0.6 - 50 - 113;
//    CGFloat height = titleView.bounds.size.height;
//    UILabel *countLab = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, 100, height)];
//    countLab.text = @"43个配对";
//    countLab.textColor = [UIColor whiteColor];
//    [titleView addSubview:countLab];
    
}

#pragma mark - UITableView Delegate & Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCellIdentifier forIndexPath:indexPath];
    
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
