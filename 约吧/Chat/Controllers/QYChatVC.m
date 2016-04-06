//
//  ViewController.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/1.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYChatVC.h"
#import "QYMapVC.h"

//Models
#import "FriendModel.h"

//Views
#import "QYMessageCell.h"
#import "MessageBar.h"
#import "FunctionView.h"
#import "QYVoiceRecordingView.h"

//Managers
#import "QYChatManager.h"
#import "QYAudioRecorder.h"
#import "QYAudioPlayer.h"
#import "QYDataManager.h"
#import "QYNetworkManager.h"
#import "QYImagesPicker.h"

//Others
#import "UIView+Extension.h"
#import <AVOSCloudIM.h>
#import <AVFile.h>
#import <Masonry.h>

@interface QYChatVC () <AVIMClientDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, QYChatManagerDelegate, MessageBarDelegate, QYAudioPlayerDelegate, QYFunctionViewDelegate, QYImagesPickerDelegate>
@property (strong, nonatomic) MessageBar *messageBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) AVIMClient *client;
@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) QYAudioRecorder *voiceRecorder;
@property (strong, nonatomic) QYVoiceRecordingView *voiceRecordingView;


@property (strong, nonatomic) QYMessageCell *currentSelectedVoiceCell;
@property (strong, nonatomic) QYMessageCell *lastSelectedVoiceCell;



@end

@implementation QYChatVC

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

#pragma mark - Getters
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenW, kScreenH - 64 - kMessageBarHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        
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

#pragma mark - Life Cycles
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
    [QYChatManager sharedManager].delegate = nil;
    [QYAudioPlayer sharedInstance].delegate = nil;
    [QYImagesPicker sharedInstance].delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Custom Methods
- (void)addMessageBar{
    _messageBar = [[NSBundle mainBundle] loadNibNamed:@"MessageBar" owner:nil options:nil][0];
    [self.view addSubview:_messageBar];
    _messageBar.delegate = self;
    CGFloat y = kScreenH - kMessageBarHeight;
    _messageBar.frame = CGRectMake(0, y, kScreenW, kMessageBarHeight);
}

-(void)insertRowWithMessage:(id)message{
    __weak QYChatVC *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *messages = [NSMutableArray arrayWithArray:weakSelf.messages];
        [messages addObject:message];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messages.count - 1 inSection:0];
        NSArray *indexPaths = @[indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.messages = messages;
            [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
            [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
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


#pragma mark - Custom Methods - audio recorder
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

#pragma mark - Events
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
    
    _currentSelectedVoiceCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![_currentSelectedVoiceCell isTapedInContent:sender]) {
        return;
    }
    
    switch (_currentSelectedVoiceCell.messageType) {
        case kMessageTypeVoice://播放声音
            [self tapVoiceCellAction];
            break;
            
        case kMessageTypePhoto://放大图片
            [self tapPhotoCellAction];
            break;
            
        case kMessageTypeLocation://查看地图
            [self tapLocationCellAction];
            break;
            
        default:
            break;
    }
}

-(void)tapVoiceCellAction{
#if 1
    AVIMAudioMessage *message = (AVIMAudioMessage *)_currentSelectedVoiceCell.message;
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

-(void)tapPhotoCellAction{
    
}

-(void)tapLocationCellAction{
    
}

#pragma mark - QYAudioPlayer Delegate
-(void)didAudioPlayerBeginPlay:(AVAudioPlayer *)player{
    NSLog(@"开始播放");
    //UI
    if (_lastSelectedVoiceCell != _currentSelectedVoiceCell) {
        [_lastSelectedVoiceCell stopVoiceAnimating];
        _lastSelectedVoiceCell = _currentSelectedVoiceCell;
    }
    [_currentSelectedVoiceCell startVoiceAnimating];
}

-(void)didAudioPlayerPausePlay:(AVAudioPlayer *)player{
    
}

-(void)didAudioPlayerStopPlay:(AVAudioPlayer *)player{
    NSLog(@"====播放完成");
    player.currentTime = 0;
    [_currentSelectedVoiceCell stopVoiceAnimating];
}

-(void)didAudioPlayerFailedPlay:(AVAudioPlayer *)player{
    player = nil;
    //TODO: 语音文件下载失败，UI提示
}


#pragma mark - Message Bar Delegate - voice methods
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
    QYMapVC *mapVC = [[QYMapVC alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mapVC];
    [self presentViewController:navVC animated:YES completion:nil];
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

#pragma mark - Chat Manager Delegate
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

-(void)willSendTypedMessage:(AVIMTypedMessage *)message{
    [self insertRowWithMessage:message];
    //TODO: 风火轮，正在发送
}

-(void)didSendTypedMessage:(AVIMTypedMessage *)message succeeded:(BOOL)succeeded{
    //TODO: 发送成功，风火轮停止；发送失败，提示发送失败
    
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


#pragma mark - AVIM Client Delegate
-(void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message{
//    //下载富文本附件
//    [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        if (error) {
//            NSLog(@"%@", error);
//            return;
//        }
//    }];
    
    [self insertRowWithMessage:message];
}

-(void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message{
    [self insertRowWithMessage:message];
}


#pragma mark - Table View Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id message = _messages[indexPath.row];
//    QYMessageCell *cell;
//
//    if ([message isKindOfClass:[AVIMTypedMessage class]]) {
//        AVIMTypedMessage *typedMessage = (AVIMTypedMessage *)message;
//        switch (typedMessage.mediaType) {
//            case kAVIMMessageMediaTypeAudio:
//                cell = [tableView dequeueReusableCellWithIdentifier:kVoiceCell forIndexPath:indexPath];
//                break;
//            case kAVIMMessageMediaTypeImage:
//                cell = [tableView dequeueReusableCellWithIdentifier:kPhotoCell forIndexPath:indexPath];
//                break;
//            case kAVIMMessageMediaTypeLocation:
//                cell = [tableView dequeueReusableCellWithIdentifier:kLocationCell forIndexPath:indexPath];
//                break;
//                
//            default:
//                break;
//        }
//        cell.typedMessage = typedMessage;
//    }else{
//        cell = [tableView dequeueReusableCellWithIdentifier:kTextCell forIndexPath:indexPath];
//        cell.message = message;
//    }
//    
//    if ([[message clientId] isEqualToString:_userName]) {
//        [cell setMessageCellType:kMessageCellTypeSend];
//    }else if ([[message clientId] isEqualToString:_targetUserName]){
//        [cell setMessageCellType:kMessageCellTypeReceive];
//    }else{
//        NSLog(@"这不可能！");
//    }
//    
//    return cell;
    
    
    
    
    QYMessageCell *cell;
    if ([[message clientId] isEqualToString:_userName]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kRightCellIdentifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:kRightMessageCellNib owner:nil options:nil][0];
        }
        
    }
    
    if ([[message clientId] isEqualToString:_targetUserName]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kLeftCellIdentifier];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:kLeftMessageCellNib owner:nil options:nil][0];
        }
    }
    
    cell.message = message;
    return cell;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    QYMessageCell *messageCell = (QYMessageCell *)cell;
//    id message = _messages[indexPath.row];
//
//    if ([message isKindOfClass:[AVIMTypedMessage class]]) {
//        AVIMTypedMessage *typedMessage = (AVIMTypedMessage *)message;
//        messageCell.typedMessage = typedMessage;
//    }else{
//        messageCell.message = message;
//    }
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
//    [cell setMessage:message];
//
////    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
////    return size.height + 1;
//    return [cell heightWithMessage:message];
//}
@end
