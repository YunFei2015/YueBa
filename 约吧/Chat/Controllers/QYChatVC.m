//
//  ViewController.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/1.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYChatVC.h"
#import "AppDelegate.h"

//controllers
#import "QYLocationShareVC.h"
#import "QYLocationMapVC.h"
#import "QYPhotoBrowser.h"

//Models
#import "QYUserInfo.h"

//Views
#import "QYMessageCell.h"
#import "MessageBar.h"
#import "QYVoiceRecordingView.h"


//Managers
#import "QYChatManager.h"
#import "QYAudioRecorder.h"
#import "QYAudioPlayer.h"
#import "QYUserStorage.h"
#import "QYImagesPicker.h"
#import "QYPhotoBrowserTransition.h"

//Others
#import "UIView+Extension.h"
#import <AVOSCloudIM.h>
#import <AVFile.h>
#import <AVPush.h>
#import <Masonry.h>

@interface QYChatVC () <UITableViewDelegate, UITableViewDataSource, QYChatManagerDelegate, MessageBarDelegate, QYAudioPlayerDelegate, QYFunctionViewDelegate, QYImagesPickerDelegate, UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) MessageBar *messageBar;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableDictionary *groups;//消息按时间分组
@property (strong, atomic) NSMutableArray *messages;//消息列表
@property (strong, nonatomic) NSMutableArray *images;//图片列表，用于图片轮播


@property (strong, nonatomic) QYAudioRecorder *voiceRecorder;
@property (strong, nonatomic) QYVoiceRecordingView *voiceRecordingView;//录音动画

@property (strong, nonatomic) AVIMConversation *conversation;//当前会话
@property (strong, nonatomic) QYMessageCell *currentSelectedVoiceCell;//当前选中的语音消息
@property (strong, nonatomic) QYMessageCell *lastSelectedVoiceCell;//上一个选中的语音消息

@property (nonatomic) BOOL lastMessageChanged;//最后一条消息是否变化了
@end

@implementation QYChatVC
#pragma mark - Getters
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenW, kScreenH - 64 - kMessageBarHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        
        [_tableView registerNib:[UINib nibWithNibName:kRightMessageCellNib bundle:nil] forCellReuseIdentifier:kRightCellIdentifier];
        [_tableView registerNib:[UINib nibWithNibName:kLeftMessageCellNib bundle:nil] forCellReuseIdentifier:kLeftCellIdentifier];
        
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
    
    [self configNavigationBar];
    [self addMessageBar];
    [self.view addSubview:self.tableView];
    
    _messages = [NSMutableArray array];
    _images = [NSMutableArray array];
    
    
    [QYAudioPlayer sharedInstance].delegate = self;
    [QYImagesPicker sharedInstance].delegate = self;
    
    if (_user.keyedConversation) {
        _conversation = [[QYChatManager sharedManager] conversationFromKeyedConversation:_user.keyedConversation];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self queryMessages];
        });
    }else{
        [[QYChatManager sharedManager] findConversationWithUser:_user.userId];
    }
}

-(void)dealloc{
    [[QYUserStorage sharedInstance] updateUserLastMessageAt:_user.lastMessageAt forUserId:_user.userId];
    
    [QYChatManager sharedManager].delegate = nil;
    [QYAudioPlayer sharedInstance].delegate = nil;
    [QYImagesPicker sharedInstance].delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [QYChatManager sharedManager].delegate = self;
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[QYUserStorage sharedInstance] updateUserLastMessageAt:_user.lastMessageAt forUserId:_user.userId];
    //反向传值
    if (_lastMessageChanged) {
        _lastMessageDidChanged(_conversation);
    }
    
    //取消静音，开始接收此对话的离线推送
    [_conversation unmuteWithCallback:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
    
    [super viewWillDisappear:animated];
    
}


#pragma mark - Custom Methods
-(void)configNavigationBar{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"messages_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    CGFloat iconW = 40;
    CGFloat iconH = 40;
    CGFloat iconX = 0;
    CGFloat iconY = (44 - iconH) / 2.f;
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconW, iconH)];
    iconView.image = [UIImage imageNamed:_user.iconUrl];
    [UIView drawRoundCornerOnImageView:iconView];
    [titleView addSubview:iconView];
    
    CGFloat nameW = 40;
    CGFloat nameH = 20;
    CGFloat nameX = iconX + iconW + 5;
    CGFloat nameY = (44 - nameH) / 2.f;
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(nameX, nameY, nameW, nameH)];
    name.textColor = [UIColor redColor];
    name.text = _user.name;
    [titleView addSubview:name];
    
    self.navigationItem.titleView = titleView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getUserDetailInfo)];
    [titleView addGestureRecognizer:tap];
}

//TODO: 查看用户详细信息
-(void)getUserDetailInfo{
    NSLog(@"正在查看用户详细信息");
}


- (void)addMessageBar{
    _messageBar = [[NSBundle mainBundle] loadNibNamed:@"MessageBar" owner:nil options:nil][0];
    [self.view addSubview:_messageBar];
    _messageBar.delegate = self;
    CGFloat y = kScreenH - kMessageBarHeight;
    _messageBar.frame = CGRectMake(0, y, kScreenW, kMessageBarHeight);
}

