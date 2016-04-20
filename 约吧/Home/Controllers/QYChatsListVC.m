//
//  QYMessagesListVC.m
//  约吧
//
//  Created by 云菲 on 4/6/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYChatsListVC.h"

//models
#import "QYAccount.h"
#import "QYUserInfo.h"

//views
#import "QYChatCell.h"

//controllers
#import "QYChatVC.h"

//protocols
#import "QYNetworkManager.h"
#import "QYUserStorage.h"
#import "QYChatManager.h"

#import <AVIMConversation.h>


@interface QYChatsListVC () <UITableViewDelegate, UITableViewDataSource, QYNetworkDelegate, QYChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (strong, nonatomic) NSMutableArray *datas;//需要显示的数据列表
@property (strong, nonatomic) NSMutableArray *friends;//好友列表
@property (strong, nonatomic) QYChatCell *selectedCell;

@end

@implementation QYChatsListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _datas = [NSMutableArray array];
    
    [_tableView registerNib:[UINib nibWithNibName:@"QYChatCell" bundle:nil] forCellReuseIdentifier:kFriendCellIdentifier];
    
    [QYNetworkManager sharedInstance].delegate = self;
    
    _datas = [self getFriendsListFromDB];
    [_tableView reloadData];
    [self getFriendsListFromNetwork];
}

-(void)viewWillAppear:(BOOL)animated{
    [QYChatManager sharedManager].delegate = self;
    
    [super viewWillAppear:animated];
}

#pragma mark - Custom Methods
//从本地获取用户列表
-(NSMutableArray *)getFriendsListFromDB{
    NSArray *friends = [[QYUserStorage sharedInstance] getAllUsersWithSortType:@"matchTime"];
    _friends = [NSMutableArray arrayWithArray:friends];
    return [NSMutableArray arrayWithArray:friends];
}

//从网络获取用户列表
-(void)getFriendsListFromNetwork{
    NSDictionary *params = [[QYAccount currentAccount] accountParameters];
    [[QYNetworkManager sharedInstance] getFriendsListWithParameters:params];
}

//获取会话列表
-(NSMutableArray *)getChatsList{
    NSArray *friends = [[QYUserStorage sharedInstance] getAllUsersWithSortType:@"lastMessageAt"];
    return [NSMutableArray arrayWithArray:friends];
}

-(void)reloadLastMessageInConversation:(AVIMConversation *)conversation withIndexPath:(NSIndexPath *)indexPath{
    //把最新会话置顶
    QYUserInfo *user = _datas[indexPath.row];
    if ([_datas containsObject:user]) {
        QYChatCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        [_datas exchangeObjectAtIndex:0 withObjectAtIndex:indexPath.row];
        
        [_tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.conversation = [[QYChatManager sharedManager] conversationFromKeyedConversation:user.keyedConversation];
    }
    
}

#pragma mark - Events
- (IBAction)segmentControlAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        _datas = [self getFriendsListFromDB];
        self.titleLabel.text = [NSString stringWithFormat:@"%ld个配对", _datas.count];
        [_tableView reloadData];
    }else{
        _datas = [self getChatsList];
        self.titleLabel.text = [NSString stringWithFormat:@"%ld个聊天", _datas.count];
        [_tableView reloadData];
    }
}


#pragma mark - QYNetworkManager Delegate
-(void)didGetFriendsList:(id)responseObject success:(BOOL)success{
    if (success) {
        if (responseObject[kResponseKeySuccess]) {
            NSArray *list = responseObject[kResponseKeyData][@"users"];
            if (_datas.count == 0) {
                [[QYUserStorage sharedInstance] addUsers:list];
                _datas = [NSMutableArray arrayWithArray:[[QYUserStorage sharedInstance] getAllUsersWithSortType:kUserMatchTime]];
                self.titleLabel.text = [NSString stringWithFormat:@"%ld个配对", _datas.count];
                return;
            }
        
            NSMutableArray *datasFromNet = [NSMutableArray array];
            //对网络数据进行遍历
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //数组转模型
                QYUserInfo *user = [QYUserInfo userWithDictionary:obj];
                [datasFromNet addObject:obj];
                
                //如果网络有，本地没有，则插入到本地
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userId MATCHES %@" argumentArray:@[user.userId]];
                NSArray *results = [_datas filteredArrayUsingPredicate:predicate];
                if (results.count <= 0) {
                    [_datas insertObject:user atIndex:idx];
                    [[QYUserStorage sharedInstance] addUser:obj];
                }
                
            }];
            
            //对本地用户列表进行遍历
            [_datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //如果本地有，网络没有，则删除本地
                QYUserInfo *user = (QYUserInfo *)obj;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userId MATCHES %@" argumentArray:@[user.userId]];
                NSArray *results = [datasFromNet filteredArrayUsingPredicate:predicate];
                if (results.count <= 0) {
                    [[QYUserStorage sharedInstance] deleteUser:user.userId];
                    [_datas removeObject:user];
                }
            }];
            
            [_segmentControl setSelectedSegmentIndex:1];
            [self segmentControlAction:_segmentControl];

            
            
        }else{
           
        }
    }else{
        [SVProgressHUD showErrorWithStatus:kNetworkFail];
    }
}

