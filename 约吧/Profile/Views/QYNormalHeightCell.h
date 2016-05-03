//
//  QYNormalHeightCell.h
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//  正常高度的 cell

#import <UIKit/UIKit.h>
#import "QYNormalHeightModel.h"

@interface QYNormalHeightCell : UITableViewCell

@property (nonatomic, strong) QYNormalHeightModel *normalHeightModel;

/** 返回循环利用的cell */
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
