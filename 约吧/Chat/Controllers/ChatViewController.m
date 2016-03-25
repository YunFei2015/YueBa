//
//  ViewController.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/1.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "ChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFile.h>
#import "FriendModel.h"
#import "QYMessageCell.h"
#import "MessageTableViewCell.h"
#import "MessageBar.h"
#import "FunctionView.h"
#import "QYVoiceRecordingView.h"

#import "QYChatManager.h"
#import "QYAudioRecorder.h"
#import "QYAudioPlayer.h"
#import "QYDataManager.h"
#import "QYNetworkManager.h"
#import "QYImagesPicker.h"

#import "UIView+Extension.h"
#import <AVOSCloudIM.h>
#import <Masonry.h>

@interface ChatViewController () <AVIMClientDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, QYChatManagerDelegate, MessageBarDelegate, QYAudioPlayerDelegate, QYFunctionViewDelegate, QYImagesPickerDelegate>
@property (strong, nonatomic) MessageBar *messageBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) AVIMClient *client;
@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) QYAudioRecorder *voiceRecorder;
@property (strong, nonatomic) QYVoiceRecordingView *voiceRecordingView;


@property (strong, nonatomic) QYVoiceMessageCell *currentSelectedVoiceCell;
@property (strong, nonatomic) QYVoiceMessageCell *lastSelectedVoiceCell;



@end

@implementation ChatViewController
static NSString *leftIdentifier = @"leftMessageCell";
static NSString *rightIdentifier = @"rightMessageCell";
//#pragma mark - init
//-(instancetype)initWithFriend:(FriendModel *)friendModel{
//    self = [super init];
//    if (self) {
//        _userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];
//        [ChatManager sharedManager].userID = _userName;
//        [ChatManager sharedManager].targetUserID = _targetUserName;
//        [ChatManager sharedManager].delegate = self;
//        [[ChatManager sharedManager] queryHistoryMessagesWith:@[_targetUserName]];
//    }
//    return self;
//}

#pragma mark - getters
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenW, kScreenH - 64 - kMessageBarHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        
        [_tableView registerNib:[UINib nibWithNibName:@"QYTextMessageCell" bundle:nil] forCellReuseIdentifier:kTextCell];
        [_tableView registerNib:[UINib nibWithNibName:@"QYVoiceMessageCell" bundle:nil] forCellReuseIdentifier:kVoiceCell];
        [_tableView registerNib:[UINib nibWithNibName:@"QYPhotoMessageCell" bundle:nil] forCellReuseIdentifier:kPhotoCell];
        [_tableView registerNib:[UINib nibWithNibName:@"QYLocationMessageCell" bundle:nil] forCellReuseIdentifier:kLocationCell];
        
//        [_tableView registerClass:[QYTextMessageCell class] forCellReuseIdentifier:kTextCell];
//        [_tableView registerClass:[QYVoiceMessageCell class] forCellReuseIdentifier:kVoiceCell];
//        [_tableView registerClass:[QYPhotoMessageCell class] forCellReuseIdentifier:kPhotoCell];
//        [_tableView registerClass:[QYLocationMessageCell class] forCellReuseIdentifier:kLocationCell];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

-(QYAudioRecorder *)voiceRecorder{
    if (_voiceRecorder == nil) {
        WEAKSELF
        _voiceRecorder = [[QYAudioRecorder alloc] init];
        _voiceRecorder.maxTimeStopRecorderCompletion = ^{
            NSLog(@"已经达到最大限制时间了，进入下一步的提示");
            [weakSelf finishRecord];
        };
        _voiceRecorder.peakPowerForChannel = ^(float peakPowerForChannel){
            weakSelf.voiceRecordingView.peakPower = peakPowerForChannel;
        };
    }
    return _voiceRecorder;
}

-(QYVoiceRecordingView *)voiceRecordingView{
    if (_voiceRecordingView == nil) {
        _voiceRecordingView = [[NSBundle mainBundle] loadNibNamed:@"QYVoiceRecordingView" owner:nil options:nil][0];
        _voiceRecordingView.center = self.view.center;
        _voiceRecordingView.bounds = CGRectMake(0, 0, kScreenW / 2.f, kScreenH / 4.f);
    }
    return _voiceRecordingView;
}

#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addMessageBar];
    [self.view addSubview:self.tableView];
    
    _messages = [NSMutableArray array];
    
//    _userName = [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];
//    _targetUserName = _friendModel.userID;
    [QYChatManager sharedManager].conversation = _conversation;
    [QYChatManager sharedManager].delegate = self;
    [[QYChatManager sharedManager] queryHistoryMessagesWith:@[_targetUserName]];
 
    [QYAudioPlayer sharedInstance].delegate = self;
    [QYImagesPicker sharedInstance].delegate = self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - custom methods
