//
//  MessageTableViewCell.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVIMTypedMessage;

typedef enum {
    kMessageTypeText,
    kMessageTypeVoice,
    kMessageTypePhoto,
    kMessageTypeLocation
}kMessageType;

@interface QYMessageCell : UITableViewCell

@property (nonatomic) kMessageType messageType;
@property (strong, nonatomic) AVIMTypedMessage *message;
@property (weak, nonatomic) IBOutlet UIImageView *voiceAnimatingImageView;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;


//-(CGFloat)heightWithMessage:(AVIMTypedMessage *)message;

//判断手指是否触摸在有效区域
-(BOOL)isTapedInContent:(UITapGestureRecognizer *)tap;

//判断手指是否触摸在用户头像上
-(BOOL)isTapedInIcon:(UITapGestureRecognizer *)tap;

/**
 *  语音播放和停止
 */
-(void)startVoiceAnimating;
-(void)stopVoiceAnimating;

@end

@interface QYLeftMessageCell : QYMessageCell

@end

@interface QYRightMessageCell : QYMessageCell

@end
