//
//  QYSubselectionController.h
//  约吧
//
//  Created by Shreker on 16/5/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYSelectModel;
typedef void (^QYSelectedSubModel)(QYSelectModel *model);
@interface QYSubselectionController : UITableViewController
@property (nonatomic, strong) NSArray *subSelectionItems;
@property (nonatomic, strong) QYSelectedSubModel selectedSubModel;
@end