- (void)addMessageBar{
    _messageBar = [[NSBundle mainBundle] loadNibNamed:@"MessageBar" owner:nil options:nil][0];
    [self.view addSubview:_messageBar];
    _messageBar.delegate = self;
    CGFloat y = kScreenH - kMessageBarHeight;
    _messageBar.frame = CGRectMake(0, y, kScreenW, kMessageBarHeight);
}

-(void)insertRowWithMessage:(id)message{
    __weak ChatViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if ([message isKindOfClass:[AVIMTypedMessage class]]) {
            NSMutableArray *messages = [NSMutableArray arrayWithArray:weakSelf.messages];
            [messages addObject:message];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messages.count - 1 inSection:0];
            NSArray *indexPaths = @[indexPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.messages = messages;
                [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });
            
            return;
//        }
        
//        if ([message isKindOfClass:[AVIMMessage class]]) {
//            NSMutableArray *messages = [NSMutableArray arrayWithArray:weakSelf.messages];
//            [messages addObject:message];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messages.count - 1 inSection:0];
//            NSArray *indexPaths = @[indexPath];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.messages = messages;
//                [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
//                [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            });
//            
//            return;
//        }
    });
}

-(void)updateContentOffsetOfTableView{
    if (_tableView.contentSize.height > _tableView.bounds.size.height) {
        _tableView.contentOffset = CGPointMake(0, _tableView.contentSize.height - _tableView.bounds.size.height);
    }
}

-(NSString *)getRecorderPath{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd-hh-mm-ss";
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *recorderPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:now]]];
    return recorderPath;
}

#pragma mark - events
//tableView的点击事件
- (void)tapAction:(UITapGestureRecognizer *)sender {
    //重置第一响应
    [_messageBar.messageTextView resignFirstResponder];
    
    //如果点击的位置在某个cell上，处理该cell的数据
    CGPoint point = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (!indexPath) {
        return;
    }
    
    QYMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isTapedInContent:sender]) {
        return;
    }
    
   
        switch (cell.messageType) {
            case kMessageTypeText:{

            }
                
                break;
            case kMessageTypeVoice:{
                _currentSelectedVoiceCell = (QYVoiceMessageCell *)cell;
                [self manageVoicePlayingWith:_currentSelectedVoiceCell.typedMessage];
            }
                
                break;
            case kMessageTypePhoto:{

            }
                
                break;
            case kMessageTypeLocation:{

            }
                
                break;
                
            default:
                break;
        }
    
}

-(void)manageVoicePlayingWith:(AVIMTypedMessage *)message{
#if 1
    [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        NSLog(@"音频数据下载或从本地读取成功");
        [[QYAudioPlayer sharedInstance] playAudioWithData:data];
    }];
#else
    NSString *voicePath = [[QYDataManager sharedInstance] voiceFilePathForMessageID:message.messageId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:voicePath]) {
        //如果本地存在，播放
        [[QYAudioPlayer sharedInstance] playAudio:voicePath];
        return;
    }
    
    //如果本地不存在，则通过网络下载
    NSLog(@"语音文件本地不存在，开始网络下载……");
    //网络下载
    [[QYNetworkManager sharedInstance] downloadWithUrl:message.file.url withMessageID:message.messageId completion:^(NSString *filePath) {
        NSLog(@"下载成功");
        [[QYAudioPlayer sharedInstance] playAudio:filePath];
    }];
#endif
}

#pragma mark - QYAudioPlayer delegate
-(void)didAudioPlayerBeginPlay:(AVAudioPlayer *)player{
    NSLog(@"开始播放");
    //UI
    if (_lastSelectedVoiceCell != _currentSelectedVoiceCell) {
        [_lastSelectedVoiceCell stopAnimating];
        _lastSelectedVoiceCell = _currentSelectedVoiceCell;
    }
    [_currentSelectedVoiceCell startAnimating];
}

-(void)didAudioPlayerPausePlay:(AVAudioPlayer *)player{
    
}

-(void)didAudioPlayerStopPlay:(AVAudioPlayer *)player{
    NSLog(@"====播放完成");
    player.currentTime = 0;
    [_currentSelectedVoiceCell stopAnimating];
}

-(void)didAudioPlayerFailedPlay:(AVAudioPlayer *)player{
    player = nil;
    //TODO: 语音文件下载失败，UI提示
}