#pragma mark - QYChatManager Delegate
-(void)didReceiveMessage:(AVIMTypedMessage *)message inConversation:(AVIMConversation *)conversation{
    //找出包含在会话成员中的好友
    NSArray *results = [_friends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.userId BETWEEN %@", conversation.members]];
    QYUserInfo *user = results[0];
    
    //如果用户的会话属性为空，则将会话存储到内存和本地
    if (user.keyedConversation == nil) {
        user.keyedConversation = conversation.keyedConversation;
        [[QYUserStorage sharedInstance] updateUserConversation:user.keyedConversation forUserId:user.userId];
    }
    
    //将最近消息时间存储到内存
    user.lastMessageAt = [NSDate dateWithTimeIntervalSince1970:message.deliveredTimestamp];
    //将最近消息时间存储到本地
    [[QYUserStorage sharedInstance] updateUserLastMessageAt:user.lastMessageAt forUserId:user.userId];
    
    if (_segmentControl.selectedSegmentIndex == 1) {
        //找到需要更新UI的用户下标
        NSInteger index = [_datas indexOfObject:user];
        [self reloadLastMessageInConversation:conversation withIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

#pragma mark - UITableView Delegate & Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QYChatCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCellIdentifier forIndexPath:indexPath];
    QYUserInfo *user = _datas[indexPath.row];
    cell.user = user;
    if (_segmentControl.selectedSegmentIndex == 0) {
        cell.conversation = nil;
    }else{
        cell.conversation = [[QYChatManager sharedManager] conversationFromKeyedConversation:user.keyedConversation];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QYChatCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    QYChatVC *chatVC = [[QYChatVC alloc] init];
    chatVC.user = cell.user;
    //当最后一条消息改变时，调用block块，刷新视图
    chatVC.lastMessageDidChanged = ^(AVIMConversation *conversation){
        if (_segmentControl.selectedSegmentIndex == 1) {
            //找到需要更新UI的用户下标
            [self reloadLastMessageInConversation:conversation withIndexPath:indexPath];
        }
    };

    [self.navigationController pushViewController:chatVC animated:YES];
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeftSideMost animated:YES];
    
    _selectedCell = cell;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"解除匹配" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        QYUserInfo *user = _datas[indexPath.row];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"解除匹配" message:[NSString stringWithFormat:@"确定要与%@解除匹配吗？", user.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_datas removeObject: user];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            //数据库删除数据
            [[QYUserStorage sharedInstance] deleteUser:user.userId];
            
            //TODO: 服务器删除数据
        }];
        [controller addAction:action1];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            QYChatCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setEditing:NO animated:YES];
        }];
        [controller addAction:action2];
        [self presentViewController:controller animated:YES completion:nil];
    }];
    
    /*
    UITableViewRowAction *clearAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"清空聊天记录" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        QYUserInfo *user = _datas[indexPath.row];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"清空聊天记录" message:[NSString stringWithFormat:@"确定要清空与%@的聊天记录吗？", user.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //TODO: 清空聊天记录
            
            
            //数据源删除数据
            
            //界面删除
            
            //数据库删除
            
            //服务器删除
        }];
        [controller addAction:action1];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            QYChatCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setEditing:NO animated:YES];
        }];
        [controller addAction:action2];
        [self presentViewController:controller animated:YES completion:nil];
    }];
     */
    
    return @[deleteAction];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
