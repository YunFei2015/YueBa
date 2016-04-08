//
//  QYVerifyCodeBtn.m
//  约吧
//
//  Created by 云菲 on 4/7/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYVerifyCodeBtn.h"

@implementation QYVerifyCodeBtn

-(void)setCodeState:(kVerifyCodeState)codeState{
    _codeState = codeState;
    
    switch (codeState) {
        case kVerifyCodeStateInactive:
            [self becomeInactiveState];
            break;
        case kVerifyCodeStateActive:
            [self becomeActiveState];
            break;
        case kVerifyCodeStateSent:
            [self becomeSentState];
            break;
        case kVerifyCodeStateReGet:
            [self becomeReGetState];
            break;
            
        default:
            break;
    }
}

-(void)becomeInactiveState{
    [self setEnabled:NO];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self setTitle:@"获取验证码" forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.backgroundColor = [UIColor clearColor];
}

-(void)becomeActiveState{
    [self setEnabled:YES];
    self.layer.borderWidth = 0;
    [self setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backgroundColor = kRGBColor(151, 220, 111, 1);
}

-(void)becomeSentState{
    [self setEnabled:NO];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    [self setTitle:@"验证码已发送" forState:UIControlStateDisabled];
    [self setTitle:@"60s" forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.backgroundColor = [UIColor clearColor];
}

-(void)becomeReGetState{
    [self setEnabled:YES];
    self.layer.borderWidth = 1;
    self.layer.borderColor = kRGBColor(151, 220, 111, 1).CGColor;
    [self setTitle:@"重新发送验证码" forState:UIControlStateNormal];
    [self setTitleColor:kRGBColor(151, 220, 111, 1) forState:UIControlStateNormal];
    self.backgroundColor = [UIColor clearColor];
}

@end
