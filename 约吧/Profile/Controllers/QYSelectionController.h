//
//  QYSelectionController.h
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileCommon.h"
@class QYSelectionController, QYSelectModel;

@protocol QYSelectionControllerDelegate <NSObject>

- (void)selectionController:(QYSelectionController *)selectionController didSelectSelectStrings:(NSArray *)selectStrings;

@end

@interface QYSelectionController : UITableViewController

@property (nonatomic, strong) NSString *selectedString;     //已经选中的描述

@property (nonatomic, assign) QYSelectionType type;
@property (nonatomic, assign) QYCreateTextType createTextType;
@property (nonatomic, weak) id<QYSelectionControllerDelegate> delegate;

@end
