//
//  QYCreateTagViewController.m
//  约吧
//
//  Created by Shreker on 16/4/28.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYCreateTagViewController.h"
#import "Masonry.h"

@interface QYCreateTagViewController ()

@end

@implementation QYCreateTagViewController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    self.view.backgroundColor = [UIColor whiteColor];
    
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
