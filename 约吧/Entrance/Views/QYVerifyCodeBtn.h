//
//  QYVerifyCodeBtn.h
//  约吧
//
//  Created by 云菲 on 4/7/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    kVerifyCodeStateInactive=0,
    kVerifyCodeStateActive,
    kVerifyCodeStateSent,
    kVerifyCodeStateReGet
}kVerifyCodeState;

@interface QYVerifyCodeBtn : UIButton
@property (nonatomic) kVerifyCodeState codeState;

@end
