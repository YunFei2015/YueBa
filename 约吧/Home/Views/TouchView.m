//
//  TouchView.m
//  01-配配
//
//  Created by qing on 16/3/8.
//  Copyright © 2016年 qing. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        _imageView=[[UIImageView alloc] init];
        _imageView.frame=frame;
        [self addSubview:_imageView];
        self.backgroundColor=[UIColor blueColor];
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