#pragma mark - audio recorder methods
-(void)prepareRecordWithCompletion:(QYPrepareRecorderCompletion)completion{
//    [self.voiceRecorder prepareToRecordWithPath:[self getRecorderPath] completion:completion];
    NSLog(@"准备录音");
    [self.voiceRecorder prepareToRecordWithPath:kAudioPath completion:completion];
}

-(void)startRecord{
    NSLog(@"开始录音");
    WEAKSELF
    //开始录音
    [self.voiceRecorder startToRecordWithStartRecorderCompletion:^{
        [weakSelf.view addSubview:weakSelf.voiceRecordingView];
        weakSelf.voiceRecordingView.recording = YES;
    }];
}

-(void)pauseRecord{
    NSLog(@"暂停录音");
    WEAKSELF
    [self.voiceRecorder pauseToRecordWithPauseRecorderCompletion:^{
        //TODO: 提示取消录音
        weakSelf.voiceRecordingView.recording = NO;
    }];
}

-(void)continueRecord{
    NSLog(@"继续录音");
    WEAKSELF
    [self.voiceRecorder continueToRecordWithContinueRecordCompletion:^{
        //TODO: 继续录音
        weakSelf.voiceRecordingView.recording = YES;
    }];
}

-(void)cancelRecord{
    NSLog(@"取消录音");
    WEAKSELF
    //取消录音
    [self.voiceRecorder cancelRecordingWithCancelRecorderCompletion:^{
        [weakSelf.voiceRecordingView removeFromSuperview];
    }];
}

-(void)finishRecord{
    NSLog(@"结束录音");
    WEAKSELF
    //发送录音
    [self.voiceRecorder stopRecordingWithStopRecorderCompletion:^{
        [weakSelf.voiceRecordingView removeFromSuperview];
        [[QYChatManager sharedManager] sendVoiceMessage];
    }];
}

#pragma mark - message bar delegate
-(void)updateTableViewHeight{
    [_tableView updateSizeHeight:_messageBar.frame.origin.y - 64];
    [self updateContentOffsetOfTableView];
}

-(void)prepareToRecordVoiceWithCompletion:(BOOL (^)(void))completion{
    NSLog(@"prepareToRecordVoice");
    [self prepareRecordWithCompletion:completion];
}

-(void)didStartRecording{
    NSLog(@"didStartRecording");
    [self startRecord];
}

-(void)didPauseRecording{
    NSLog(@"didPauseRecording");
    [self pauseRecord];
}

-(void)didContinueRecording{
    NSLog(@"didContinueRecording");
    [self continueRecord];
}

-(void)didCancelRecording{
    NSLog(@"didCancelRecording");
    [self cancelRecord];
}

-(void)didFinishRecording{
    NSLog(@"didFinishRecording");
    [self finishRecord];
}

#pragma mark - Function View Delegate
-(void)toSelectImages{
    //选择图片
    [[QYImagesPicker sharedInstance] selectImagesWithInitPickControllerCompletion:^(UIImagePickerController *pickerController) {
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
    
}

-(void)toTakeAPhoto{
    //拍照
    [[QYImagesPicker sharedInstance] takeAPhotoWithInitPickControllerCompletion:^(UIImagePickerController *pickerController) {
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
}

-(void)toShareLocation{
    //共享位置
}

#pragma mark - QYImagesPicker Delegate
-(void)didFinishSelectImages:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSData *data = UIImageJPEGRepresentation(image, 0.6);
        
        [[QYChatManager sharedManager] sendImageMessageWithData:data];
    }];
}

-(void)didCancelSelectImages{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - chat manager delegate
-(void)didSendMessage:(AVIMMessage *)message succeeded:(BOOL)succeeded{
    if (succeeded) {
        NSString *messageText = message.content;
        //FIXME: 空格的检测要在在发送成功之前处理
        NSString *regex = @" *";//任意个空格
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([predicate evaluateWithObject:messageText]) {//如果文本是由任意个空格组成的，则不允许发送
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"不能发送空白消息" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [controller addAction:action];
            [self presentViewController:controller animated:YES completion:nil];
            return;
        }
        [self insertRowWithMessage:message];
        return;
    }
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"发送失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)didSendTypedMessage:(AVIMTypedMessage *)message succeeded:(BOOL)succeeded{
    //FIXME: 发送语音时崩溃
    [self insertRowWithMessage:message];
}

-(void)didQueryHistoryMessages:(NSArray *)historyMessages succeeded:(BOOL)succeeded{
    if (!succeeded) {
        NSLog(@"历史消息查询失败");
        return;
    }
    if (historyMessages.count == 0) {
        return;
    }
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:historyMessages.count];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [historyMessages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexPaths addObject:indexPath];
        [indexSet addIndex:idx];
    }];
    NSMutableArray *messages = [[NSMutableArray alloc] initWithArray:self.messages];
    [messages insertObjects:historyMessages atIndexes:indexSet];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.messages = messages;
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView scrollToRowAtIndexPath:indexPaths.lastObject atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}


