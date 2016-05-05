//
//  QYSelectionController.m
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYSelectionController.h"
#import "QLCategories.h"
#import "QYCreateTextController.h"
#import "QYSelectModel.h"
#import "QYSubselectionController.h"

@interface QYSelectionController ()
{
    /** 职业 */
    NSArray *_arrOcuupations;
    
    /** 来自 */
    NSArray *_arrHometowns;
    
    /** 我的个性标签 */
    NSArray *_arrPersonalities;
    
    /** 我喜欢的运动 */
    NSArray *_arrSports;
    
    /** 我喜欢的音乐 */
    NSArray *_arrMusics;
    
    /** 我喜欢的食物 */
    NSArray *_arrFoods;
    
    /** 我喜欢的电影 */
    NSArray *_arrMovies;
    
    /** 我喜欢的书和动漫 */
    NSArray *_arrLiteratures;
    
    /** 我的旅行足迹 */
    NSArray *_arrPlaces;
    
    /** 临时存储 */
    NSDictionary *_dicItems;
    
    /** 当前显示的 */
    NSArray *_arrItems;
}

@end

@implementation QYSelectionController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    QLCategories *categories =[QLCategories sharedCategories];
    
    switch (self.type) {
        case QYSelectionTypeOccupation:
            self.title = @"职业";
            _arrOcuupations = categories.arrOccupations;
            _arrItems = _arrOcuupations;
            break;
        case QYSelectionTypeHometown:
            self.title = @"来自";
            _arrHometowns = categories.arrHometowns;
            _arrItems = _arrHometowns;
            break;
        case QYSelectionTypePersonality:
            self.title = @"我的个性标签";
            _arrPersonalities = categories.arrPersonalities;
            _arrItems = _arrPersonalities;
            self.tableView.allowsMultipleSelection = YES;
            break;
        case QYSelectionTypeSports:
            self.title = @"我喜欢的运动";
            _arrSports = categories.arrSports;
            _arrItems = _arrSports;
            self.tableView.allowsMultipleSelection = YES;
            break;
        case QYSelectionTypeMusic:
            self.title = @"我喜欢的音乐";
            _arrMusics = categories.arrMusics;
            _arrItems = _arrMusics;
            self.tableView.allowsMultipleSelection = YES;
            break;
        case QYSelectionTypeFood:
            self.title = @"我喜欢的食物";
            _arrFoods = categories.arrFoods;
            _arrItems = _arrFoods;
            self.tableView.allowsMultipleSelection = YES;
            break;
        case QYSelectionTypeMovies:
            self.title = @"我喜欢的电影";
            _arrMovies = categories.arrMovies;
            _arrItems = _arrMovies;
            self.tableView.allowsMultipleSelection = YES;
            break;
        case QYSelectionTypeLiterature:
            self.title = @"我喜欢的书和动漫";
            _arrLiteratures = categories.arrLiteratures;
            _arrItems = _arrLiteratures;
            self.tableView.allowsMultipleSelection = YES;
            break;
        case QYSelectionTypePlaces:
            self.title = @"我的旅行足迹";
            _arrPlaces = categories.arrPlaces;
            _arrItems = _arrPlaces;
            self.tableView.allowsMultipleSelection = YES;
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - 🔌 Delegate Methods
#pragma mark UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrItems.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *strId = @"cellStyleAddTag";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strId];
            cell.imageView.contentMode = UIViewContentModeCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        cell.textLabel.text = @"创建我自己的标签";
        cell.imageView.image = [UIImage imageNamed:@""];
        
        return cell;
    } else {
        static NSString *strId = @"cellStyleNormal";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strId];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        
        QYSelectModel *model = _arrItems[indexPath.row - 1];
        cell.textLabel.text = model.strText;
        if (model.arrSubitems.count > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        QYCreateTextController *vcCreateTag = [QYCreateTextController new];
        [self.navigationController pushViewController:vcCreateTag animated:YES];
    } else {
        QYSelectModel *model = _arrItems[indexPath.row - 1];
        if (model.arrSubitems.count > 0) { // 有子项目
            QYSubselectionController *vcSubselection = [QYSubselectionController new];
            [self.navigationController pushViewController:vcSubselection animated:YES];
        } else { // 无子项目
            if (tableView.allowsMultipleSelection) {
                NSLog(@"%@", tableView.indexPathsForSelectedRows);
            } else {
                [self.delegate selectionController:self didSelectSelectModel:model indexPath:self.indexPath];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

@end
