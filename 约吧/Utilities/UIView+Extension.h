//
//  UIView+Extension.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/3.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
/**
 *  修改view的frame参数
 */
- (void)updateOriginX:(CGFloat)x;
- (void)updateOriginY:(CGFloat)y;
- (void)updateSizeWidth:(CGFloat)width;
- (void)updateSizeHeight:(CGFloat)height;

/**
 *  裁剪视图图层
 *
 *  @param view  需要的图层样式
 *  @param frame 要裁剪的图层位置和大小
 */
-(void)maskLayerToView:(UIView *)view withFrame:(CGRect)frame;
@end
