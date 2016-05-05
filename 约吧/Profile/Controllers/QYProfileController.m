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
#import "QYCreateTextController.h"

@interface QYProfileController () <UITableViewDataSource, UITableViewDelegate, QYSelectionControllerDelegate>
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
        switch (indexPath.row) {
            case 0:
                viewController = [self selectionViewControllerWithSelectionType:QYSelectionTypeOccupation indexPath: indexPath];
                break;
            case 1:
                viewController = [self selectionViewControllerWithSelectionType:QYSelectionTypeHometown indexPath: indexPath];
                break;
            case 2:
                viewController = [self createTextViewControllerWithType:QYCreateTextTypeHaunt];
                break;
            case 3:
                viewController = [self createTextViewControllerWithType:QYCreateTextTypeSignature];
                break;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            viewController = [self createTextViewControllerWithType:QYCreateTextTypeWeChat];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            viewController = [self selectionViewControllerWithSelectionType:QYSelectionTypePersonality indexPath: indexPath];
        }
    } else if (indexPath.section == 4) {
        QYSelectionType type;
        switch (indexPath.row) {
            case 0:
                type = QYSelectionTypeSports;
                break;
            case 1:
                type = QYSelectionTypeMusic;
                break;
            case 2:
                type = QYSelectionTypeFood;
                break;
            case 3:
                type = QYSelectionTypeMovies;
                break;
            case 4:
                type = QYSelectionTypeLiterature;
                break;
            case 5:
                type = QYSelectionTypePlaces;
                break;
            default:
                break;
        }
        viewController = [self selectionViewControllerWithSelectionType:type indexPath: indexPath];
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
#pragma mark QYSelectionControllerDelegate
- (void)selectionController:(QYSelectionController *)selectionController didSelectSelectModel:(QYSelectModel *)selectModel indexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", selectModel.strText);
    QYProfileSectionModel *sectionModel = _arrProfileInfos[indexPath.section - 1];
    if (indexPath.section == 1) { // NormalHeight cell
        QYNormalHeightModel *normalHeightModel = sectionModel.arrModels[indexPath.row];
        normalHeightModel.strContent = selectModel.strText;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    } else if (indexPath.section == 3 || indexPath.section == 4) {
        //QYAutoHeightModel *autoHeightModel = sectionModel.arrModels[indexPath.row];
        
    }
}

#pragma mark - Private
- (UIViewController *)selectionViewControllerWithSelectionType:(QYSelectionType)type indexPath:(NSIndexPath *)indexPath {
    QYSelectionController *viewController = [QYSelectionController new];
    viewController.type = type;
    viewController.delegate = self;
    viewController.indexPath = indexPath;
    return viewController;
}

- (QYCreateTextController *)createTextViewControllerWithType:(QYCreateTextType)type {
    QYCreateTextController *vcCreateText = [QYCreateTextController new];
    vcCreateText.type = type;
    return vcCreateText;
}

@end
