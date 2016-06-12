//
//  QYCreateTextViewController.h
//  约吧
//
//  Created by Shreker on 16/4/28.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYSelectModel;

typedef void(^QYContentDidEndEdit)(QYSelectModel *model);

@interface QYCreateTextController : UIViewController
@property (nonatomic, strong) QYContentDidEndEdit contentDidEndEdit;
@property (nonatomic, strong) NSString *textContent;

//当back的时候是否pop至个人信息编辑界面
@property (nonatomic)         BOOL isPopToEditProfileInfoVCWhenBack;
@end
