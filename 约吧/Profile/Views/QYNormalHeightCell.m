//
//  QYNormalHeightCell.m
//  约吧
//
//  Created by Shreker on 16/4/29.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYNormalHeightCell.h"

@implementation QYNormalHeightCell
{
    __weak IBOutlet UILabel *_lblTitle;
    __weak IBOutlet UILabel *_lblContent;
}

/** 返回循环利用的cell */
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *strId = @"QYNormalHeightCell";
    QYNormalHeightCell *cell = [tableView dequeueReusableCellWithIdentifier:strId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QYNormalHeightCell" owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)setNormalHeightModel:(QYNormalHeightModel *)normalHeightModel {
    _normalHeightModel = normalHeightModel;
    
    _lblTitle.text = _normalHeightModel.strTitle;
    if ([normalHeightModel.strContent isEqualToString:@""]) { // 用户暂未选择
        _lblContent.text = _normalHeightModel.strPlaceholder;
        _lblContent.textColor = [UIColor lightGrayColor];
    } else { // 用户已经有选择的内容
        _lblContent.text = _normalHeightModel.strContent;
        _lblContent.textColor = [UIColor darkGrayColor];
    }
}

@end
