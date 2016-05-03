//
//  QYSelectionController.m
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYSelectionController.h"
#import "QLCategories.h"
#import "QYCreateTagViewController.h"

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
    NSLog(@"%@", categories.arrOccupations);
    
    switch (self.type) {
        case QYSelectionTypeOccupation:
            _arrOcuupations = categories.arrOccupations;
            _arrItems = _arrOcuupations;
            break;
        case QYSelectionTypeHometown:
            _arrHometowns = categories.arrHometowns;
            _arrItems = _arrHometowns;
            break;
        case QYSelectionTypePersonality:
            _arrPersonalities = categories.arrPersonalities;
            _arrItems = _arrPersonalities;
            break;
        case QYSelectionTypeSports:
            _arrSports = categories.arrSports;
            _arrItems = _arrSports;
            break;
        case QYSelectionTypeMusic:
            _arrMusics = categories.arrMusics;
            _arrItems = _arrMusics;
            break;
        case QYSelectionTypeFood:
            _arrFoods = categories.arrFoods;
            _arrItems = _arrFoods;
            break;
        case QYSelectionTypeMovies:
            _arrMovies = categories.arrMovies;
            _arrItems = _arrMovies;
            break;
        case QYSelectionTypeLiterature:
            _arrLiteratures = categories.arrLiteratures;
            _arrItems = _arrLiteratures;
            break;
        case QYSelectionTypePlaces:
            _arrPlaces = categories.arrPlaces;
            _arrItems = _arrPlaces;
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
        cell.textLabel.text = _arrItems[indexPath.row - 1];
        
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        QYCreateTagViewController *vcCreateTag = [QYCreateTagViewController new];
        [self.navigationController pushViewController:vcCreateTag animated:YES];
    } else {
        
    }
}

@end
