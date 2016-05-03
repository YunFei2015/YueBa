//
//  QYAccountInfoEntranceCell.m
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYAccountInfoEntranceCell.h"

@implementation QYAccountInfoEntranceCell

/** 返回循环利用的cell */
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *strId = @"QYAccountInfoEntranceCell";
    QYAccountInfoEntranceCell *cell = [tableView dequeueReusableCellWithIdentifier:strId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QYAccountInfoEntranceCell" owner:nil options:nil] firstObject];
    }
    return cell;
}

@end
