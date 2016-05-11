//
//  QYLoginVC.m
//  约吧
//
//  Created by 云菲 on 4/6/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYLoginVC.h"
#import "AppDelegate.h"
#import "QYAccount.h"
#import "QYUserInfo.h"

#import "QYChatManager.h"

#import <AFNetworking.h>
#import <AVIMClient.h>

@interface QYLoginVC () <QYNetworkDelegate>
@property (weak, nonatomic) IBOutlet UITextField *telNumTf;
@property (weak, nonatomic) IBOutlet UITextField *passwdTf;

@end

@implementation QYLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [QYNetworkManager sharedInstance].delegate = self;
    [_telNumTf becomeFirstResponder];
}

- (IBAction)leftBarButtonItemAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//登录
- (IBAction)loginAction:(UIButton *)sender {
    [SVProgressHUD showWithStatus:kLoging];
    
    //网络请求
    NSDictionary *params = @{kNetworkKeyTel : _telNumTf.text,
                             kNetworkKeyPasswd : _passwdTf.text};
    [[QYNetworkManager sharedInstance] loginWithParameters:params];
}

-(void)didFinishLogin:(id)responseObject success:(BOOL)success{
    if (success) {
        [[QYAccount currentAccount] saveAccount:responseObject[kResponseKeyData]];
        
        //设置用户默认的筛选条件
        QYUserInfo *myInfo = [QYAccount currentAccount].myInfo;
        if ([myInfo.sex isEqualToString:@"F"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"M" forKey:kFilterKeySex];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"F" forKey:kFilterKeySex];
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:kFilterKeyDistance];
        [[NSUserDefaults standardUserDefaults] setInteger:16 forKey:kFilterKeyMinAge];
        [[NSUserDefaults standardUserDefaults] setInteger:55 forKey:kFilterKeyMaxAge];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
        
        //更改当前应用的根视图控制器
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        [app setRootViewControllerToHome];
        
        [self dismissViewControllerAnimated:YES completion:^{}];
    }else{
        if (responseObject) {
            [SVProgressHUD showErrorWithStatus:responseObject[kResponseKeyError]];
        }else{
            [SVProgressHUD showErrorWithStatus:kNetworkFail];
        }
        
    }
}

@end
