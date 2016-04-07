//
//  QYEditBaseInfoVC.m
//  约吧
//
//  Created by 云菲 on 4/5/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYEditBaseInfoVC.h"
#import "QYImagesPicker.h"
#import "NSDate+Extension.h"
#import "AppDelegate.h"

@interface QYEditBaseInfoVC () <QYImagesPickerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) UIView *birthdayInputView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSDate *birthday;
@property (weak, nonatomic) IBOutlet UITextField *nameTf;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTf;
@property (nonatomic) BOOL isWoman;
@end

@implementation QYEditBaseInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _birthdayTf.inputView = self.birthdayInputView;
}

#pragma mark - Events
- (IBAction)leftBarButtonItemAction:(UIBarButtonItem *)sender {
    //TODO: 提示用户：若不编辑基本信息，系统将会屏蔽盖用户
    
    [self presentToHomeViewController];
}

- (IBAction)rightBarButtonItemAction:(UIBarButtonItem *)sender {
    [_nameTf resignFirstResponder];
    [_birthdayTf resignFirstResponder];
    
    //TODO: 检查是否有未填项
    
    //若有未填项，提示用户将会被屏蔽
    
    //TODO: 提示用户注册成功
    
    
    //若成功，跳转到主页
    [self presentToHomeViewController];
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
    _birthdayTf.text = [sender.date dateToStringWithFormatter:@"dd/MM/yyyy"];
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
