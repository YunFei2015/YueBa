//
//  QYMultipleSelectionCell.h
//  约吧
//
//  Created by 青云-wjl on 16/6/7.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseSelectionCell.h"
@interface QYMultipleSelectionCell : QYBaseSelectionCell
+(instancetype)multipleSelectionCellForTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath;
@end
