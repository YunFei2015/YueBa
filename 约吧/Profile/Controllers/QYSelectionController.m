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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
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
    
    [self chagngeDatas:_selectedStrings];
    
    [self.tableView reloadData];
}

//更改数据源（_arrItems）
-(void)chagngeDatas:(NSArray *)strings{
    if (strings.count == 0) {
        return;
    }
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:_arrItems];
    //过滤_selectedStrings包含的model.strText
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.strText IN %@",strings];
    NSArray *filterArray = [mutableArray filteredArrayUsingPredicate:predicate];
    [mutableArray removeObjectsInArray:filterArray];
    
    for (NSString *str in strings) {
        QYSelectModel *model = [QYSelectModel new];
        model.strText = str;
        model.selected = YES;
        [mutableArray insertObject:model atIndex:0];
    }
    _arrItems = mutableArray;
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = @"创建我自己的标签";
        cell.imageView.image = [UIImage imageNamed:@""];
        
        return cell;
    } else {
        static NSString *strId = @"cellStyleNormal";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        QYSelectModel *model = _arrItems[indexPath.row - 1];
        cell.textLabel.text = model.strText;
        cell.textLabel.font = model.selected ? [UIFont boldSystemFontOfSize:15.0] : [UIFont systemFontOfSize:15.0];
        //判断当有子选项的时候，UITableViewCellAccessoryDisclosureIndicator；没有子选项的时候，并且model.strText和self.selectedString相同的时候UITableViewCellAccessoryCheckmark；否则UITableViewCellAccessoryNone
        cell.accessoryType = model.arrSubitems.count > 0 ? UITableViewCellAccessoryDisclosureIndicator : model.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak QYSelectionController *weakSelf = self;
    if (indexPath.row == 0) {
        QYCreateTextController *vcCreateTag = [QYCreateTextController new];
        vcCreateTag.type = _createTextType;
        vcCreateTag.contentDidEndEdit = ^(QYSelectModel *model){
            if (weakSelf.createTextType == QYCreateTextTypeOccupation || weakSelf.createTextType == QYCreateTextTypeHometown) {
                if ([weakSelf.delegate respondsToSelector:@selector(selectionController:didSelectSelectStrings:)]) {
                    [weakSelf.delegate selectionController:self didSelectSelectStrings:@[model.strText]];
                }
            }else{
                //当profile界面选中的单元格内容存在时，判断是否需要在_arrItems插入
                if (model.strText.length > 0) {
                    
                    [weakSelf chagngeDatas:@[model.strText]];
                    
                    [weakSelf.tableView reloadData];
                }
            }
        };
        [self.navigationController pushViewController:vcCreateTag animated:YES];
    } else {
        QYSelectModel *model = _arrItems[indexPath.row - 1];
        if (model.arrSubitems.count > 0) { // 有子项目
            QYSubselectionController *vcSubselection = [QYSubselectionController new];
            vcSubselection.subSelectionItems = model.arrSubitems;
            vcSubselection.selectedSubModel = ^(QYSelectModel *model){
                if ([weakSelf.delegate respondsToSelector:@selector(selectionController:didSelectSelectStrings:)]) {
                    [weakSelf.delegate selectionController:self didSelectSelectStrings:@[model.strText]];
                }
            };
            [self.navigationController pushViewController:vcSubselection animated:YES];
        } else { // 无子项目
            if (tableView.allowsMultipleSelection) {
//                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                model.selected = YES;
//                cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
                [self setAppearanceForCell:indexPath];
            } else {
                if ([self.delegate respondsToSelector:@selector(selectionController:didSelectSelectStrings:)]) {
                    [self.delegate selectionController:self didSelectSelectStrings:@[model.strText]];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0) {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        QYSelectModel *model = _arrItems[indexPath.row - 1];
//        model.selected = NO;
//        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        [self setAppearanceForCell:indexPath];
    }
}

-(void)setAppearanceForCell:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    QYSelectModel *model = _arrItems[indexPath.row - 1];
    model.selected = !model.selected;
    cell.accessoryType = model.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.font = model.selected ? [UIFont boldSystemFontOfSize:15.0] : [UIFont systemFontOfSize:15.0];
}

-(void)back:(UIBarButtonItem *)item{
    if (self.tableView.allowsMultipleSelection) {
        NSMutableArray *didSelectedStrings = [NSMutableArray array];
        
        [_arrItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[QYSelectModel class]]) {
                QYSelectModel *selectModel = (QYSelectModel *)obj;
                if (selectModel.selected) {
                    [didSelectedStrings addObject:selectModel.strText];
                }
            }
        }];
        
        if ([self.delegate respondsToSelector:@selector(selectionController:didSelectSelectStrings:)]) {
            [self.delegate selectionController:self didSelectSelectStrings:didSelectedStrings];
        }
 
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
