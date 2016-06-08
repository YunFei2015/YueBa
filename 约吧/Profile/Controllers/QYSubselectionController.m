//
//  QYSubselectionController.m
//  约吧
//
//  Created by Shreker on 16/5/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYSubselectionController.h"
#import "QYSelectModel.h"
@interface QYSubselectionController ()

@end

@implementation QYSubselectionController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    
}

#pragma mark - 🔌 Delegate Methods
#pragma mark UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subSelectionItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *strId = @"cellStyle1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strId];
    }
    cell.textLabel.text = ((QYSelectModel *)self.subSelectionItems[indexPath.row]).strText;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%s~%@", __FUNCTION__, indexPath);
    if (_selectedSubModel) {
        _selectedSubModel((QYSelectModel *)self.subSelectionItems[indexPath.row]);
        if (_isPopToEditProfileInfoVCWhenBack) {
            UIViewController *popToVC = self.navigationController.viewControllers[1];
            [self.navigationController popToViewController:popToVC animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

@end
