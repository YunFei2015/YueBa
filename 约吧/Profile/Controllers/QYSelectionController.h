//
//  QYSelectionController.h
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYProfileCellModel;

@interface QYSelectionController : UITableViewController

@property (nonatomic, strong) QYProfileCellModel *selectionCellModel;
@property (nonatomic, copy) void (^backPreviousVC)(QYProfileCellModel *model);
@end
