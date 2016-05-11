//
//  QYEditBaseInfoVC.m
//  约吧
//
//  Created by 云菲 on 4/5/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYEditBaseInfoVC.h"
#import "QYUserInfo.h"
#import "QYImagesPicker.h"
#import "QYNetworkManager.h"
#import "NSDate+Extension.h"
#import "AppDelegate.h"

#import <SVProgressHUD.h>

@interface QYEditBaseInfoVC () <QYImagesPickerDelegate, QYNetworkDelegate>
@property (weak, nonatomic  ) IBOutlet UIImageView  *iconImageView;
@property (weak, nonatomic  ) IBOutlet UITextField  *nameTf;
@property (weak, nonatomic  ) IBOutlet UITextField  *birthdayTf;
@property (strong, nonatomic) UIView       *birthdayInputView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSDate       *birthday;
@property (strong, nonatomic) NSString     *sex;
@end

@implementation QYEditBaseInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _birthdayTf.inputView = self.birthdayInputView;
    _sex = @"M";
}

#pragma mark - Events
- (IBAction)leftBarButtonItemAction:(UIBarButtonItem *)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"跳过" message:@"若跳过此页，系统将会将您屏蔽，确定要跳过吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //确定跳过，切换到主页
        [self presentToHomeViewController];
    }];
    [controller addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    [controller addAction:action2];
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (IBAction)rightBarButtonItemAction:(UIBarButtonItem *)sender {
    [_nameTf resignFirstResponder];
    [_birthdayTf resignFirstResponder];
    
    if (_nameTf.text.length == 0 || _birthdayTf.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:kEditBaseInfo];
    }else{
        [SVProgressHUD showWithStatus:kCommitBaseInfo];

        //网络请求
        NSMutableDictionary *parameters = [[QYAccount currentAccount] accountParameters];
        [parameters setObject:_nameTf.text forKey:kUserName];
        [parameters setObject:_sex forKey:kUserSex];
        
        [QYNetworkManager sharedInstance].delegate = self;
        [[QYNetworkManager sharedInstance] updateUserInfoWithParameters:parameters];
        
        //显示正在加载
        [SVProgressHUD show];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_nameTf resignFirstResponder];
    [_birthdayTf resignFirstResponder];
}

//选择性别
- (IBAction)sexSelectedAction:(UISegmentedControl *)sender {
    [_nameTf resignFirstResponder];
    [_birthdayTf resignFirstResponder];
    
    _sex = sender.selectedSegmentIndex == 0 ? @"M" : @"F";
}

//选择出生日期
-(void)selectDate:(UIDatePicker *)sender{
    _birthdayTf.text = [sender.date stringFromDateWithFormatter:@"dd/MM/yyyy"];
}

//选择照片
- (IBAction)selectPhoto:(UITapGestureRecognizer *)sender {
    [QYImagesPicker sharedInstance].delegate = self;
    [[QYImagesPicker sharedInstance] selectImageWithViewController:self];
}

#pragma mark - QYNetworkManager Delegate
-(void)didUpdateUserInfo:(id)responseObject success:(BOOL)success{
    if (success) {
        [SVProgressHUD dismiss];
        
        //保存登录信息
        [[QYAccount currentAccount] saveAccount:responseObject[kResponseKeyData]];
        
        //设置默认的筛选条件
        if ([_sex isEqualToString:@"F"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"M" forKey:kFilterKeySex];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"F" forKey:kFilterKeySex];
        }
    
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:kFilterKeyDistance];
        [[NSUserDefaults standardUserDefaults] setInteger:16 forKey:kFilterKeyMinAge];
        [[NSUserDefaults standardUserDefaults] setInteger:55 forKey:kFilterKeyMaxAge];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //若成功，跳转到主页
        [self presentToHomeViewController];
    }else{
        //提示用户更新失败，说明失败原因
        if (responseObject) {
            [SVProgressHUD showErrorWithStatus:responseObject[kResponseKeyError]];
        }else{
            [SVProgressHUD showErrorWithStatus:kNetworkFail];
        }
    }
}

#pragma mark - Custom Methods
//跳转到主页
-(void)presentToHomeViewController{
    [self dismissViewControllerAnimated:YES completion:^{}];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app setRootViewControllerToHome];
}

#pragma mark - QYImagesPicker Delegate
-(void)didFinishSelectImages:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    _iconImageView.image = image;
    [QYImagesPicker sharedInstance].delegate = nil;
}


#pragma mark - Getters
-(UIView *)birthdayInputView{
    if (_birthdayInputView == nil) {
        UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH - 200, kScreenW, 200)];
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 200)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.locale = [NSLocale currentLocale];
        _datePicker.backgroundColor = [UIColor whiteColor];
        [_datePicker addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventValueChanged];
        
        [inputView addSubview:_datePicker];
        _birthdayInputView = inputView;
    }
    return _birthdayInputView;
}

@end