-(void)queryMessages{
    //开启静音，不再接收此对话的离线推送
    [_conversation muteWithCallback:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
    
    //查询聊天记录
    NSArray *indexPaths = [self getMessagesIndexPathsWithCount:20];
    if (indexPaths) {
        WEAKSELF
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:indexPaths.lastObject atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            //将该会话标记为已读
            [_conversation markAsReadInBackground];
        });
    }
}

-(NSArray *)getMessagesIndexPathsWithCount:(NSInteger)count{
    NSArray *array = [_conversation queryMessagesFromCacheWithLimit:self.messages.count + count];
    if (array.count > self.messages.count) {
        NSArray *messages = [array subarrayWithRange:NSMakeRange(0, array.count - _messages.count)];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:messages.count];
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [indexPaths addObject:indexPath];
            [indexSet addIndex:idx];
        }];
        
        [self.messages insertObjects:messages atIndexes:indexSet];
        return indexPaths;
    }
    return nil;
}

-(void)divideMessagesIntoGroupsByDate{
    [_messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
}

-(void)insertRowWithMessage:(AVIMTypedMessage *)message{
    _lastMessageChanged = YES;
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _user.lastMessageAt = [NSDate date];
        [weakSelf.messages addObject:message];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.messages.count - 1 inSection:0];
        NSArray *indexPaths = @[indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONGSELF
            [strongSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
            [strongSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            CGSize size = strongSelf.tableView.contentSize;
//            [strongSelf.tableView setContentOffset:CGPointMake(1, size.height) animated:YES];
        });
    });
}

-(void)updateContentOffsetOfTableView{
    if (_tableView.contentSize.height > _tableView.bounds.size.height) {
        _tableView.contentOffset = CGPointMake(0, _tableView.contentSize.height - _tableView.bounds.size.height);
    }
}

//-(NSString *)getRecorderPath{
//    NSDate *now = [NSDate date];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd-hh-mm-ss";
//    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *recorderPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:now]]];
//    return recorderPath;
//}


-(void)getMoreMessages:(NSInteger)count{
    NSArray *indexPaths = [self getMessagesIndexPathsWithCount:count];
    if (indexPaths) {
        WEAKSELF
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            [weakSelf.tableView scrollToRowAtIndexPath:indexPaths.lastObject atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
    }else{
        NSLog(@"没有更多消息了");
    }
}

#pragma mark - Custom Methods - send messages
-(void)pushMessage:(NSString *)title{
    NSDictionary *data = @{
        @"alert":             title, //显示内容
        @"badge":             @"Increment", //应用图标显示未读消息个数是递增当前值
        @"sound":             @"sms-received1.caf", //提示音
        @"content-available": @"1"
    };
    [AVPush sendPushDataToChannelInBackground:_user.userId withData:data];
}

-(void)sendTextMessageWithContent:(NSString *)message{
    [[QYChatManager sharedManager] sendTextMessage:message withConversation:_conversation];
    [self pushMessage:[NSString stringWithFormat:@"%@:%@", _user.name, message]];
}

-(void)sendImageMessageWithData:(NSData *)data{
    [[QYChatManager sharedManager] sendImageMessageWithData:data withConversation:_conversation];
    [self pushMessage:[NSString stringWithFormat:@"%@发来一张图片", _user.name]];
}

-(void)sendVoiceMessage{
    [[QYChatManager sharedManager] sendVoiceMessageWithConversation:_conversation];
    [self pushMessage:[NSString stringWithFormat:@"%@发来一段语音", _user.name]];
}

-(void)sendLocationMessageWithAnnotation:(QYPinAnnotation *)annotation{
    [[QYChatManager sharedManager] sendLocationMessageWithAnnotation:annotation withConversation:_conversation];
    [self pushMessage:[NSString stringWithFormat:@"%@发来位置信息", _user.name]];
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
        [weakSelf sendVoiceMessage];
    }];
}


#pragma mark - Events
-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
    self.revealViewController.frontViewPosition = FrontViewPositionLeftSide;
}

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
    
    _selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([_selectedCell isTapedInContent:sender]) {
        switch (_selectedCell.messageType) {
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
        return;
    }
    
    if ([_selectedCell isTapedInIcon:sender]) {
        [self getUserDetailInfo];
        return;
    }
}

