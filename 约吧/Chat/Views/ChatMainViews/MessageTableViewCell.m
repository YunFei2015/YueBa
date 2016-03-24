//
//  MessageTableViewCell.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "FaceModel.h"
#import "QYAudioPlayer.h"
#import "QYDataManager.h"
#import "QYNetworkManager.h"
#import <AVFile.h>
#import <AVIMAudioMessage.h>
#import <AVIMFileMessage.h>
#import <AVIMLocationMessage.h>
#import <AVIMImageMessage.h>
#import "NSString+Extension.h"
#import "UIImage+Extension.h"

#define kFaceTTW 36
#define kFaceTTH 36
#pragma mark - MessageTableViewCell
@interface MessageTableViewCell ()  <QYAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *messageLab;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTypeImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation MessageTableViewCell
@synthesize message = _message;
@synthesize typedMessage = _typedMessage;
- (void)awakeFromNib {
    // Initialization code
    
}

#pragma mark - setters
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setMessage:(AVIMMessage *)message{
    if (!message) {
        return;
    }
    [self resumeOriginalLayout];
    _message = message;
    _messageLab.attributedText = [self faceAttributeTextWithMessage:[message content]];
    [self calculateLayoutWith:_messageLab.attributedText];
}

-(void)setTypedMessage:(AVIMTypedMessage *)typedMessage{
    if (!typedMessage) {
        return;
    }

    [self resumeOriginalLayout];
    _typedMessage = typedMessage;
    switch (typedMessage.mediaType) {
        case kAVIMMessageMediaTypeAudio:{
            [self configAudioMessage];
            //存储语音文件
//            [[QYDataManager sharedInstance] saveVoiceFileWithMessageID:typedMessage.messageId];
        }
            break;
            
        case kAVIMMessageMediaTypeImage:
            [self configPhotoMessage];
            break;
            
        default:
            break;
    }
}

#pragma mark - custom methods
//当cell被复用时，要把之前的约束清空
-(void)resumeOriginalLayout{
    _messageTypeImageViewWidthConstraint.constant = 0;
    _photoImageView.hidden = YES;
    _messageLab.attributedText = [[NSAttributedString alloc] initWithString:@""];
}

-(NSAttributedString *)faceAttributeTextWithMessage:(NSString *)message{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Faces" ofType:@"plist"];
    NSArray *faces = [NSDictionary dictionaryWithContentsOfFile:path][kFaceTT];
    
    NSMutableAttributedString *messageAttriText = [[NSMutableAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
        [faces enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FaceModel *face = [FaceModel faceModelWithDictionary:obj];
        if ([message containsString:face.text]) {
            //创建富文本
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *image = [UIImage imageNamed:face.imgName];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, -8, image.size.width, image.size.height);
            NSAttributedString *attributeStr = [NSAttributedString attributedStringWithAttachment:attachment];
            
            //用富文本替换表情文本
            NSRange resultRange;
            NSRange searchRange = NSMakeRange(0, messageAttriText.length);
            while ((resultRange = [[messageAttriText string] rangeOfString:face.text options:0 range:searchRange]).location != NSNotFound) {
                [messageAttriText replaceCharactersInRange:resultRange withAttributedString:attributeStr];
                resultRange.length = 1;
                searchRange = NSMakeRange(NSMaxRange(resultRange), messageAttriText.length - NSMaxRange(resultRange));
            }
        }
    }];
    return messageAttriText;
}

