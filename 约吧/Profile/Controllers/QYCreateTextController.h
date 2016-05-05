//
//  QYCreateTextViewController.h
//  约吧
//
//  Created by Shreker on 16/4/28.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QYCreateTextType) {
    /** 经常出没 */
    QYCreateTextTypeHaunt,
    
    /** 个人签名 */
    QYCreateTextTypeSignature,
    
    /** 我的微信 */
    QYCreateTextTypeWeChat
};

@interface QYCreateTextController : UIViewController

@property (nonatomic, assign) QYCreateTextType type;

@end
