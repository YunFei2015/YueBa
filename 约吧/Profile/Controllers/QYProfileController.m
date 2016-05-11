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
#import "ProfileCommon.h"
#import "QYSelectModel.h"
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
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    //NSLog(@"%s~%@", __FUNCTION__, indexPath);
    
    UIViewController *viewController = nil;
    if (indexPath.section == 1) {
        QYNormalHeightCell *normalCell = [tableView cellForRowAtIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                viewController = [self selectionViewControllerWithSelectionType:QYSelectionTypeOccupation selectedString:normalCell.normalHeightModel.strContent createTextType:QYCreateTextTypeOccupation];
                break;
            case 1:
                viewController = [self selectionViewControllerWithSelectionType:QYSelectionTypeHometown selectedString:normalCell.normalHeightModel.strContent createTextType:QYCreateTextTypeHometown];
                break;
            case 2:
                viewController = [self createTextViewControllerWithType:QYCreateTextTypeHaunt textContent:normalCell.normalHeightModel.strContent];
                break;
            case 3:
                viewController = [self createTextViewControllerWithType:QYCreateTextTypeSignature textContent:normalCell.normalHeightModel.strContent];
                break;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            QYNormalHeightCell *normalCell = [tableView cellForRowAtIndexPath:indexPath];
            viewController = [self createTextViewControllerWithType:QYCreateTextTypeWeChat textContent:normalCell.normalHeightModel.strContent];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            viewController = [self selectionViewControllerWithSelectionType:QYSelectionTypePersonality selectedString:nil createTextType:QYCreateTextTypeNone];
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
        viewController = [self selectionViewControllerWithSelectionType:type selectedString:nil createTextType:QYCreateTextTypeNone];
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
#pragma mark QYSelectionControllerDelegate
- (void)selectionController:(QYSelectionController *)selectionController didSelectSelectStrings:(NSArray *)selectStrings{
    NSLog(@"%@", selectStrings);
    NSIndexPath *selectedIndex = self.tableView.indexPathForSelectedRow;
    QYProfileSectionModel *sectionModel = _arrProfileInfos[selectedIndex.section - 1];
    if (selectedIndex.section == 1 || selectedIndex.section == 2) { // NormalHeight cell
        QYNormalHeightModel *normalHeightModel = sectionModel.arrModels[selectedIndex.row];
        normalHeightModel.strContent = selectStrings[0];
        
    } else if (selectedIndex.section == 3 || selectedIndex.section == 4) {
        QYAutoHeightModel *autoHeightModel = sectionModel.arrModels[selectedIndex.row];
        autoHeightModel.arrTags = selectStrings;
        
    }
    [self.tableView reloadRowsAtIndexPaths:@[selectedIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Private
- (UIViewController *)selectionViewControllerWithSelectionType:(QYSelectionType)type selectedString:(NSString *)string createTextType:(QYCreateTextType)textType{
    QYSelectionController *viewController = [QYSelectionController new];
    viewController.type = type;
    viewController.createTextType = textType;
    viewController.delegate = self;
    viewController.selectedString = string;
    return viewController;
}

- (QYCreateTextController *)createTextViewControllerWithType:(QYCreateTextType)type textContent:(NSString *)content{
    QYCreateTextController *vcCreateText = [QYCreateTextController new];
    vcCreateText.type = type;
    vcCreateText.textContent = content;
    
    __weak QYProfileController *weakSelf = self;
    vcCreateText.contentDidEndEdit = ^(QYSelectModel *model){
        [weakSelf selectionController:nil didSelectSelectStrings:@[model.strText]];
    };
    return vcCreateText;
}

@end
