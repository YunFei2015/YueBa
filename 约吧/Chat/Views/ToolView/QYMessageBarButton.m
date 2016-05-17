//
//  QYMessageBarButton.m
//  约吧
//
//  Created by 云菲 on 16/5/16.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYMessageBarButton.h"

@implementation QYMessageBarButton
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //每个按钮的tag值在storyboard中设置好，作为其初始showType
        self.showType = self.tag;
    }
    return self;
}

-(void)setShowType:(kMessageBarButtonType)showType{
    _showType = showType;
    
    [self setTitle:nil forState:UIControlStateNormal];
    switch (showType) {
        case kMessageBarButtonTypeAdd:
            [self setImage:[UIImage imageNamed:@"messageBar_Add"] forState:UIControlStateNormal];
            break;
            
        case kMessageBarButtonTypeFace:
            [self setImage:[UIImage imageNamed:@"messageBar_Smiley"] forState:UIControlStateNormal];
            break;
            
        case kMessageBarButtonTypeSend:
        {
            [self setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
            [self setTitle:@"发送" forState:UIControlStateNormal];
        }
            break;
            
        case kMessageBarButtonTypeVoice:
            [self setImage:[UIImage imageNamed:@"messageBar_Microphone"] forState:UIControlStateNormal];
            break;
            
        case kMessageBarButtonTypeKeyboard:
            [self setImage:[UIImage imageNamed:@"messageBar_Keyboard"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}


@end
