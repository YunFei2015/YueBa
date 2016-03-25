//
//  QYMessageCell.h
//  约吧
//
//  Created by 云菲 on 3/24/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVIMTypedMessage;
@class AVIMMessage;

typedef enum {
    kMessageTypeText,
    kMessageTypeVoice,
    kMessageTypePhoto,
    kMessageTypeLocation
}kMessageType;

typedef enum {
    kMessageCellTypeReceive,
    kMessageCellTypeSend
}kMessageCellType;

@interface QYMessageCell : UITableViewCell
{
    kMessageType _messageType;
    kMessageCellType _messageCellType;
    AVIMMessage *_message;
    AVIMTypedMessage *_typedMessage;
}

-(void)setMessageCellType:(kMessageCellType)messageCellType;
-(void)setMessage:(AVIMMessage *)message;
-(void)setTypedMessage:(AVIMTypedMessage *)typedMessage;

-(AVIMMessage *)message;
-(AVIMTypedMessage *)typedMessage;
-(kMessageType)messageType;

-(BOOL)isTapedInContent:(UITapGestureRecognizer *)tap;

@end


@interface QYTextMessageCell : QYMessageCell

@end

@interface QYVoiceMessageCell : QYMessageCell
-(void)startAnimating;
-(void)stopAnimating;
@end

@interface QYPhotoMessageCell : QYMessageCell

@end

@interface QYLocationMessageCell : QYMessageCell

@end