//
//  LoginViewController.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/2.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatViewController.h"
#import "FriendModel.h"

#import <AVOSCloudIM.h>
#import "QYChatManager.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *targetUserName;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click:(UIButton *)sender {
    AVIMClient *client = [[AVIMClient alloc] initWithClientId:_userName.text];
    client.messageQueryCacheEnabled = NO;
    [QYChatManager sharedManager].client = client;
    [client openWithCallback:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"聊天不可用！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:action];
            [self presentViewController:controller animated:YES completion:nil];
        }
//        [[NSUserDefaults standardUserDefaults] setValue:_userName.text forKey:@"userID"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        FriendModel *friend = [[FriendModel alloc] init];
//        friend.userID = _targetUserName.text;
        ChatViewController *chatVC = [[ChatViewController alloc] init];
        chatVC.userName = _userName.text;
        chatVC.targetUserName = _targetUserName.text;
//        chatVC.friendModel = friend;
        
        AVIMConversationQuery *query = [client conversationQuery];
        [query whereKey:@"m" containsAllObjectsInArray:@[_userName.text, _targetUserName.text]];
        [query whereKey:@"m" sizeEqualTo:2];
        [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
            if (objects.count == 0) {
                [client createConversationWithName:@"Tom and Jerry" clientIds:@[_targetUserName.text] attributes:nil options:AVIMConversationOptionNone callback:^(AVIMConversation *conversation, NSError *error) {
                    chatVC.conversation = conversation;
                    [self.navigationController pushViewController:chatVC animated:YES];
                }];
            }else{
                chatVC.conversation = objects.firstObject;
                [self.navigationController pushViewController:chatVC animated:YES];
            }
        }];
     }];
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    [_targetUserName resignFirstResponder];
//    UIViewController *chatViewController = segue.destinationViewController;
//    [chatViewController setValue:_userName.text forKey:@"userName"];
//    [chatViewController setValue:_targetUserName.text forKey:@"targetUserName"];
//    
//}


@end