-(void)calculateLayoutWith:(NSAttributedString *)text{
    //根据文本内容调整布局
    CGRect rect = [text boundingRectWithSize:CGSizeMake(kMessageMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _viewWidthConstraint.constant = ceilf(rect.size.width) + _messageTypeImageViewWidthConstraint.constant + 10 + 20;
}


-(void)configAudioMessage{
    AVIMAudioMessage *audioMessage = (AVIMAudioMessage *)_typedMessage;
#if 1
    //下载音频文件，若之前下载过，不会重复下载
    [audioMessage.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        NSLog(@"音频数据下载成功");
    }];
#endif
    if ([self isKindOfClass:[LeftMessageTableViewCell class]]) {
        NSString *text = [NSString stringWithFormat:@"          %.0f\''", audioMessage.duration];
        _messageLab.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
        _messageTypeImageView.animationImages = @[
                                                  [UIImage imageNamed:@"ReceiverVoiceNodePlaying000"],
                                                  [UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
                                                  [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
                                                  [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"]];
    }else if ([self isKindOfClass:[RightMessageTableViewCell class]]){
        NSString *text = [NSString stringWithFormat:@"%.0f\''          ", audioMessage.duration];
        _messageLab.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
        _messageTypeImageView.animationImages = @[
                                                  [UIImage imageNamed:@"SenderVoiceNodePlaying000"],
                                                  [UIImage imageNamed:@"SenderVoiceNodePlaying001"],
                                                  [UIImage imageNamed:@"SenderVoiceNodePlaying002"],
                                                  [UIImage imageNamed:@"SenderVoiceNodePlaying003"]];
    }else{
        NSLog(@"这不可能！！");
    }
    
    _messageTypeImageView.animationDuration = 1;
    _messageTypeImageView.animationRepeatCount = audioMessage.duration;
    _messageTypeImageViewWidthConstraint.constant = _messageTypeImageView.image.size.width;
    [self calculateLayoutWith:_messageLab.attributedText];
}

-(void)configPhotoMessage{
    AVIMImageMessage *message = (AVIMImageMessage *)_typedMessage;
    [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        
//        CGFloat top = image.size.height / 2;
//        CGFloat bottom = (int)image.size.height % 2 == 0 ? top : top + 1;
//        CGFloat left = image.size.width / 2;
//        CGFloat right = (int)image.size.width % 2 == 0 ? left : left + 1;
//        UIImage *photo = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
        CGFloat width = kScreenW / 2.f;
        CGFloat height = kScreenH / 3.f;
        
//        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//        attachment.image = photo;
//        attachment.bounds = CGRectMake(0, 0, width, height);
//        NSAttributedString *photoString = [NSAttributedString attributedStringWithAttachment:attachment];
//        _messageLab.attributedText = photoString;
//        [self calculateLayoutWith:photoString];
        
        
        UIImage *photo = [image resizeToSize:CGSizeMake(width, height)];
        _photoImageView.hidden = NO;
        _photoImageView.image = photo;
        
        NSLog(@"Main thread? %d", [NSThread isMainThread]);
        NSLog(@"width:%f, height:%f", width, height);
    }];
}

-(BOOL)isTapedInContent:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.contentView];
    NSLog(@"%f,%f", point.x, point.y);
    if (CGRectContainsPoint(self.messageView.frame, point)) {
        return YES;
    }
    
    return NO;
}

//-(void)tapCellAction:(UITapGestureRecognizer *)tap{
//    CGPoint point = [tap locationInView:self.contentView];
//    NSLog(@"%f,%f", point.x, point.y);
//    if (CGRectContainsPoint(self.messageView.frame, point)) {
//        if (_typedMessage) {
//            switch (_typedMessage.mediaType) {
//                case kAVIMMessageMediaTypeAudio:{
//                    [self manageVoicePlayingWith:_typedMessage];
//                }
//                    
//                    break;
//                    
//                default:
//                    break;
//            }
//        }
//    }
//    
//}
//
//-(void)manageVoicePlayingWith:(AVIMTypedMessage *)message{
//    NSString *voicePath = [[QYDataManager sharedInstance] voiceFilePathForMessageID:message.messageId];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:voicePath]) {
//        //如果本地存在，播放
//        [[QYAudioPlayer sharedInstance] playAudio:voicePath];
//        return;
//    }
//    
//    //如果本地不存在，则通过网络下载
//    NSLog(@"语音文件本地不存在，开始网络下载……");
//    //网络下载
//#if 1
//    [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        NSLog(@"下载成功");
//        [[QYAudioPlayer sharedInstance] playAudioWithData:data];
//    }];
//#else
//    [[QYNetworkManager sharedInstance] downloadWithUrl:message.file.url withMessageID:message.messageId completion:^(NSString *filePath) {
//        NSLog(@"下载成功");
//        [[QYAudioPlayer sharedInstance] playAudio:filePath];
//    }];
//#endif
//}
@end


#pragma mark - LeftMessageTableViewCell
@interface LeftMessageTableViewCell ()
@end

@implementation LeftMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

//-(void)setMessage:(id)message{
//    [super setMessage:message];
//}
//
//-(void)setTypedMessage:(AVIMTypedMessage *)typedMessage{
//    [super setTypedMessage:typedMessage];
//    switch (typedMessage.mediaType) {
//        case kAVIMMessageMediaTypeAudio:
//            
//            break;
//            
//        default:
//            break;
//    }
//}


@end

#pragma mark - RightMessageTableViewCell
@interface RightMessageTableViewCell ()
@end

@implementation RightMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

//-(void)setMessage:(id)message{
//    [super setMessage:message];
//    
//    
//}
//
//-(void)setTypedMessage:(AVIMTypedMessage *)typedMessage{
//    [super setTypedMessage:typedMessage];
//    switch (typedMessage.mediaType) {
//        case kAVIMMessageMediaTypeAudio:
//            break;
//            
//        default:
//            break;
//    }  
//}






@end
