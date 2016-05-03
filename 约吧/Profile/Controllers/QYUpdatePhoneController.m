//
//  QYUpdatePhoneController.m
//  约吧
//
//  Created by Shreker on 16/4/27.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYUpdatePhoneController.h"

@interface QYUpdatePhoneController ()
{
    __weak IBOutlet UITextField *_txfPhone;
    __weak IBOutlet UIButton *_btnGetCode;
}

@end

@implementation QYUpdatePhoneController

#pragma mark - ♻️ LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultSetting];
}

/** Load the default UI elements And prepare some datas needed. */
- (void)loadDefaultSetting {
    [_btnGetCode.layer setCornerRadius:5.0];
    [_btnGetCode.layer setMasksToBounds:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChanged:) name:UITextFieldTextDidChangeNotification object:_txfPhone];
}

#pragma mark - 🎬 Action Methods
- (void)textFieldTextDidChanged:(NSNotification *)notification {
    NSLog(@"%@", _txfPhone.text);
}
- (IBAction)save:(UIBarButtonItem *)sender {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - 🔌 Delegate Methods



@end
