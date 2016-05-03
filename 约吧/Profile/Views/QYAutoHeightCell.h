//
//  QYAutoHeightCell.h
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//  行高随选择内容变化的 cell

#import <UIKit/UIKit.h>
#import "QYAutoHeightModel.h"

@interface QYAutoHeightCell : UITableViewCell

@property (nonatomic, strong) QYAutoHeightModel *autoHeightModel;

/** 返回循环利用的cell */
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
