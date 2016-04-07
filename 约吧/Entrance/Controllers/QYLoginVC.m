//
//  QYLoginVC.m
//  约吧
//
//  Created by 云菲 on 4/6/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYLoginVC.h"
#import "AppDelegate.h"

#import <AFNetworking.h>

@interface QYLoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *telNumTf;
@property (weak, nonatomic) IBOutlet UITextField *passwdTf;

@end

@implementation QYLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_telNumTf becomeFirstResponder];
}

- (IBAction)leftBarButtonItemAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app setRootViewControllerToHome];
    
    
    //TODO: 请求登录
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSString *url = [kBaseUrl stringByAppendingPathComponent:kRegisterApi];
//    NSDictionary *parames = @{@"telephone" : _telNumTf.text,
//                              @"password" : _passwdTf.text};
//    [manager POST:url parameters:parames progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@", responseObject);
//        if ([responseObject[@"success"] integerValue] == 1) {
//            //TODO: 提示用户登录成功
//            
//            //进入主页
//            UINavigationController *homeNav = [self.storyboard instantiateViewControllerWithIdentifier:kHomeNavIdentifier];
//            [self presentViewController:homeNav animated:YES completion:^{
//                
//            }];
//            
//        }else{
//            //TODO: 提示用户注册失败，说明失败原因
//            
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@", error);
//        //TODO: 提示用户网络不可用
//        
//    }];
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
