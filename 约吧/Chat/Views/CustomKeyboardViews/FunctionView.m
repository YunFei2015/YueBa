//
//  FunctionView.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/8.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "FunctionView.h"

@implementation FunctionView

- (IBAction)takePhoto:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(toTakeAPhoto)]) {
        [self.delegate toTakeAPhoto];
    }
}

- (IBAction)selectImage:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(toSelectImages)]) {
        [self.delegate toSelectImages];
    }
    
}

- (IBAction)shareLocation:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(toShareLocation)]) {
        [self.delegate toShareLocation];
    }
}


@end
