//
//  QYCreateTextViewController.h
//  约吧
//
//  Created by Shreker on 16/4/28.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileCommon.h"
@class QYSelectModel;


typedef void(^QYContentDidEndEdit)(QYSelectModel *model);

@interface QYCreateTextController : UIViewController

@property (nonatomic, assign) QYCreateTextType type;

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) QYContentDidEndEdit contentDidEndEdit;
@property (nonatomic, strong) NSString *textContent;
@end
