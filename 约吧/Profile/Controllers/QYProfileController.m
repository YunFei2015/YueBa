//
//  QYProfileController.m
//  约吧
//
//  Created by Shreker on 16/4/26.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYProfileController.h"
#import "QYSelectionController.h"
#import "QYAccountInfoController.h"
#import "QYAccountInfoEntranceCell.h"
#import "QYNormalHeightCell.h"
#import "QYAutoHeightCell.h"
#import "QLProfileInfo.h"
#import "QYProfileSectionModel.h"

@interface QYProfileController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_arrProfileInfos;
}

@end

@implementation QYProfileController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    _arrProfileInfos = [[QLProfileInfo sharedProfileInfo] arrProfileInfos];
    
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - 🔌 Delegate Methods
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _arrProfileInfos.count + 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    QYProfileSectionModel *sectionModel = _arrProfileInfos[section - 1];
    return sectionModel.arrModels.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // 个人信息修改入口 cell
        QYAccountInfoEntranceCell *cell = [QYAccountInfoEntranceCell cellWithTableView:tableView];
        return cell;
    } else if (indexPath.section == 1 || indexPath.section == 2 ) { // NormalHeight cell
        QYNormalHeightCell *cell = [QYNormalHeightCell cellWithTableView:tableView];
        QYProfileSectionModel *sectionModel = _arrProfileInfos[indexPath.section - 1];
        cell.normalHeightModel = sectionModel.arrModels[indexPath.row];
        return cell;
    } else if (indexPath.section == 3 || indexPath.section == 4) {
        QYAutoHeightCell *cell = [QYAutoHeightCell cellWithTableView:tableView];
        QYProfileSectionModel *sectionModel = _arrProfileInfos[indexPath.section - 1];
        cell.autoHeightModel = sectionModel.arrModels[indexPath.row];
        return cell;
    } else {
        NSAssert(0 > 1, @"数据错误, 请检查");
        return nil;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    QYProfileSectionModel *sectionModel = _arrProfileInfos[section - 1];
    return sectionModel.strHeaderText;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    QYProfileSectionModel *sectionModel = _arrProfileInfos[section - 1];
    return sectionModel.strFooterText;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%s~%@", __FUNCTION__, indexPath);
    
    UIViewController *viewController = nil;
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            viewController = [self selectionViewControllerWithSelectionType:QYSelectionTypeOccupation];
        }
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Private
- (UIViewController *)selectionViewControllerWithSelectionType:(QYSelectionType)type {
    QYSelectionController *viewController = [QYSelectionController new];
    viewController.type = type;
    switch (type) {
        case QYSelectionTypeOccupation:
            viewController.title = @"职业";
            break;
        case QYSelectionTypeHometown:
            viewController.title = @"来自";
            break;
        case QYSelectionTypePersonality:
            viewController.title = @"我的个性标签";
            break;
        case QYSelectionTypeSports:
            viewController.title = @"我喜欢的运动";
            break;
        case QYSelectionTypeMusic:
            viewController.title = @"我喜欢的音乐";
            break;
        case QYSelectionTypeFood:
            viewController.title = @"我喜欢的食物";
            break;
        case QYSelectionTypeMovies:
            viewController.title = @"我喜欢的电影";
            break;
        case QYSelectionTypeLiterature:
            viewController.title = @"我喜欢的书和动漫";
            break;
        case QYSelectionTypePlaces:
            viewController.title = @"我的旅行足迹";
            break;
    }
    return viewController;
}

@end