#pragma mark - AVIM client delegate
-(void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message{
    [self insertRowWithMessage:message];
}

-(void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message{
    [self insertRowWithMessage:message];
}


#pragma mark - table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id message = _messages[indexPath.row];
    QYMessageCell *cell;

    if ([message isKindOfClass:[AVIMTypedMessage class]]) {
        AVIMTypedMessage *typedMessage = (AVIMTypedMessage *)message;
        switch (typedMessage.mediaType) {
            case kAVIMMessageMediaTypeAudio:
                cell = [tableView dequeueReusableCellWithIdentifier:kVoiceCell forIndexPath:indexPath];
                break;
            case kAVIMMessageMediaTypeImage:
                cell = [tableView dequeueReusableCellWithIdentifier:kPhotoCell forIndexPath:indexPath];
                break;
            case kAVIMMessageMediaTypeLocation:
                cell = [tableView dequeueReusableCellWithIdentifier:kLocationCell forIndexPath:indexPath];
                break;
                
            default:
                break;
        }
//        cell.typedMessage = typedMessage;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:kTextCell forIndexPath:indexPath];
//        cell.message = message;
    }
    
//    if ([[message clientId] isEqualToString:_userName]) {
//        [cell setMessageCellType:kMessageCellTypeSend];
//    }else if ([[message clientId] isEqualToString:_targetUserName]){
//        [cell setMessageCellType:kMessageCellTypeReceive];
//    }else{
//        NSLog(@"这不可能！");
//    }
    
    return cell;
    
//    if ([[message clientId] isEqualToString:_userName]) {
//        cell = [tableView dequeueReusableCellWithIdentifier:rightIdentifier];
//        if (!cell) {
//            cell = [[NSBundle mainBundle] loadNibNamed:@"RightMessageTableViewCell" owner:nil options:nil][0];
//        }
//        
//    }
//    
//    if ([[message clientId] isEqualToString:_targetUserName]) {
//        cell = [tableView dequeueReusableCellWithIdentifier:leftIdentifier];
//        if (!cell) {
//            cell = [[NSBundle mainBundle] loadNibNamed:@"LeftMessageTableViewCell" owner:nil options:nil][0];
//        }
//    }
//    
//    //如果是富媒体消息，就赋值给typedMessage
//    if ([message isKindOfClass:[AVIMTypedMessage class]]) {
//        cell.typedMessage = message;
//        return cell;
//    }
//    
//    //如果是文本消息，就赋值给message
//    cell.message = message;
//    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    QYMessageCell *messageCell = (QYMessageCell *)cell;
    id message = _messages[indexPath.row];
    
    if ([message isKindOfClass:[AVIMTypedMessage class]]) {
        AVIMTypedMessage *typedMessage = (AVIMTypedMessage *)message;
        messageCell.typedMessage = typedMessage;
    }else{
        messageCell.message = message;
    }
    
    if ([[message clientId] isEqualToString:_userName]) {
        [messageCell setMessageCellType:kMessageCellTypeSend];
    }else if ([[message clientId] isEqualToString:_targetUserName]){
        [messageCell setMessageCellType:kMessageCellTypeReceive];
    }else{
        NSLog(@"这不可能！");
    }
}

//-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    QYMessageCell *messageCell = (QYMessageCell *)cell;
//    id message = _messages[indexPath.row];
//    
//    if ([[message clientId] isEqualToString:_userName]) {
//        [messageCell setMessageCellType:kMessageCellTypeSend];
//    }else if ([[message clientId] isEqualToString:_targetUserName]){
//        [messageCell setMessageCellType:kMessageCellTypeReceive];
//    }else{
//        NSLog(@"这不可能！");
//    }
//}


//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    AVIMMessage *message = _messages[indexPath.row];
//    MessageTableViewCell *cell;
//    cell = [[NSBundle mainBundle] loadNibNamed:@"RightMessageTableViewCell" owner:nil options:nil][0];
//    
//    
//    if ([message isKindOfClass:[AVIMTypedMessage class]]) {
//        AVIMTypedMessage *typedMessage = (AVIMTypedMessage *)message;
//        [cell setTypedMessage:typedMessage];
//    }else{
//        [cell setMessage:message];
//    }
//    
//    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    return size.height + 1;
//}
@end
