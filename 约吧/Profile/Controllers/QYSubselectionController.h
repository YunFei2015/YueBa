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
//可供选择的数据
@property (nonatomic, strong) NSArray *subSelectionItems;
//当back的时候是否pop至个人信息编辑界面
@property (nonatomic)         BOOL isPopToEditProfileInfoVCWhenBack;
//选中后回调
@property (nonatomic, copy) QYSelectedSubModel selectedSubModel;
@end
