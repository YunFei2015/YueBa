//
//  QYProfileController.m
//  约吧
//
//  Created by 青云-wjl on 16/5/15.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYProfileController.h"
#import "QLProfileInfo.h"
#import "QYProfileSectionModel.h"
#import "QYAccountInfoEntranceCell.h"
#import "QYSingleSelectionCell.h"
#import "QYMultipleSelectionCell.h"
#import "QYScrollPhotoView.h"
@interface QYProfileController ()
{
    QLProfileInfo *_profileInfo;
    NSArray *_images;
    CGRect _bgViewFrame;
    UIImageView *_currentDisplayPhoto;
}
@end

@implementation QYProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    _profileInfo = [QLProfileInfo profileInfoExceptEmpty];
    
    self.tableView.estimatedRowHeight = 80;
}

#pragma mark - Table view data source

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
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    } else{
        QYProfileSectionModel *sectionModel = _profileInfo.arrProfileInfos[indexPath.section - 1];
        
        if([sectionModel.sectionheader isEqualToString:@"我的信息"] || [sectionModel.sectionheader isEqualToString:@"我的社交账号"]){
            QYSingleSelectionCell *cell = [QYSingleSelectionCell singleSelectionCellForTableView:tableView forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.cellModel = sectionModel.celldatas[indexPath.row];
            return cell;
        }else if ([sectionModel.sectionheader isEqualToString:@"我的标签"] || [sectionModel.sectionheader isEqualToString:@"我的兴趣"]) {
            QYMultipleSelectionCell *cell = [QYMultipleSelectionCell multipleSelectionCellForTableView:tableView forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.cellModel = sectionModel.celldatas[indexPath.row];
            return cell;
        }else {
            NSAssert(0 > 1, @"数据错误, 请检查");
            return nil;
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    QYProfileSectionModel *sectionModel = _profileInfo.arrProfileInfos[section - 1];
    return sectionModel.sectionheader;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationVC = segue.destinationViewController;
    __weak QYProfileController *weakProfileVC = self;
    void (^didBackFromEditProfile)(NSArray *photos) = ^(NSArray *photos){
        [weakProfileVC updateUI:photos];
    };
    [destinationVC setValue:didBackFromEditProfile forKey:@"didEditProfile"];
    [destinationVC setValue:_images forKey:@"wallPhotos"];
}

//从编辑个人信息界面返回后更新界面
-(void)updateUI:(NSArray *)images{
    _profileInfo = [QLProfileInfo profileInfoExceptEmpty];
    [self.tableView reloadData];
    
    _images = images;
    QYScrollPhotoView *scrollPhotoView = [QYScrollPhotoView scrollPhotoViewWithImages:images];
    self.tableView.tableHeaderView = scrollPhotoView;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kScreenW, 0, 0, 0);
    
}

@end
