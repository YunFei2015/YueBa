//
//  UIView+Extension.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/3.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)


-(void)updateOriginX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

-(void)updateOriginY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(void)updateSizeWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(void)updateSizeHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

-(void)maskLayerToView:(UIView *)view withFrame:(CGRect)frame{
    CALayer *layer = view.layer;
    layer.frame = frame;
    self.layer.mask = layer;
    [self setNeedsDisplay];
}
@end
