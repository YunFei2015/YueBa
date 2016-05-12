//
//  QYCreateTextViewController.m
//  约吧
//
//  Created by Shreker on 16/4/28.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYCreateTextController.h"
#import "Masonry.h"
#import "QYSelectModel.h"
@interface QYCreateTextController ()
{
    UITextField *_textField;
}
@end

@implementation QYCreateTextController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonAction:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(barButtonAction:)];
    self.navigationItem.rightBarButtonItem.enabled = _textContent.length ? YES : NO;

    switch (self.type) {
        case QYCreateTextTypeOccupation:
            self.title = @"职业";
            break;
        case QYCreateTextTypeHometown:
            self.title = @"来自";
            break;
        case QYCreateTextTypeHaunt:
            self.title = @"经常出没";
            break;
        case QYCreateTextTypeSignature:
            self.title = @"个人签名";
            break;
        case QYCreateTextTypeWeChat:
            self.title = @"我的微信";
            break;
        case QYCreateTextTypeNone:
            break;
    }

    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _textField = [UITextField new];
    [self.view addSubview:_textField];
    _textField.text = _textContent;
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@30);
        make.right.equalTo(@(-10));
        make.height.equalTo(@(30));
    }];
    
    UIView *viewLine = [UIView new];
    viewLine.backgroundColor = [UIColor lightGrayColor];
    [_textField addSubview:viewLine];
    [viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(0.5));
        make.left.and.bottom.and.right.equalTo(_textField);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}
#pragma mark - Private

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)textFieldTextDidChange:(NSNotification *)notification{
    UITextField *tf = notification.object;
    self.navigationItem.rightBarButtonItem.enabled = tf.text.length ? YES : NO;
}


-(void)barButtonAction:(UIBarButtonItem *)item{
    
    if ([item.title isEqualToString:@"完成"]) {
        QYSelectModel *model = [QYSelectModel new];
        model.strText = _textField.text;
        
        if (_contentDidEndEdit) {
            _contentDidEndEdit(model);
        }
        if (self.type == QYCreateTextTypeOccupation || self.type == QYCreateTextTypeHometown) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}
@end
