//
//  QYUpdatePwdController.m
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYUpdatePwdController.h"

@interface QYUpdatePwdController ()
{
    __weak IBOutlet UITextField *_txfOldPwd;
    __weak IBOutlet UITextField *_txfNewPwd;
    __weak IBOutlet UITextField *_txfConfirmNewPwd;
}

@end

@implementation QYUpdatePwdController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    
}

#pragma mark - 🎬 Action Methods
- (IBAction)save:(UIBarButtonItem *)sender {
    NSLog(@"%s", __FUNCTION__);
    if (_txfOldPwd.text.length <= 0) {
        NSLog(@"轻输入旧密码");
        return;
    }
}

@end
