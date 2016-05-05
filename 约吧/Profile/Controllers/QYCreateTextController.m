//
//  QYCreateTextViewController.m
//  约吧
//
//  Created by Shreker on 16/4/28.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYCreateTextController.h"
#import "Masonry.h"

@interface QYCreateTextController ()

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
    
    switch (self.type) {
        case QYCreateTextTypeHaunt:
            self.title = @"经常出没";
            break;
        case QYCreateTextTypeSignature:
            self.title = @"签名";
            break;
        case QYCreateTextTypeWeChat:
            self.title = @"我的微信";
            break;
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UITextField *textField = [UITextField new];
    [self.view addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(@(30));
    }];
    
    UIView *viewLine = [UIView new];
    viewLine.backgroundColor = [UIColor lightGrayColor];
    [textField addSubview:viewLine];
    [viewLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(0.5));
        make.left.and.bottom.and.right.equalTo(textField);
    }];
}

@end
