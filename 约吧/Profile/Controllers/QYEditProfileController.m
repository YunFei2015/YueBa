//
//  QYProfileController.m
//  约吧
//
//  Created by Shreker on 16/4/26.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYEditProfileController.h"
#import "QYSelectionController.h"
#import "QYAccountInfoController.h"
#import "QYAccountInfoEntranceCell.h"
#import "QLProfileInfo.h"
#import "QYProfileSectionModel.h"
#import "QYCreateTextController.h"
#import "ProfileCommon.h"
#import "QYSelectModel.h"
#import "QYPhotoWall.h"
#import "QYSingleSelectionCell.h"
#import "QYMultipleSelectionCell.h"
@interface QYEditProfileController () <UITableViewDataSource, UITableViewDelegate>
{
    
    QLProfileInfo *_profileInfo;
}
@property (nonatomic, strong) QYPhotoWall *wall;
@end

@implementation QYEditProfileController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    _profileInfo = [QLProfileInfo profileInfo];
    
    self.tableView.estimatedRowHeight = 80;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableHeaderView = self.wall;
}

-(QYPhotoWall *)wall{
    if (_wall == nil) {
        _wall = [QYPhotoWall photoWallWithPhotos:self.wallPhotos];
    }
    return _wall;
}

#pragma mark - 🔌 Delegate Methods
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _profileInfo.arrProfileInfos.count + 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    QYProfileSectionModel *sectionModel = _profileInfo.arrProfileInfos[section - 1];
    return sectionModel.celldatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { //个人信息修改入口
        QYAccountInfoEntranceCell *cell = [QYAccountInfoEntranceCell cellWithTableView:tableView];
        return cell;
    } else if (indexPath.section == 1 || indexPath.section == 2 ) {//我的信息、我的社交账号
        QYSingleSelectionCell *cell = [QYSingleSelectionCell singleSelectionCellForTableView:tableView forIndexPath:indexPath];
        QYProfileSectionModel *sectionModel = _profileInfo.arrProfileInfos[indexPath.section - 1];
        cell.cellModel = sectionModel.celldatas[indexPath.row];
        return cell;
    } else if (indexPath.section == 3 || indexPath.section == 4) {//我的标签、我的兴趣
        QYMultipleSelectionCell *cell = [QYMultipleSelectionCell multipleSelectionCellForTableView:tableView forIndexPath:indexPath];
        QYProfileSectionModel *sectionModel = _profileInfo.arrProfileInfos[indexPath.section - 1];
        cell.cellModel = sectionModel.celldatas[indexPath.row];
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
    QYProfileSectionModel *sectionModel = _profileInfo.arrProfileInfos[section - 1];
    return sectionModel.sectionheader;
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    //NSLog(@"%@",self.wall.imagesOfWall);
    UIViewController *viewController = nil;
    
    if (indexPath.section == 0) {
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"accountInfo"];
        
    }else{
        QYBaseSelectionCell *selectionCell = [tableView cellForRowAtIndexPath:indexPath];
        __weak QYEditProfileController *weakSelf = self;
        if (selectionCell.cellModel.type == MyProfileCellWillPresentedTypeSelection) {
            viewController = [QYSelectionController new];
            [viewController setValue:selectionCell.cellModel forKey:@"selectionCellModel"];
            void (^changeDidSelectedModel)(QYProfileCellModel *model) = ^(QYProfileCellModel *model){
                [weakSelf changeDidSelectedContent:model];
            };
            [viewController setValue:changeDidSelectedModel forKey:@"backPreviousVC"];
        }else if (selectionCell.cellModel.type == MyProfileCellWillPresentedTypeInput){
            viewController = [QYCreateTextController new];
            
            viewController.title = selectionCell.cellModel.title;
            [viewController setValue:selectionCell.cellModel.content forKey:@"textContent"];
            void (^changeDidSelectedModel)(QYSelectModel *model) = ^(QYSelectModel *model){
                [weakSelf contentDidEndEdit:model];
            };
            [viewController setValue:changeDidSelectedModel forKey:@"contentDidEndEdit"];
        }
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
//处理QYSelectionController回调
-(void)changeDidSelectedContent:(QYProfileCellModel *)cellModel{
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    QYProfileSectionModel *sectionModel = _profileInfo.arrProfileInfos[selectedIndexPath.section - 1];
    [sectionModel.celldatas replaceObjectAtIndex:selectedIndexPath.row withObject:cellModel];
    [self.tableView reloadData];
}

//处理QYCreateTextController回调
-(void)contentDidEndEdit:(QYSelectModel *)model{
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    QYProfileSectionModel *sectionModel = _profileInfo.arrProfileInfos[selectedIndexPath.section - 1];
    QYProfileCellModel *cellModel = (QYProfileCellModel *)sectionModel.celldatas[selectedIndexPath.row];
    cellModel.content = model.strText;
    [self.tableView reloadData];
}


- (IBAction)done:(UIBarButtonItem *)sender {
    [NSKeyedArchiver archiveRootObject:_profileInfo toFile:kProfilePath];
    //进行网络请求保存编辑后的个人信息
    NSMutableDictionary *uploadDict = [NSMutableDictionary dictionary];
    for (QYProfileSectionModel *model in _profileInfo.arrProfileInfos) {
        [model.celldatas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[QYProfileCellModel class]]) {
                QYProfileCellModel *cellModel = (QYProfileCellModel *)obj;
                if (cellModel.content.length > 0) {
                    [uploadDict setObject:cellModel.content forKey:cellModel.key];
                }
            }
        }];
    }
    
    if (_didEditProfile) {
        _didEditProfile(_wall.imagesOfWall);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
