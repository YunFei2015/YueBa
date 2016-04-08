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

#import <AFNetworking.h>

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
        //TODO: 保存登录信息
        NSDictionary *dict = @{kAccountKeyToken : @"token", kAccountKeyUid : @1};
//        NSDictionary *dict = @{kAccountKeyToken : responseObject[kAccountKeyToken], kAccountKeyUid : responseObject[kAccountKeyUid]};
        [[QYAccount currentAccount] saveAccount:dict];
        
        [self dismissViewControllerAnimated:YES completion:^{}];
        
        //更改当前应用的根视图控制器
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        [app setRootViewControllerToHome];
    }else{
        if (responseObject) {
            [SVProgressHUD showErrorWithStatus:responseObject[kResponseKeyData]];
        }else{
            [SVProgressHUD showErrorWithStatus:kNetworkFail];
        }
        
    }
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