-(void)tapVoiceCellAction{
#if 1
    _currentSelectedVoiceCell = _selectedCell;
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
    NSIndexPath *indexPath = [_tableView indexPathForCell:_selectedCell];
    NSInteger index = indexPath.row;
    
    //获取从当前消息开始往前的50条消息
    NSArray *messages = [_conversation queryMessagesFromCacheWithLimit:_messages.count - index + 50];
    AVFile *selectedFile = _selectedCell.message.file;
    __block NSInteger currentIndex;
    //遍历50条消息，将所有image消息过滤出来，并把图片数据流存储到内存中
    [_images removeAllObjects];
    [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AVIMTypedMessage *message = (AVIMTypedMessage *)obj;
        if (message.mediaType == kAVIMMessageMediaTypeImage) {
            AVFile *file = message.file;
            UIImage *image = [UIImage imageWithData:[file getData]];
            [_images addObject:image];
            
            if ([file.objectId isEqualToString:selectedFile.objectId]) {
                currentIndex = [_images indexOfObject:image];
            }
        }
    }];
    
    QYPhotoBrowser *photoBrowser = [[QYPhotoBrowser alloc] initWithNibName:@"QYPhotoBrowser" bundle:nil];
    photoBrowser.transitioningDelegate = self;
    self.transitioningDelegate = self;
    photoBrowser.photos = _images;
    [self.revealViewController presentViewController:photoBrowser animated:YES completion:^{
    }];
    photoBrowser.currentIndex = currentIndex;
}

-(void)tapLocationCellAction{
    AVIMLocationMessage *message = (AVIMLocationMessage *)_selectedCell.message;
    QYLocationMapVC *mapVC = [[QYLocationMapVC alloc] initWithLocation:[[CLLocation alloc] initWithLatitude:message.latitude longitude:message.longitude] title:message.text];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mapVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioning Delegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    QYPhotoBrowserTransition *transition = [[QYPhotoBrowserTransition alloc] init];
    return transition;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    QYPhotoBrowserTransition *transition = [[QYPhotoBrowserTransition alloc] init];
    return transition;
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

-(void)sendMessage:(NSString *)message{
    [self sendTextMessageWithContent:message];
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
    [[QYImagesPicker sharedInstance] selectImageWithViewController:self];
}

-(void)toTakeAPhoto{
    //拍照
    [[QYImagesPicker sharedInstance] takeAPhotoWithViewController:self];
}

-(void)toShareLocation{
    //共享位置
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    if (app.location) {
        QYLocationShareVC *mapVC = [[QYLocationShareVC alloc] init];
        WEAKSELF
        mapVC.sendLocationToShare = ^(QYPinAnnotation *annotation){
            [weakSelf sendLocationMessageWithAnnotation:annotation];
        };
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mapVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"请打开定位服务" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //TODO: 跳转到设置界面
        }];
        [controller addAction:action];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleCancel handler:nil];
        [controller addAction:action1];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}


#pragma mark - QYImagesPicker Delegate
-(void)didFinishSelectImages:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image, 0);
    [self sendImageMessageWithData:data];
}


#pragma mark - Chat Manager Delegate
-(void)didFindConversation:(AVIMConversation *)conversation succeeded:(BOOL)succeeded{
    if (succeeded) {
        _conversation = conversation;
        _user.keyedConversation = _conversation.keyedConversation;
        //本地缓存
        [[QYUserStorage sharedInstance] updateUserConversation:conversation.keyedConversation forUserId:_user.userId];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self queryMessages];
        });
        
    }
}

-(void)willSendMessage:(AVIMTypedMessage *)message{
    //将文件上传至云端
    if (message.file) {
        [message.file saveInBackground];
    }
    
    [self insertRowWithMessage:message];
    //TODO: 风火轮，正在发送
}

-(void)didSendMessage:(AVIMTypedMessage *)message succeeded:(BOOL)succeeded{
    //TODO: 发送成功，风火轮停止；发送失败，提示发送失败

}

-(void)didReceiveMessage:(AVIMTypedMessage *)message inConversation:(AVIMConversation *)conversation{
    if ([conversation.conversationId isEqualToString:_conversation.conversationId]) {
        //下载富文本附件
        [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
                return;
            }
        }];
        _user.messageStatus = QYMessageStatusDefault;
        [[QYUserStorage sharedInstance] updateUserMessageStatus:_user.messageStatus forUserId:_user.userId];
        [self insertRowWithMessage:message];
    }
}

#pragma mark - Table View Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AVIMTypedMessage *message = _messages[indexPath.row];
    QYMessageCell *cell;
    
    NSLog(@"message status : %d", message.status);
    switch (message.status) {
        case AVIMMessageStatusNone://无
            cell = [tableView dequeueReusableCellWithIdentifier:kRightCellIdentifier forIndexPath:indexPath];
            break;
        
        case AVIMMessageStatusSending://发送中
            cell = [tableView dequeueReusableCellWithIdentifier:kRightCellIdentifier forIndexPath:indexPath];
            break;
            
        case AVIMMessageStatusSent://发送
            cell = [tableView dequeueReusableCellWithIdentifier:kRightCellIdentifier forIndexPath:indexPath];
            break;
            
        case AVIMMessageStatusDelivered://接收
            cell = [tableView dequeueReusableCellWithIdentifier:kLeftCellIdentifier forIndexPath:indexPath];
            break;
            
        case AVIMMessageStatusFailed://失败
            cell = [tableView dequeueReusableCellWithIdentifier:kRightCellIdentifier forIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    NSLog(@"cell : %@", cell);
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

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.y < 0) {
        [self getMoreMessages:20];//获取20条历史消息
    }
}
@end
