//
//  QYRegisterVC.m
//  约吧
//
//  Created by 云菲 on 4/5/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYRegisterVC.h"
#import "QYVerifyCodeBtn.h"
#import "QYAccount.h"
#import "QYChatManager.h"
#import "NSString+Extension.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <AVIMClient.h>

@interface QYRegisterVC () <UITextFieldDelegate, QYNetworkDelegate>
@property (weak, nonatomic) IBOutlet QYVerifyCodeBtn *getVerifyCodeBtn;
@property (weak, nonatomic) IBOutlet UITextField     *telNumberTf;
@property (weak, nonatomic) IBOutlet UITextField     *verifyCodeTf;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextItem;
@property (weak, nonatomic) IBOutlet UITextField     *passwdTf;
@property (weak, nonatomic) IBOutlet UITextField     *passwdAgainTf;
@property (weak, nonatomic) IBOutlet UILabel         *countDownLabel;
@property (weak, nonatomic) IBOutlet UIButton        *registerBtn;

@property (strong, nonatomic) NSTimer   *countDownTimer;//60s计时器
@property (nonatomic        ) NSInteger second;//秒数
@property (strong, nonatomic) NSString  *telephone;//合法的手机号

@end

@implementation QYRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [QYNetworkManager sharedInstance].delegate = self;

    //设置第一响应
    [_telNumberTf becomeFirstResponder];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    //禁用获取验证码按钮
    _getVerifyCodeBtn.codeState = kVerifyCodeStateInactive;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    //释放计时器
    [_countDownTimer invalidate];
    _countDownTimer = nil;
    
    //删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    //重置第一响应
    [_telNumberTf resignFirstResponder];
    [_verifyCodeTf resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Events
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.telNumberTf resignFirstResponder];
    [self.verifyCodeTf resignFirstResponder];
}

- (IBAction)leftBarButtonItemAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//获取验证码
- (IBAction)getVerifyCodeAction:(QYVerifyCodeBtn *)sender {
    //更新按钮外观，修改按钮状态为“已发送”
    sender.codeState = kVerifyCodeStateSent;
    
    //开始计时，60s
    _second = kMsmCodeSeconds;
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown60s) userInfo:nil repeats:YES];
    
    //请求获取验证码
    NSDictionary *params = @{kNetworkKeyTel : _telephone};
    [[QYNetworkManager sharedInstance] getVerifyCodeWithParameters:params];
    
    //验证码输入框接受第一响应
    [_verifyCodeTf becomeFirstResponder];
}

//注册
- (IBAction)registerAction:(UIButton *)sender {
    if (_passwdTf.text.length < 6) {
        [SVProgressHUD showWithStatus:@"密码长度不得少于6位"];
        [_passwdTf becomeFirstResponder];
        return;
    }
    
    if (![_passwdTf.text isEqualToString:_passwdAgainTf.text]) {
        [SVProgressHUD showWithStatus:@"两次密码必须相同"];
        [_passwdAgainTf becomeFirstResponder];
        return;
    }
    
    [SVProgressHUD showWithStatus:kResistering];//注册中……
    
    NSDictionary *params = @{kNetworkKeyTel : _telNumberTf.text,
                              kNetworkKeyPasswd : _passwdTf.text,
                              kNetworkKeyMsmCode : _verifyCodeTf.text};
    [[QYNetworkManager sharedInstance] registerWithParameters:params];
}


//当文本框内容发生改变后，调用此方法
-(void)textFieldDidChanged:(NSNotification *)notification{
    if (_telNumberTf.text.length > 0 && _verifyCodeTf.text.length > 0 && _passwdTf.text.length > 0 && _passwdAgainTf.text.length > 0) {
        [_registerBtn setEnabled:YES];
    }else{
        [_registerBtn setEnabled:NO];
    }
    //先判断当前第一响应者是谁
    if ([_telNumberTf isFirstResponder]) {
        //如果验证码按钮是已发送状态，则无论手机号是否合法，状态都不变
        if (_getVerifyCodeBtn.codeState == kVerifyCodeStateSent) {
            return;
        }
        
        //判断手机号是否合法
        BOOL isTel = [NSString isTelephoneNumber:_telNumberTf.text];
        if (isTel) {//是手机号，可以获取验证码
            _telephone = _telNumberTf.text;
            _getVerifyCodeBtn.codeState = kVerifyCodeStateActive;
        }else{//不是手机号，禁止获取验证码
            _getVerifyCodeBtn.codeState = kVerifyCodeStateInactive;
        }

        return;
    }
}

#pragma mark - Custom Methods
//倒计时60s
-(void)countDown60s{
    _second -= 1;
   
    if (_second == 0) {//60s倒计时结束
        [_countDownTimer invalidate];
        _countDownTimer = nil;
        _getVerifyCodeBtn.codeState = kVerifyCodeStateReGet;//标记为重新获取验证码状态
        return;
    }
    
    [_getVerifyCodeBtn setTitle:[NSString stringWithFormat:@"%lds", _second] forState:UIControlStateDisabled];
}

#pragma mark - QYNetwork Delegate
-(void)didGetVerifyCode:(id)responseObject success:(BOOL)success{
    if (!success) {
        [_countDownTimer invalidate];
        _countDownTimer = nil;
        _getVerifyCodeBtn.codeState = kVerifyCodeStateActive;
        if (responseObject) {
            [SVProgressHUD showErrorWithStatus:responseObject[kResponseKeyError]];
        }else{
            [SVProgressHUD showErrorWithStatus:kNetworkFail];
        }
    }
}

-(void)didFinishRegister:(id)responseObject success:(BOOL)success{
    if (success) {
        //提示用户注册成功
        [SVProgressHUD showSuccessWithStatus:kRegisterSuccess];
        
        //保存登录信息
        NSDictionary *data = responseObject[kResponseKeyData];
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:data[kAccountKeyToken], kAccountKeyToken, data[kAccountKeyUid], kAccountKeyUid, nil];
        [[QYAccount currentAccount] saveAccount:data];
        
        //leanCloud上线
        NSInteger userId = [QYAccount currentAccount].userId;
        [QYChatManager sharedManager].client = [[AVIMClient alloc] initWithClientId:@(userId).stringValue];
        [[QYChatManager sharedManager].client openWithCallback:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"client open failed : %@", error);
                return;
            }
            //进入下一界面
            NSNumber *userId = responseObject[kResponseKeyData][kUserId];
            UIViewController *baseInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:kUserBaseInfo];
            [baseInfoVC setValue:userId forKey:@"userId"];
            [self.navigationController pushViewController:baseInfoVC animated:YES];
        }];
        
    }else{
        //提示用户注册失败，说明失败原因
        if (responseObject) {
            [SVProgressHUD showErrorWithStatus:responseObject[kResponseKeyError]];
        }else{
            [SVProgressHUD showErrorWithStatus:kNetworkFail];
        }
        
    }
}


@end
