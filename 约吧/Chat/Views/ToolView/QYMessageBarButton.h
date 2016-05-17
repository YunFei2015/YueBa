//
//  QYMessageBarButton.h
//  约吧
//
//  Created by 云菲 on 16/5/16.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>

//按钮外观
typedef NS_ENUM(NSInteger, kMessageBarButtonType) {
    kMessageBarButtonTypeAdd=1,//添加
    kMessageBarButtonTypeFace,//表情
    kMessageBarButtonTypeVoice,//语音
    kMessageBarButtonTypeSend,//发送
    kMessageBarButtonTypeKeyboard //键盘
};

@interface QYMessageBarButton : UIButton

@property (nonatomic) kMessageBarButtonType showType;

@end
