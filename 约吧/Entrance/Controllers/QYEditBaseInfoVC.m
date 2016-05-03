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
#import "NSDate+Extension.h"
#import "AppDelegate.h"

#import <SVProgressHUD.h>

@interface QYEditBaseInfoVC () <QYImagesPickerDelegate>
@property (weak, nonatomic  ) IBOutlet UIImageView  *iconImageView;
@property (weak, nonatomic  ) IBOutlet UITextField  *nameTf;
@property (weak, nonatomic  ) IBOutlet UITextField  *birthdayTf;
@property (strong, nonatomic) UIView       *birthdayInputView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSDate       *birthday;
@property (nonatomic        ) BOOL         isWoman;
@end

@implementation QYEditBaseInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _birthdayTf.inputView = self.birthdayInputView;
}

#pragma mark - Events
- (IBAction)leftBarButtonItemAction:(UIBarButtonItem *)sender {
    //TODO: 提示用户：若不编辑基本信息，系统将会屏蔽该用户
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"警告" message:@"若跳过此页，系统将会将您屏蔽，确定要跳过吗？" preferredStyle:UIAlertControllerStyleAlert];
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
        //TODO: 网络请求
        
        
        //获取默认的筛选条件
        QYUserInfo *myInfo = [QYAccount currentAccount].myInfo;
        [[NSUserDefaults standardUserDefaults] setBool:!myInfo.isMan forKey:kFilterKeySex];
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:kFilterKeyDistance];
        [[NSUserDefaults standardUserDefaults] setInteger:16 forKey:kFilterKeyMinAge];
        [[NSUserDefaults standardUserDefaults] setInteger:55 forKey:kFilterKeyMinAge];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
         //若成功，跳转到主页
        [self presentToHomeViewController];
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
    
    _isWoman = sender.selectedSegmentIndex;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
